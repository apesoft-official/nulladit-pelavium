// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "../NSELCBA.sol";

interface Vm {
    function chainId(uint256) external;
    function warp(uint256) external;
    function addr(uint256 privateKey) external returns (address);
    function sign(uint256 privateKey, bytes32 digest)
        external
        returns (uint8 v, bytes32 r, bytes32 s);
    function expectRevert(bytes4) external;
}

contract NSELCBATest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 private constant PARTY_A_KEY = 0xA11CE;
    uint256 private constant PARTY_B_KEY = 0xB0B;
    uint256 private constant WITNESS_A_KEY = 0xC0C;
    uint256 private constant WITNESS_B_KEY = 0xD0D;

    NSELCBA candidate;

    function setUp() public {
        vm.chainId(324);
        vm.warp(1_700_000_000);
        candidate = new NSELCBA();
    }

    function testDeploymentChainAndTokenReference() public view {
        require(candidate.TARGET_CHAIN_ID() == 324);
        require(candidate.NULL22_TOKEN() == 0x332a8e2CeE5398D52616fCABd87966010C5A7a82);
        require(
            candidate.TERMS_HASH() ==
                0x5d3b9f4c4eb2dff0d6aa27f8c4fd8e6b533f118f253618e49a2413fca504a9e0
        );
    }

    function testWrongDeploymentChainRejected() public {
        vm.chainId(1);
        vm.expectRevert(NSELCBA.WrongChain.selector);
        new NSELCBA();
    }

    function testBothPartiesAndEveryWitnessMustSign() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("synthetic exchange evidence"));

        uint64 receiptId = candidate.attestServiceExchange(
            exchange, witnesses, partyASig, partyBSig, witnessSigs
        );
        require(receiptId == 1);
        require(candidate.nextReceiptId() == 1);
        require(candidate.evidenceCommitmentUsed(exchange.serviceEvidenceCommitment));

        NSELCBA.ServiceExchange memory saved = candidate.getServiceExchange(receiptId);
        require(saved.recordedAt == block.timestamp);
        require(saved.expiry == exchange.expiry);
        require(saved.category == exchange.category);
        require(saved.partyA == exchange.partyA && saved.partyB == exchange.partyB);
        require(saved.termsHash == candidate.TERMS_HASH());
        require(saved.null22AmountAccepted == exchange.null22AmountAccepted);
        require(saved.agreedServiceValueCadMicros == exchange.agreedServiceValueCadMicros);
        require(saved.serviceEvidenceCommitment == exchange.serviceEvidenceCommitment);
        require(saved.witnessSnapshotHash == keccak256(abi.encode(witnesses)));
        require(saved.witnessCount == witnesses.length);

        address[] memory storedWitnesses = candidate.getWitnessSnapshot(receiptId);
        require(storedWitnesses.length == witnesses.length);
        for (uint256 i; i < witnesses.length; ++i) {
            require(storedWitnesses[i] == witnesses[i]);
        }
    }

    function testMissingPartySignatureRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("missing party signature"));
        require(partyBSig.length == 65);
        vm.expectRevert(NSELCBA.InvalidSignature.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, "", witnessSigs);
    }

    function testMissingWitnessSignatureRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("missing witness signature"));
        require(partyBSig.length == 65 && witnessSigs.length == witnesses.length);
        bytes[] memory missing = new bytes[](witnesses.length - 1);
        vm.expectRevert(NSELCBA.SignatureCountMismatch.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, missing);
    }

    function testEveryWitnessMustSignSameDigest() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("wrong witness digest"));
        witnessSigs[0] = _signature(WITNESS_A_KEY, keccak256("different digest"));
        vm.expectRevert(NSELCBA.InvalidSignature.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testSnapshotMustBeSortedAndUnique() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("duplicate witness"));
        witnesses[1] = witnesses[0];
        vm.expectRevert(NSELCBA.InvalidSnapshot.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testPartyCannotBeCountedAsItsOwnWitness() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("party as witness"));
        witnesses[0] = exchange.partyA;
        if (witnesses[0] > witnesses[1]) {
            address swap = witnesses[0];
            witnesses[0] = witnesses[1];
            witnesses[1] = swap;
        }
        vm.expectRevert(NSELCBA.InvalidSnapshot.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testExpiredExchangeRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("expired exchange"));
        exchange.expiry = uint64(block.timestamp);
        vm.expectRevert(NSELCBA.ExchangeExpired.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testWrongChainInSignedExchangeRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("wrong chain"));
        exchange.chainId = 1;
        vm.expectRevert(NSELCBA.WrongChain.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testChangedTermsInvalidateSignatures() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("changed terms"));
        exchange.null22AmountAccepted += 1;
        vm.expectRevert(NSELCBA.InvalidSignature.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testEvidenceCommitmentCannotBeReplayed() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("replayed evidence"));
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
        vm.expectRevert(NSELCBA.EvidenceAlreadyUsed.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testWrongPartySignatureRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            ,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("wrong party signer"));
        require(partyASig.length == 65);
        bytes memory wrongPartySig = _signature(WITNESS_A_KEY, candidate.exchangeDigest(exchange, witnesses));
        vm.expectRevert(NSELCBA.InvalidSignature.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, wrongPartySig, witnessSigs);
    }

    function testZeroEvidenceRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(bytes32(0));
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testUnrecognizedTermsHashRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("wrong terms version"));
        exchange.termsHash = keccak256("unrecognized terms");
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testZeroAmountsRejected() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("zero amount"));
        exchange.null22AmountAccepted = 0;
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);

        exchange.null22AmountAccepted = 1;
        exchange.agreedServiceValueCadMicros = 0;
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(exchange, witnesses, partyASig, partyBSig, witnessSigs);
    }

    function testSnapshotCannotBeEmpty() public {
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("empty snapshot"));
        require(witnesses.length == 2);
        address[] memory empty = new address[](0);
        vm.expectRevert(NSELCBA.InvalidSnapshot.selector);
        candidate.attestServiceExchange(exchange, empty, partyASig, partyBSig, witnessSigs);
    }

    function testContractWalletPartyCanSignThroughERC1271() public {
        MockERC1271 wallet = new MockERC1271(vm.addr(PARTY_A_KEY));
        (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory oldPartyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        ) = _signedExchange(keccak256("contract wallet"));
        require(oldPartyASig.length == 65);
        exchange.partyA = address(wallet);
        bytes32 digest = candidate.exchangeDigest(exchange, witnesses);
        bytes memory walletSig = _signature(PARTY_A_KEY, digest);
        partyBSig = _signature(PARTY_B_KEY, digest);
        uint256 witnessKeyA = WITNESS_A_KEY;
        uint256 witnessKeyB = WITNESS_B_KEY;
        if (vm.addr(witnessKeyA) > vm.addr(witnessKeyB)) {
            (witnessKeyA, witnessKeyB) = (witnessKeyB, witnessKeyA);
        }
        witnessSigs[0] = _signature(witnessKeyA, digest);
        witnessSigs[1] = _signature(witnessKeyB, digest);
        candidate.attestServiceExchange(exchange, witnesses, walletSig, partyBSig, witnessSigs);
        require(candidate.nextReceiptId() == 1);
    }

    function _signedExchange(bytes32 evidence)
        private
        returns (
            NSELCBA.Exchange memory exchange,
            address[] memory witnesses,
            bytes memory partyASig,
            bytes memory partyBSig,
            bytes[] memory witnessSigs
        )
    {
        exchange = NSELCBA.Exchange({
            partyA: vm.addr(PARTY_A_KEY),
            partyB: vm.addr(PARTY_B_KEY),
            category: NSELCBA.ServiceCategory.Delivery,
            null22AmountAccepted: 25 ether,
            agreedServiceValueCadMicros: 2_500_000_000,
            termsHash: candidate.TERMS_HASH(),
            expiry: uint64(block.timestamp + 1 days),
            chainId: 324,
            serviceEvidenceCommitment: evidence
        });

        uint256 witnessKeyA = WITNESS_A_KEY;
        uint256 witnessKeyB = WITNESS_B_KEY;
        address witnessA = vm.addr(witnessKeyA);
        address witnessB = vm.addr(witnessKeyB);
        if (witnessA > witnessB) {
            (witnessA, witnessB) = (witnessB, witnessA);
            (witnessKeyA, witnessKeyB) = (witnessKeyB, witnessKeyA);
        }
        witnesses = new address[](2);
        witnesses[0] = witnessA;
        witnesses[1] = witnessB;

        bytes32 digest = candidate.exchangeDigest(exchange, witnesses);
        partyASig = _signature(PARTY_A_KEY, digest);
        partyBSig = _signature(PARTY_B_KEY, digest);
        witnessSigs = new bytes[](2);
        witnessSigs[0] = _signature(witnessKeyA, digest);
        witnessSigs[1] = _signature(witnessKeyB, digest);
    }

    function _signature(uint256 key, bytes32 digest) private returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        return abi.encodePacked(r, s, v);
    }
}

contract MockERC1271 {
    bytes4 private constant MAGICVALUE = 0x1626ba7e;
    address private immutable owner;

    constructor(address owner_) {
        owner = owner_;
    }

    function isValidSignature(bytes32 digest, bytes calldata signature)
        external
        view
        returns (bytes4)
    {
        if (signature.length != 65) return 0xffffffff;
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly ("memory-safe") {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }
        return ecrecover(digest, v, r, s) == owner ? MAGICVALUE : bytes4(0xffffffff);
    }
}
