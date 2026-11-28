// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "../NSELCBA.sol";

interface VmFork {
    function addr(uint256 privateKey) external returns (address);
    function sign(uint256 privateKey, bytes32 digest)
        external
        returns (uint8 v, bytes32 r, bytes32 s);
}

/// @dev Run with: forge test --fork-url https://mainnet.era.zksync.io
///      This is a read-only compatibility smoke test, not a security audit.
contract NSELCBAFoundationForkTest {
    VmFork private constant vm =
        VmFork(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 private constant PARTY_A_KEY = 0xA11CE;
    uint256 private constant PARTY_B_KEY = 0xB0B;
    uint256 private constant WITNESS_A_KEY = 0xC0C;
    uint256 private constant WITNESS_B_KEY = 0xD0D;

    address[9] private foundations = [
        0x332a8e2CeE5398D52616fCABd87966010C5A7a82,
        0xEDbE3eF68315F9De399Cb77f0243C5a20e11305C,
        0x4bd6776a16cC838D4A92C16FB3B0bc32330E3427,
        0xdEbbc5932516c6FC083b2F2B8aAd823402f148B5,
        0x4A1e5037397837fFD7Bd59865A3a0dCD06386E15,
        0x78E84F3649976fc418a9aD53Bb0e4063AfB47af2,
        0xaC4179803BeDbEe923BDF4b82eC147cF82f7B9D8,
        0x978eD18f0a017b06d4F0C02EB11D4C540D3c5c06,
        0x738Ebf0d99D2a0c92d7A667b825aE8aa771E9e4e
    ];

    function testEightFoundationsAndAuroraRemainUntouched() public {
        require(block.chainid == 324, "wrong fork chain");

        bytes32[9] memory beforeHashes;
        for (uint256 i; i < foundations.length; ++i) {
            require(foundations[i].code.length != 0, "missing live contract code");
            beforeHashes[i] = foundations[i].codehash;
        }

        NSELCBA candidate = new NSELCBA();
        NSELCBA.Exchange memory exchange = NSELCBA.Exchange({
            partyA: vm.addr(PARTY_A_KEY),
            partyB: vm.addr(PARTY_B_KEY),
            category: NSELCBA.ServiceCategory.Delivery,
            null22AmountAccepted: 1 ether,
            agreedServiceValueCadMicros: 1_000_000,
            termsHash: candidate.TERMS_HASH(),
            expiry: uint64(block.timestamp + 1 days),
            chainId: 324,
            serviceEvidenceCommitment: keccak256("synthetic fork-only evidence")
        });

        uint256 witnessKeyA = WITNESS_A_KEY;
        uint256 witnessKeyB = WITNESS_B_KEY;
        address witnessA = vm.addr(witnessKeyA);
        address witnessB = vm.addr(witnessKeyB);
        if (witnessA > witnessB) {
            (witnessA, witnessB) = (witnessB, witnessA);
            (witnessKeyA, witnessKeyB) = (witnessKeyB, witnessKeyA);
        }
        address[] memory witnesses = new address[](2);
        witnesses[0] = witnessA;
        witnesses[1] = witnessB;

        bytes32 digest = candidate.exchangeDigest(exchange, witnesses);
        bytes memory partyASig = _signature(PARTY_A_KEY, digest);
        bytes memory partyBSig = _signature(PARTY_B_KEY, digest);
        bytes[] memory witnessSigs = new bytes[](2);
        witnessSigs[0] = _signature(witnessKeyA, digest);
        witnessSigs[1] = _signature(witnessKeyB, digest);
        candidate.attestServiceExchange(
            exchange, witnesses, partyASig, partyBSig, witnessSigs
        );

        for (uint256 i; i < foundations.length; ++i) {
            require(foundations[i].codehash == beforeHashes[i], "foundation code changed");
        }
    }

    function _signature(uint256 key, bytes32 digest) private returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        return abi.encodePacked(r, s, v);
    }
}
