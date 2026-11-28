// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/// @title Node Service Exchange Lawful Canadian Barter Attestation (NSELCBA)
/// @notice Research-only candidate for a bilateral service-for-token exchange
///         attested by every node in an explicitly supplied witness snapshot.
/// @dev The title is a project label, not a legal opinion or regulator finding.
///      This contract records signatures and statements only: it does not
///      transfer NULL22, verify service performance, establish the completeness
///      of a supplied node snapshot, or decide any Canadian legal classification.
contract NSELCBA {
    uint256 public constant TARGET_CHAIN_ID = 324;
    address public constant NULL22_TOKEN =
        0x332a8e2CeE5398D52616fCABd87966010C5A7a82;

    /// @notice Hash of the exact exchange terms published with this candidate.
    bytes32 public constant TERMS_HASH =
        0x5d3b9f4c4eb2dff0d6aa27f8c4fd8e6b533f118f253618e49a2413fca504a9e0;

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 private constant EXCHANGE_TYPEHASH = keccak256(
        "ServiceExchange(address partyA,address partyB,uint8 category,uint128 null22AmountAccepted,uint128 agreedServiceValueCadMicros,bytes32 termsHash,uint64 expiry,uint256 chainId,bytes32 serviceEvidenceCommitment,bytes32 witnessSnapshotHash)"
    );
    bytes32 private constant NAME_HASH = keccak256("NSELCBA");
    bytes32 private constant VERSION_HASH = keccak256("2");
    bytes4 private constant ERC1271_MAGICVALUE = 0x1626ba7e;
    uint256 private constant SECP256K1_HALF_ORDER =
        0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;

    enum ServiceCategory {
        Delivery,
        TemporaryEncryptedStorage,
        Availability
    }

    /// @notice Every field, including the witness roster hash, is signed by
    ///         both parties and every address in the witness snapshot.
    struct Exchange {
        address partyA;
        address partyB;
        ServiceCategory category;
        uint128 null22AmountAccepted;
        uint128 agreedServiceValueCadMicros;
        bytes32 termsHash;
        uint64 expiry;
        uint256 chainId;
        bytes32 serviceEvidenceCommitment;
    }

    struct ServiceExchange {
        uint64 recordedAt;
        uint64 expiry;
        ServiceCategory category;
        address partyA;
        address partyB;
        bytes32 termsHash;
        uint128 null22AmountAccepted;
        uint128 agreedServiceValueCadMicros;
        bytes32 serviceEvidenceCommitment;
        bytes32 witnessSnapshotHash;
        uint32 witnessCount;
    }

    uint64 public nextReceiptId;
    mapping(uint64 receiptId => ServiceExchange) public serviceExchanges;
    mapping(uint64 receiptId => address[]) private _witnessSnapshots;
    mapping(bytes32 evidenceCommitment => bool used) public evidenceCommitmentUsed;

    error WrongChain();
    error InvalidExchange();
    error ExchangeExpired();
    error InvalidSnapshot();
    error SignatureCountMismatch();
    error InvalidSignature();
    error EvidenceAlreadyUsed();

    event ServiceExchangeAttested(
        uint64 indexed receiptId,
        address indexed partyA,
        address indexed partyB,
        ServiceCategory category,
        bytes32 serviceEvidenceCommitment,
        bytes32 termsHash,
        bytes32 witnessSnapshotHash,
        uint128 null22AmountAccepted,
        uint128 agreedServiceValueCadMicros,
        uint64 expiry,
        uint32 witnessCount,
        uint64 recordedAt
    );

    constructor() {
        if (block.chainid != TARGET_CHAIN_ID) revert WrongChain();
    }

    /// @notice Returns the EIP-712 digest both parties and all listed witnesses
    ///         must sign. The supplied roster must be sorted and contain no
    ///         duplicates; this function does not prove the roster is globally
    ///         complete.
    function exchangeDigest(
        Exchange calldata exchange,
        address[] calldata witnessSnapshot
    ) external view returns (bytes32) {
        return _exchangeDigest(exchange, witnessSnapshot);
    }

    /// @notice Records an exchange after verifying both parties and every node
    ///         in the jointly specified witness snapshot signed the same
    ///         EIP-712 digest. Any relayer may submit the collected signatures.
    /// @dev No NULL22 or other asset is transferred. The amount and CAD value
    ///      are the parties' signed statements, not verified payment or a legal
    ///      valuation. This function does not establish the snapshot's global
    ///      completeness or determine whether NULL22 is a security under law.
    function attestServiceExchange(
        Exchange calldata exchange,
        address[] calldata witnessSnapshot,
        bytes calldata partyASignature,
        bytes calldata partyBSignature,
        bytes[] calldata witnessSignatures
    ) external returns (uint64 receiptId) {
        _validateExchange(exchange);
        _validateSnapshot(exchange, witnessSnapshot);
        if (witnessSignatures.length != witnessSnapshot.length) {
            revert SignatureCountMismatch();
        }

        bytes32 digest = _exchangeDigest(exchange, witnessSnapshot);
        if (!_isValidSignature(exchange.partyA, digest, partyASignature)) {
            revert InvalidSignature();
        }
        if (!_isValidSignature(exchange.partyB, digest, partyBSignature)) {
            revert InvalidSignature();
        }
        for (uint256 i; i < witnessSnapshot.length; ++i) {
            if (!_isValidSignature(witnessSnapshot[i], digest, witnessSignatures[i])) {
                revert InvalidSignature();
            }
        }
        if (evidenceCommitmentUsed[exchange.serviceEvidenceCommitment]) {
            revert EvidenceAlreadyUsed();
        }

        receiptId = _recordExchange(exchange, witnessSnapshot);
    }

    /// @notice Returns the exact roster whose members' signatures were checked.
    function getWitnessSnapshot(uint64 receiptId)
        external
        view
        returns (address[] memory)
    {
        return _witnessSnapshots[receiptId];
    }

    /// @notice Returns the complete stored receipt without tuple expansion.
    function getServiceExchange(uint64 receiptId)
        external
        view
        returns (ServiceExchange memory)
    {
        return serviceExchanges[receiptId];
    }

    function _recordExchange(
        Exchange calldata exchange,
        address[] calldata witnessSnapshot
    ) private returns (uint64 receiptId) {
        receiptId = ++nextReceiptId;
        evidenceCommitmentUsed[exchange.serviceEvidenceCommitment] = true;
        bytes32 snapshotHash = keccak256(abi.encode(witnessSnapshot));

        ServiceExchange memory receipt;
        receipt.recordedAt = uint64(block.timestamp);
        receipt.expiry = exchange.expiry;
        receipt.category = exchange.category;
        receipt.partyA = exchange.partyA;
        receipt.partyB = exchange.partyB;
        receipt.termsHash = exchange.termsHash;
        receipt.null22AmountAccepted = exchange.null22AmountAccepted;
        receipt.agreedServiceValueCadMicros = exchange.agreedServiceValueCadMicros;
        receipt.serviceEvidenceCommitment = exchange.serviceEvidenceCommitment;
        receipt.witnessSnapshotHash = snapshotHash;
        receipt.witnessCount = uint32(witnessSnapshot.length);
        serviceExchanges[receiptId] = receipt;

        for (uint256 i; i < witnessSnapshot.length; ++i) {
            _witnessSnapshots[receiptId].push(witnessSnapshot[i]);
        }

        emit ServiceExchangeAttested(
            receiptId,
            exchange.partyA,
            exchange.partyB,
            exchange.category,
            exchange.serviceEvidenceCommitment,
            exchange.termsHash,
            snapshotHash,
            exchange.null22AmountAccepted,
            exchange.agreedServiceValueCadMicros,
            exchange.expiry,
            uint32(witnessSnapshot.length),
            uint64(block.timestamp)
        );
    }

    function _validateExchange(Exchange calldata exchange) private view {
        if (block.chainid != TARGET_CHAIN_ID || exchange.chainId != block.chainid) {
            revert WrongChain();
        }
        if (
            exchange.partyA == address(0) || exchange.partyB == address(0) ||
            exchange.partyA == exchange.partyB ||
            exchange.null22AmountAccepted == 0 ||
            exchange.agreedServiceValueCadMicros == 0 ||
            exchange.termsHash != TERMS_HASH ||
            exchange.serviceEvidenceCommitment == bytes32(0)
        ) revert InvalidExchange();
        if (exchange.expiry <= block.timestamp) revert ExchangeExpired();
    }

    function _validateSnapshot(
        Exchange calldata exchange,
        address[] calldata witnessSnapshot
    ) private pure {
        if (witnessSnapshot.length == 0 || witnessSnapshot.length > type(uint32).max) {
            revert InvalidSnapshot();
        }
        address previous;
        for (uint256 i; i < witnessSnapshot.length; ++i) {
            address witness = witnessSnapshot[i];
            if (
                witness == address(0) || witness == exchange.partyA ||
                witness == exchange.partyB || witness <= previous
            ) revert InvalidSnapshot();
            previous = witness;
        }
    }

    function _exchangeDigest(
        Exchange calldata exchange,
        address[] calldata witnessSnapshot
    ) private view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                EXCHANGE_TYPEHASH,
                exchange.partyA,
                exchange.partyB,
                uint8(exchange.category),
                exchange.null22AmountAccepted,
                exchange.agreedServiceValueCadMicros,
                exchange.termsHash,
                exchange.expiry,
                exchange.chainId,
                exchange.serviceEvidenceCommitment,
                keccak256(abi.encode(witnessSnapshot))
            )
        );
        bytes32 domainSeparator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                NAME_HASH,
                VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

    function _isValidSignature(
        address signer,
        bytes32 digest,
        bytes calldata signature
    ) private view returns (bool) {
        if (signer.code.length != 0) {
            (bool ok, bytes memory result) = signer.staticcall(
                abi.encodeWithSelector(ERC1271_MAGICVALUE, digest, signature)
            );
            return ok && result.length >= 32 && abi.decode(result, (bytes4)) == ERC1271_MAGICVALUE;
        }
        if (signature.length != 65) return false;

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly ("memory-safe") {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }
        if (v != 27 && v != 28) return false;
        if (uint256(s) == 0 || uint256(s) > SECP256K1_HALF_ORDER) return false;
        return ecrecover(digest, v, r, s) == signer;
    }
}
