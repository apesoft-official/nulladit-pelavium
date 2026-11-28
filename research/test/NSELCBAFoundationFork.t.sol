// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "../NSELCBA.sol";

/// @dev Run with: forge test --fork-url https://mainnet.era.zksync.io
///      This is a read-only compatibility smoke test, not a security audit.
contract NSELCBAFoundationForkTest {
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
        candidate.acceptTerms();
        candidate.attestServiceExchange(
            NSELCBA.ServiceCategory.Delivery,
            keccak256("synthetic fork-only evidence"),
            1 ether,
            1_000_000
        );

        for (uint256 i; i < foundations.length; ++i) {
            require(foundations[i].codehash == beforeHashes[i], "foundation code changed");
        }
    }
}
