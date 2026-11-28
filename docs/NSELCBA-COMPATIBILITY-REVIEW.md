# NSELCBA constitutional compatibility review

**RESEARCH ONLY — NOT DEPLOYED.** This is a design and source review, not an
independent audit, legal opinion, fork test, or deployment approval. The
contract adds an operator opt-in and a public receipt of the operator's own
statement. It makes no external calls and grants no authority over other
contracts. It neither validates proof-of-service nor transfers NULL22.

The phrase “eight constitutions” is interpreted here as the eight founding
contracts protected by the NULLADIT constitution. The review maps the candidate
against their published roles and the Aurora Covenant boundary.

| Founding contract | Candidate interaction | Compatibility result |
| --- | --- | --- |
| NULL22 Token | Address is identified as a constant; no token call or transfer | No token state or allowance changes |
| NULL22 Authority | None | No authority, owner, or admin interface |
| NULL22 Controller | None | No mining or issuance control |
| NVSP Registration Pricing | None | No registration fee or pricing change |
| NVSP Mining Registration V3 | None | No registration or mining call |
| NVSP Settlement Adapter V3 | None | No settlement or bond call |
| NVSP Epoch Anchor | None | No epoch or reward schedule change |
| NVSP Adjudication Governance | None | No vote, approval, appeal, or governance call |

## Aurora Covenant

The candidate does not import, call, inherit from, or modify Aurora Covenant.
It cannot record or approve a release, alter a pinned foundation, activate
mining, force an update, or satisfy Aurora's independent review and governance
gates. It can be considered as a separate research candidate only. Any later
addition to an Aurora deployment graph requires a new exact artifact and
manifest, independent review, and the applicable governance approval.

## Constitutional checks

1. **Research boundary:** source and tests remain in `research/`; not deployed.
2. **Voluntary participation:** a wallet must explicitly accept before it can
   attest a service exchange; it can revoke future participation.
3. **No paid access gate:** the contract never gates recipient claims or
   messaging access.
4. **Data minimization:** only an opaque evidence commitment is recorded; the
   contract warns against submitting personal or message data.
5. **Wallet meaning:** a wallet signature is not treated as proof of human
   identity, node verification, legal status, or benign intent.
6. **No legal classification claim:** the title is not a determination that
   NULL22 is or is not a security or that a particular exchange qualifies as
   barter.
7. **No valuation override:** recorded CAD micros are the operator-entered
   agreed service value (1,000,000 units per CAD dollar), not a statutory or
   tax valuation finding.
8. **No governance or deployment authority:** the candidate has no owner,
   administrator, upgrade, mint, pause, or governance method.

## Verification limits

The Foundry tests compile with Solidity 0.8.24. Twelve isolated tests exercise
opt-in, revocation, validation, replay protection, and stored receipts. A
separate ZKsync Era mainnet-fork smoke test passed at block 73,133,547: it
confirmed code at the eight foundation addresses and Aurora address, submitted
one synthetic attestation to the local fork, and confirmed all nine runtime
code hashes were unchanged. This does not inspect their storage or test their
internal interfaces; the candidate does not call them. It is not a security
audit. Before any production proposal, independently verify the addresses and
proxy paths and obtain the applicable independent review and governance
approval.

The candidate also compiled to native EraVM bytecode with the ZKsync fork of
solc 0.8.24-1.0.2 and zksolc 1.5.15 (Yul codegen, optimization level 2, IPFS
metadata). The checked-in research artifact is 6,368 bytes and includes the
ABI and deployment bytecode. It is tied to the source SHA-256 recorded in that
artifact; any source change requires a fresh build. Compilation does not mean
the candidate is approved or deployed.
