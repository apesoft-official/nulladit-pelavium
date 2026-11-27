// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IVestigiumCovenant {
    function foundationRoot() external view returns (bytes32);
    function isReleaseApproved(uint64 version) external view returns (bool);
    function releases(uint64 version) external view returns
        (bytes32 sourceRevision, bytes32 artifactHash, bytes32 manifestHash,
         uint64 recordedAt, bool revoked);
}

/// @notice RESEARCH ONLY. Not production authority or proof of delivery.
/// @dev No personal information, individual routes, or raw evidence on-chain.
contract Vestigium {
    IVestigiumCovenant public immutable covenant;
    bytes32 public immutable foundationRoot;
    bytes32 public immutable manifestHash;
    uint64 public immutable releaseVersion;
    address public immutable batchPublisher;
    uint64 public lastEpoch;
    mapping(uint64 => bytes32) public batchRoots;

    error InvalidConfiguration();
    error NotApproved();
    error InvalidBatch();
    error Unauthorized();
    event BatchCommitted(uint64 indexed epoch, bytes32 root);

    constructor(address covenant_, bytes32 foundation_, bytes32 manifest_,
        uint64 version_, address publisher_) {
        if (block.chainid != 324 || covenant_.code.length == 0 ||
            foundation_ == bytes32(0) || manifest_ == bytes32(0) ||
            version_ == 0 || publisher_ == address(0))
            revert InvalidConfiguration();
        covenant = IVestigiumCovenant(covenant_);
        foundationRoot = foundation_;
        manifestHash = manifest_;
        releaseVersion = version_;
        batchPublisher = publisher_;
        if (covenant.foundationRoot() != foundation_) revert InvalidConfiguration();
    }

    function active() public view returns (bool) {
        if (block.chainid != 324 || covenant.foundationRoot() != foundationRoot ||
            !covenant.isReleaseApproved(releaseVersion)) return false;
        (, , bytes32 approvedManifest, , bool revoked) = covenant.releases(releaseVersion);
        return !revoked && approvedManifest == configurationCommitment();
    }

    /// @notice Governance must approve this exact instance and configuration.
    function configurationCommitment() public view returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("NULLADIT:VESTIGIUM:CONFIG:V1"),
            block.chainid, address(this), address(covenant), foundationRoot,
            manifestHash, releaseVersion, batchPublisher
        ));
    }

    /// @notice Anchor an opaque, padded batch commitment only.
    /// @dev The approved configuration binds the publisher and this instance.
    function commitBatch(uint64 epoch, bytes32 root) external {
        if (msg.sender != batchPublisher) revert Unauthorized();
        if (!active()) revert NotApproved();
        if (epoch != lastEpoch + 1 || root == bytes32(0)) revert InvalidBatch();
        batchRoots[epoch] = root;
        lastEpoch = epoch;
        emit BatchCommitted(epoch, root);
    }
}
