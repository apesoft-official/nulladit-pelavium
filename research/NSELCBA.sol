// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

/// @title Node Service Exchange Lawful Canadian Barter Attestation (NSELCBA)
/// @notice Research candidate for a node operator's voluntary service-for-token
///         acceptance and individual service-exchange attestations.
/// @dev The title is a project label, not a legal opinion or regulator finding.
///      This contract does not determine that NULL22 or any arrangement is or
///      is not a security, legal tender, money, or tax-recognized barter. It
///      does not verify service evidence, transfer tokens, or alter any NULLADIT
///      founding contract or Aurora Covenant state.
contract NSELCBA {
    uint256 public constant TARGET_CHAIN_ID = 324;
    address public constant NULL22_TOKEN =
        0x332a8e2CeE5398D52616fCABd87966010C5A7a82;

    /// @notice Identifier for the canonical operator terms linked by this
    ///         research candidate. The terms text is published separately.
    bytes32 public constant TERMS_HASH =
        0x562d1df1b410a8791d7c0df7957d9e20c95fd9ed9c1ee5ebdf829c83b2367b04;

    enum ServiceCategory {
        Delivery,
        TemporaryEncryptedStorage,
        Availability
    }

    struct ServiceExchange {
        uint64 recordedAt;
        ServiceCategory category;
        bytes32 termsHash;
        uint128 null22AmountAccepted;
        uint128 agreedServiceValueCadMicros;
        bytes32 serviceEvidenceCommitment;
    }

    mapping(address operator => bool accepted) public termsAccepted;
    mapping(address operator => uint64 nextReceiptId) public nextReceiptId;
    mapping(address operator => mapping(uint64 receiptId => ServiceExchange))
        public serviceExchanges;
    mapping(bytes32 evidenceCommitment => bool used) public evidenceCommitmentUsed;

    error WrongChain();
    error TermsAlreadyAccepted();
    error TermsNotAccepted();
    error TermsNotActive();
    error InvalidExchange();
    error EvidenceAlreadyUsed();

    event OperatorTermsAccepted(
        address indexed operator,
        bytes32 indexed termsHash,
        uint256 chainId
    );
    event OperatorTermsRevoked(address indexed operator, bytes32 indexed termsHash);
    event ServiceExchangeAttested(
        address indexed operator,
        uint64 indexed receiptId,
        ServiceCategory category,
        bytes32 indexed serviceEvidenceCommitment,
        bytes32 termsHash,
        uint128 null22AmountAccepted,
        uint128 agreedServiceValueCadMicros,
        uint64 recordedAt
    );

    constructor() {
        if (block.chainid != TARGET_CHAIN_ID) revert WrongChain();
    }

    /// @notice The node operator opts into the published terms for this exact
    ///         version by submitting a transaction from its own wallet.
    function acceptTerms() external {
        if (termsAccepted[msg.sender]) revert TermsAlreadyAccepted();
        termsAccepted[msg.sender] = true;
        emit OperatorTermsAccepted(msg.sender, TERMS_HASH, block.chainid);
    }

    /// @notice Stops future attestations from this wallet while preserving the
    ///         immutable on-chain history of prior acceptances and receipts.
    function revokeTerms() external {
        if (!termsAccepted[msg.sender]) revert TermsNotActive();
        termsAccepted[msg.sender] = false;
        emit OperatorTermsRevoked(msg.sender, TERMS_HASH);
    }

    /// @notice Records the operator's own statement about an agreed service
    ///         exchange. The caller supplies only an opaque evidence commitment;
    ///         no message data, identity, IP address, or raw evidence belongs
    ///         on-chain. The contract does not independently validate the work,
    ///         CAD valuation, or receipt/payment of NULL22.
    function attestServiceExchange(
        ServiceCategory category,
        bytes32 serviceEvidenceCommitment,
        uint128 null22AmountAccepted,
        uint128 agreedServiceValueCadMicros
    ) external returns (uint64 receiptId) {
        if (!termsAccepted[msg.sender]) revert TermsNotAccepted();
        if (
            serviceEvidenceCommitment == bytes32(0) ||
            null22AmountAccepted == 0 ||
            agreedServiceValueCadMicros == 0
        ) revert InvalidExchange();
        if (evidenceCommitmentUsed[serviceEvidenceCommitment])
            revert EvidenceAlreadyUsed();

        receiptId = nextReceiptId[msg.sender] + 1;
        nextReceiptId[msg.sender] = receiptId;
        evidenceCommitmentUsed[serviceEvidenceCommitment] = true;
        serviceExchanges[msg.sender][receiptId] = ServiceExchange({
            recordedAt: uint64(block.timestamp),
            category: category,
            termsHash: TERMS_HASH,
            null22AmountAccepted: null22AmountAccepted,
            agreedServiceValueCadMicros: agreedServiceValueCadMicros,
            serviceEvidenceCommitment: serviceEvidenceCommitment
        });

        emit ServiceExchangeAttested(
            msg.sender,
            receiptId,
            category,
            serviceEvidenceCommitment,
            TERMS_HASH,
            null22AmountAccepted,
            agreedServiceValueCadMicros,
            uint64(block.timestamp)
        );
    }
}
