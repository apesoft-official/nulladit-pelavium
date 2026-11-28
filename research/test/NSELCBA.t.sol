// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "../NSELCBA.sol";

interface Vm {
    function chainId(uint256) external;
    function prank(address) external;
    function expectRevert(bytes4) external;
}

contract NSELCBATest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    NSELCBA candidate;
    address constant OPERATOR = address(0xBEEF);
    bytes32 constant EVIDENCE = keccak256("synthetic opaque evidence");

    function setUp() public {
        vm.chainId(324);
        candidate = new NSELCBA();
    }

    function testDeploymentChainAndTokenReference() public view {
        require(candidate.TARGET_CHAIN_ID() == 324);
        require(candidate.NULL22_TOKEN() == 0x332a8e2CeE5398D52616fCABd87966010C5A7a82);
        require(candidate.TERMS_HASH() != bytes32(0));
    }

    function testWrongChainRejected() public {
        vm.chainId(1);
        vm.expectRevert(NSELCBA.WrongChain.selector);
        new NSELCBA();
    }

    function testOperatorMustOptIn() public {
        vm.expectRevert(NSELCBA.TermsNotAccepted.selector);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            EVIDENCE,
            10 ether,
            100_000_000
        );
    }

    function testAcceptAndAttest() public {
        vm.prank(OPERATOR);
        candidate.acceptTerms();
        require(candidate.termsAccepted(OPERATOR));

        vm.prank(OPERATOR);
        uint64 receiptId = candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.TemporaryEncryptedStorage,
            EVIDENCE,
            25 ether,
            2_500_000_000
        );

        require(receiptId == 1);
        require(candidate.nextReceiptId(OPERATOR) == 1);
        (
            uint64 recordedAt,
            NSELCBA.ServiceCategory category,
            bytes32 termsHash,
            uint128 amount,
            uint128 agreedValue,
            bytes32 evidence
        ) = candidate.serviceExchanges(OPERATOR, receiptId);
        require(recordedAt != 0);
        require(category == NSELCBA.ServiceCategory.TemporaryEncryptedStorage);
        require(termsHash == candidate.TERMS_HASH());
        require(amount == 25 ether);
        require(agreedValue == 2_500_000_000);
        require(evidence == EVIDENCE);
    }

    function testDuplicateTermsAcceptanceRejected() public {
        candidate.acceptTerms();
        vm.expectRevert(NSELCBA.TermsAlreadyAccepted.selector);
        candidate.acceptTerms();
    }

    function testRevocationBlocksFutureAttestations() public {
        vm.prank(OPERATOR);
        candidate.acceptTerms();
        vm.prank(OPERATOR);
        candidate.revokeTerms();
        require(!candidate.termsAccepted(OPERATOR));
        vm.expectRevert(NSELCBA.TermsNotAccepted.selector);
        vm.prank(OPERATOR);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Availability,
            EVIDENCE,
            1,
            1
        );
    }

    function testReacceptAfterRevocation() public {
        candidate.acceptTerms();
        candidate.revokeTerms();
        candidate.acceptTerms();
        require(candidate.termsAccepted(address(this)));
    }

    function testZeroEvidenceRejected() public {
        candidate.acceptTerms();
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            bytes32(0),
            1,
            1
        );
    }

    function testZeroTokenAmountRejected() public {
        candidate.acceptTerms();
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            EVIDENCE,
            0,
            1
        );
    }

    function testZeroAgreedValueRejected() public {
        candidate.acceptTerms();
        vm.expectRevert(NSELCBA.InvalidExchange.selector);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            EVIDENCE,
            1,
            0
        );
    }

    function testEvidenceCommitmentCannotBeReplayedByAnotherOperator() public {
        candidate.acceptTerms();
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            EVIDENCE,
            1,
            1
        );

        vm.prank(OPERATOR);
        candidate.acceptTerms();
        vm.expectRevert(NSELCBA.EvidenceAlreadyUsed.selector);
        vm.prank(OPERATOR);
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Availability,
            EVIDENCE,
            1,
            1
        );
    }

    function testReceiptSequenceIsPerOperator() public {
        candidate.acceptTerms();
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            EVIDENCE,
            1,
            1
        );
        vm.prank(OPERATOR);
        candidate.acceptTerms();
        vm.prank(OPERATOR);
        uint64 otherReceipt = candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Availability,
            keccak256("second synthetic evidence"),
            2,
            2
        );
        require(otherReceipt == 1);
        require(candidate.nextReceiptId(address(this)) == 1);
        require(candidate.nextReceiptId(OPERATOR) == 1);
    }
}
