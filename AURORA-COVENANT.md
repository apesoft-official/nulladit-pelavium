# AURORA COVENANT — research candidate

**RESEARCH ONLY — NOT DEPLOYED.** The Solidity source in [research/AuroraCovenant.sol](research/AuroraCovenant.sol) is a candidate release registry, not production authority.

It is designed to sit beneath and pin the original eight NULLADIT mainnet contracts. The registry binds a release record to an exact source revision, artifact digest, manifest digest and approval from the designated three-constituency election. It does not alter the founding contracts, execute upgrades, install software, force nodes to update, or establish that a release is safe.

Before any adoption, independently verify the eight addresses and interfaces, authenticate the election snapshot provider, compile and review with pinned tooling, and complete appropriate unit, invariant, adversarial and fork testing. Repository publication is not a governance vote. Any production promotion remains subject to NULLADIT's applicable constitutional process and separate approval. NODSEL alone documents actual deployed encryption source and provenance.


A runtime code hash pins only the proxy shell if a founding address is a proxy. The current candidate does not pin implementation or beacon state; independently identify and verify any upgrade paths before considering deployment.
