# Aurora Covenant and Vestigium — deployment bulletin

27 November 2026 · ZKsync Era · chain 324

The operator-supplied mainnet receipt reports success (0x1), block 73129641, 58 events, root 0x3f9b8a59d9ab9841e5aa6244e1fc4bd6404789b5.
Transaction: https://explorer.zksync.io/tx/0x813c74d4058a8bd58b39472d0a088e3262aae7ed97c191f2cbb655447507b2d6

The founding suite comprises 29 identified contracts: eight original contracts, wallet whitelist, and twenty contracts in the atomic Aurora graph. The root is receipt-supported; nineteen child addresses below are rehearsal-derived and must not be treated as verified production endpoints.

## Existing manifest addresses
- NULL22Authority: 0xEDbE3eF68315F9De399Cb77f0243C5a20e11305C
- NULL22Controller: 0x4bd6776a16cC838D4A92C16FB3B0bc32330E3427
- NULL22Token: 0x332a8e2CeE5398D52616fCABd87966010C5A7a82
- NVSPRegistrationPricing: 0xdEbbc5932516c6FC083b2F2B8aAd823402f148B5
- NVSPMiningRegistrationV3: 0x4A1e5037397837fFD7Bd59865A3a0dCD06386E15
- NVSPBondSettlementAdapterV3: 0x78E84F3649976fc418a9aD53Bb0e4063AfB47af2
- NVSPEpochAnchor: 0xaC4179803BeDbEe923BDF4b82eC147cF82f7B9D8
- NVSPAdjudicationGovernance: 0x978eD18f0a017b06d4F0C02EB11D4C540D3c5c06
- NULLADITWalletWhitelist: 0xcECc869b43f59c951F61cE70DbE11d6Eb3EeeCAF

## New graph
- NVSPAtomicFoundingDeployment: 0x3f9b8a59d9ab9841e5aa6244e1fc4bd6404789b5 (receipt-supported)
- NVSPEpochEvidenceCandidate: 0xB8f17Ad2F140B2871ea838F020F7D2f337b1A155
- NVSPElectionSnapshotCandidate: 0x912ee4C8Af4e7B3501bD587fEC48f108b5a55627
- NVSPWitnessActivation: 0xC853385C53D3f271bc106Bea8A853C3e922E854D
- NVSPThreeWayElection: 0x88d086c32e44044fbAb3dB2a4935adF6D2500881
- AuroraCovenant: 0x738Ebf0d99D2a0c92d7A667b825ae8aa771E9e4e
- Vestigium: 0x49a6DE9673b52499FfF9466731E1Bf77dF58ce1F
- NVSPProofUpgradeGovernor: 0x67869A01F251a4188009Ab30dB552139B0832032
- NVSPBondSettlementAdapterV4Candidate: 0xfeEF8c6170cc8f86966a44b01E1Ce3a47A109cA9
- NULL22SecurityBondV4: 0x7d5FfE2c428401d7b16d0894C8947875105934Aa
- Seats 0–4 (initial): 0x558D4A8E06Bc8015713b59045C1E74aa164232A4, 0xf7B9EADF5b0b023d93aaEd6849481f1dcac328F4, 0x0cE57Cf321340d763dc6dde0e1A977f1e9b52717, 0x699e7071B721fA82aD60C488289fC5698727f5a3, 0x156404aBd52A2F025eF603d1293B4F26a0803f0f
- Seats 5–9 (appeal): 0xa58F7b730fa1fe4a31061c3dbc2da17182d881B5, 0xf6329d7cbD81aaa03D927B0fccFD1c4947433A53, 0xe54155D1E996975B8Ca247fdE196a5012f434Ae4, 0x71A6E53d9C0498488aE5A3b59099670A3D9111E1, 0x0cdA4d5B04F538246817A02EBCE6F06650e432AA

Aurora pins founding integrity and governs release approvals; Vestigium provides accountability commitments without publishing private conversations. Evidence and snapshot candidates bootstrap attestation; witness activation scales thresholds; elections separate three constituencies; governor manages proof upgrades; adapters and bond contracts govern settlement and disputes. Seats are not yet independently staffed.

Engineering record: six CI runs passed; native compilation Solidity 0.8.24/zksolc 1.5.15; mainnet fork rehearsal at block 73129187 matched 20/20 runtime bytecodes and tested rollback, foundation integrity, inactive Vestigium and paused mining. These are rehearsal results, not independent mainnet certification. Owner authorization and wallet signature were recorded; independent audit and formal constitutional approval remain unverified. Founding attesters are commonly controlled. No mining or production activation authorized. Immediate priority: controlled independent-node encrypted messaging tests without rewards. Pelavium remains experimental research, not activated cryptography.

This bulletin is informational, not a production registry or authorization to change endpoints.
