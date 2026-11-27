// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @notice Interface to the three-constituency election candidate.
interface IAuroraCovenantElection {
    function authority() external view returns (address);
    function result(uint256 electionId)
        external
        view
        returns (bool approved, uint256 executableAt, bytes32 action);
}

interface IAuroraFoundationToken {
    function authority() external view returns (address);
    function controller() external view returns (address);
}

interface IAuroraFoundationAuthority {
    function primary() external view returns (address);
    function miningPaused() external view returns (bool);
}

interface IAuroraFoundationController {
    function authority() external view returns (address);
    function token() external view returns (address);
}

interface IAuroraFoundationPricing {
    function OFFICIAL_TREASURY() external view returns (address);
}

interface IAuroraFoundationRegistration {
    function pricing() external view returns (address);
}

interface IAuroraFoundationAdapter {
    function controller() external view returns (address);
    function registration() external view returns (address);
}

interface IAuroraFoundationEpoch {
    function controller() external view returns (address);
}

interface IAuroraFoundationAdjudication {
    function authority() external view returns (address);
}

/// @title Aurora Covenant
/// @notice Governance-gated, append-only registry for approved PELAVIUM release
///         commitments. It pins the original eight NULLADIT mainnet contracts.
/// @dev This contract does not install software or control the founding contracts.
///      A client or node must separately verify a downloaded artifact against a
///      recorded release. Candidate only; independent review and governance
///      approval are required before deployment.
contract AuroraCovenant {
    uint256 public constant TARGET_CHAIN_ID = 324;
    uint256 private constant FOUNDATION_COUNT = 8;

    bytes32 public constant RELEASE_DOMAIN =
        keccak256("NULLADIT:AURORA_COVENANT:RELEASE:V1");
    bytes32 public constant REVOCATION_DOMAIN =
        keccak256("NULLADIT:AURORA_COVENANT:REVOCATION:V1");

    // Founding order: token, authority, controller, registration pricing,
    // mining registration V3, settlement adapter V3, epoch anchor,
    // adjudication governance.
    address public constant NULL22_TOKEN =
        0x332a8e2CeE5398D52616fCABd87966010C5A7a82;
    address public constant NULL22_AUTHORITY =
        0xEDbE3eF68315F9De399Cb77f0243C5a20e11305C;
    address public constant NULL22_CONTROLLER =
        0x4bd6776a16cC838D4A92C16FB3B0bc32330E3427;
    address public constant NVSP_REGISTRATION_PRICING =
        0xdEbbc5932516c6FC083b2F2B8aAd823402f148B5;
    address public constant NVSP_MINING_REGISTRATION_V3 =
        0x4A1e5037397837fFD7Bd59865A3a0dCD06386E15;
    address public constant NVSP_SETTLEMENT_ADAPTER_V3 =
        0x78E84F3649976fc418a9aD53Bb0e4063AfB47af2;
    address public constant NVSP_EPOCH_ANCHOR =
        0xaC4179803BeDbEe923BDF4b82eC147cF82f7B9D8;
    address public constant NVSP_ADJUDICATION_GOVERNANCE =
        0x978eD18f0a017b06d4F0C02EB11D4C540D3c5c06;

    IAuroraCovenantElection public immutable election;
    uint256 public immutable deploymentChainId;
    bytes32 public immutable foundationRoot;

    address[8] public foundationContracts;
    bytes32[8] public foundationCodeHashes;

    uint64 public latestVersion;
    mapping(uint64 => Release) public releases;
    mapping(uint256 => bool) public consumedElection;

    struct Release {
        bytes32 sourceRevision;
        bytes32 artifactHash;
        bytes32 manifestHash;
        uint64 recordedAt;
        bool revoked;
    }

    error WrongChain();
    error InvalidFoundation();
    error InvalidElection();
    error InvalidRelease();
    error InvalidApproval();
    error ElectionAlreadyConsumed();
    error FoundationChanged();
    error UnknownRelease();

    event FoundationPinned(
        bytes32 indexed foundationRoot,
        uint256 indexed chainId
    );
    event ReleaseRecorded(
        uint64 indexed version,
        uint256 indexed electionId,
        bytes32 sourceRevision,
        bytes32 artifactHash,
        bytes32 manifestHash
    );
    event ReleaseRevoked(
        uint64 indexed version,
        uint256 indexed electionId
    );

    constructor(address election_) {
        if (block.chainid != TARGET_CHAIN_ID) revert WrongChain();
        if (election_ == address(0) || election_.code.length == 0)
            revert InvalidElection();

        IAuroraCovenantElection candidateElection =
            IAuroraCovenantElection(election_);

        address[8] memory founding;
        founding[0] = NULL22_TOKEN;
        founding[1] = NULL22_AUTHORITY;
        founding[2] = NULL22_CONTROLLER;
        founding[3] = NVSP_REGISTRATION_PRICING;
        founding[4] = NVSP_MINING_REGISTRATION_V3;
        founding[5] = NVSP_SETTLEMENT_ADAPTER_V3;
        founding[6] = NVSP_EPOCH_ANCHOR;
        founding[7] = NVSP_ADJUDICATION_GOVERNANCE;

        bytes32[8] memory codeHashes;
        for (uint256 i; i < FOUNDATION_COUNT; ++i) {
            address foundation = founding[i];
            if (foundation.code.length == 0) revert InvalidFoundation();
            for (uint256 j; j < i; ++j) {
                if (founding[j] == foundation) revert InvalidFoundation();
            }
            bytes32 codeHash = foundation.codehash;
            if (codeHash == bytes32(0)) revert InvalidFoundation();
            codeHashes[i] = codeHash;
            foundationContracts[i] = foundation;
            foundationCodeHashes[i] = codeHash;
        }

        address token = founding[0];
        address authority = founding[1];
        address controller = founding[2];
        address pricing = founding[3];
        address registration = founding[4];
        address adapter = founding[5];
        address epochAnchor = founding[6];
        address adjudication = founding[7];

        if (
            IAuroraFoundationToken(token).authority() != authority ||
            IAuroraFoundationToken(token).controller() != controller ||
            IAuroraFoundationController(controller).authority() != authority ||
            IAuroraFoundationController(controller).token() != token ||
            IAuroraFoundationPricing(pricing).OFFICIAL_TREASURY() !=
                IAuroraFoundationAuthority(authority).primary() ||
            IAuroraFoundationRegistration(registration).pricing() != pricing ||
            IAuroraFoundationAdapter(adapter).controller() != controller ||
            IAuroraFoundationAdapter(adapter).registration() != registration ||
            IAuroraFoundationEpoch(epochAnchor).controller() != controller ||
            IAuroraFoundationAdjudication(adjudication).authority() != authority ||
            candidateElection.authority() != authority ||
            !IAuroraFoundationAuthority(authority).miningPaused()
        ) revert InvalidFoundation();

        election = candidateElection;
        deploymentChainId = block.chainid;
        foundationRoot = keccak256(
            abi.encode(block.chainid, founding, codeHashes)
        );

        emit FoundationPinned(foundationRoot, block.chainid);
    }

    function releaseAction(
        uint64 version,
        bytes32 sourceRevision,
        bytes32 artifactHash,
        bytes32 manifestHash
    ) public view returns (bytes32) {
        return keccak256(
            abi.encode(
                RELEASE_DOMAIN,
                deploymentChainId,
                address(this),
                foundationRoot,
                version,
                sourceRevision,
                artifactHash,
                manifestHash
            )
        );
    }

    function revocationAction(uint64 version)
        public
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                REVOCATION_DOMAIN,
                deploymentChainId,
                address(this),
                foundationRoot,
                version
            )
        );
    }

    /// @notice Anyone may record a release after governance approved the exact
    ///         version, source revision, artifact digest and manifest digest.
    function recordApprovedRelease(
        uint256 electionId,
        uint64 version,
        bytes32 sourceRevision,
        bytes32 artifactHash,
        bytes32 manifestHash
    ) external {
        _requireFoundationIntact();

        if (
            version != latestVersion + 1 ||
            sourceRevision == bytes32(0) ||
            artifactHash == bytes32(0) ||
            manifestHash == bytes32(0)
        ) revert InvalidRelease();

        bytes32 action = releaseAction(
            version,
            sourceRevision,
            artifactHash,
            manifestHash
        );
        _requireApproved(electionId, action);

        consumedElection[electionId] = true;
        releases[version] = Release({
            sourceRevision: sourceRevision,
            artifactHash: artifactHash,
            manifestHash: manifestHash,
            recordedAt: uint64(block.timestamp),
            revoked: false
        });
        latestVersion = version;

        emit ReleaseRecorded(
            version,
            electionId,
            sourceRevision,
            artifactHash,
            manifestHash
        );
    }

    /// @notice Revocation is also governance-gated and leaves the audit record.
    function recordApprovedRevocation(
        uint256 electionId,
        uint64 version
    ) external {
        _requireFoundationIntact();

        Release storage release = releases[version];
        if (release.recordedAt == 0 || release.revoked)
            revert UnknownRelease();

        _requireApproved(electionId, revocationAction(version));
        consumedElection[electionId] = true;
        release.revoked = true;

        emit ReleaseRevoked(version, electionId);
    }

    function isReleaseApproved(uint64 version)
        external
        view
        returns (bool)
    {
        Release storage release = releases[version];
        return
            deploymentChainId == block.chainid &&
            _foundationIntact() &&
            release.recordedAt != 0 &&
            !release.revoked;
    }

    function foundationIntact() external view returns (bool) {
        return deploymentChainId == block.chainid && _foundationIntact();
    }

    function _requireApproved(uint256 electionId, bytes32 expectedAction)
        private
        view
    {
        if (consumedElection[electionId])
            revert ElectionAlreadyConsumed();

        (bool approved, uint256 executableAt, bytes32 action) =
            election.result(electionId);

        if (
            !approved ||
            executableAt == 0 ||
            block.timestamp < executableAt ||
            action != expectedAction
        ) revert InvalidApproval();
    }

    function _requireFoundationIntact() private view {
        if (!_foundationIntact()) revert FoundationChanged();
    }

    function _foundationIntact() private view returns (bool) {
        for (uint256 i; i < FOUNDATION_COUNT; ++i) {
            address foundation = foundationContracts[i];
            if (
                foundation.code.length == 0 ||
                foundation.codehash != foundationCodeHashes[i]
            ) return false;
        }
        return true;
    }
}
