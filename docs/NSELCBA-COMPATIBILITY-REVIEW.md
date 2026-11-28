# NSELCBA constitutional compatibility review

**RESEARCH ONLY — NOT DEPLOYED.** This is a source-level design review, not an
independent security audit, legal opinion, deployment approval, or proof that a
barter exchange is enforceable. The current candidate is a research proposal
for a bilateral signed exchange record with unanimity among an explicit witness
snapshot. No production deployment or signing is authorized by this document.

## Signature design

Both exchange parties and every address in the supplied witness roster must
sign one EIP-712 digest. The digest binds the parties, service category, stated
NULL22 quantity, agreed CAD-micros value, exact terms hash, expiry, chain ID,
opaque evidence commitment, witness-roster hash, and verifying contract. EIP-712
domain separation uses the contract name, version, chain ID, and contract
address. EOA signatures are checked with low-`s` ECDSA recovery; contract-wallet
signatures use ERC-1271 validation. Any relayer may submit the signed bundle.

The roster is explicit, sorted, unique, and jointly included in the digest. The
contract verifies every listed address, but has no authoritative node registry
and cannot establish that the list includes every NULLADIT node. Therefore this
candidate enforces unanimity **within the signed snapshot only**. A later design
claiming unanimity across the network needs a governance-approved, current,
independently auditable definition of eligible nodes. An omitted node prevents
the record from proving network-wide unanimity.

The contract stores the signed statements and witness roster. It does not
transfer NULL22, prove that service was performed, verify token payment,
establish the CAD value as fair market value, establish the parties' legal
identities, or determine whether NULL22 or the exchange is a security, barter,
legal tender, or taxable in a particular way. The project constitution's
representation limits remain in force. See [EIP-712](https://eips.ethereum.org/EIPS/eip-712)
and [ERC-1271](https://eips.ethereum.org/EIPS/eip-1271).

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
mining, force an update, or satisfy Aurora's independent-review and governance
gates. The historical foundation-address list in the fork test is a compatibility
fixture, not current proof of governance eligibility or authority to sign. Any
later production proposal needs fresh address verification, the exact artifact
and manifest, independent review, and applicable constitutional approval.

## Constitutional checks

1. **Research boundary:** source and tests remain in `research/`; this candidate
   is not deployed or approved.
2. **Specific assent:** the two parties sign the same typed exchange terms;
   every witness named in the supplied snapshot signs the same digest.
3. **Snapshot limitation:** the contract cannot prove that the supplied roster
   is a complete network roster.
4. **No paid access gate:** the contract never gates recipient claims or
   messaging access.
5. **Data minimization:** only an opaque evidence commitment and public
   transaction terms are recorded; message content and personal data are out
   of scope.
6. **Wallet meaning:** a signature proves cryptographic control or contract-
   wallet validation for that digest. It does not prove human identity,
   verified-node status, legal capacity, or benign intent.
7. **No legal classification claim:** the title is not a determination that
   NULL22 is or is not a security, or that the exchange qualifies as barter.
8. **No valuation override:** CAD micros record the signers' agreed value at
   1,000,000 units per CAD dollar; they do not make a statutory or tax valuation
   finding.
9. **No asset transfer:** the contract logs signed statements; it does not
   transfer NULL22 or prove delivery or payment.
10. **No governance or deployment authority:** the candidate has no owner,
    administrator, upgrade, mint, pause, or governance method.

## Verification status and limits

The revised source compiled with Solidity 0.8.24 through Foundry. Its 18 unit
tests passed, including the party and witness unanimity paths, wrong-chain,
expiry, duplicate/missing signer, malformed signature, and replay rejections.
The separate ZKsync Era mainnet-fork compatibility test passed against a live
read-only fork. That test confirms the listed foundation runtime code remained
unchanged during the local-fork exercise; it does not validate live governance,
wallet authority, or production eligibility.

A native EraVM artifact for this revision has **not** been produced. The checked-
in 6,368-byte EraVM artifact is from the earlier source and is superseded; it
must not be used for deployment or signing. The standard Solidity EVM artifact
is not a substitute for a native EraVM build or deployment review. Independent
security review, a reproducible native EraVM build, current foundation/address
verification, and applicable constitutional approval remain open gates.

Passing tests and a fork check are evidence for reviewers, not approval to
deploy. The founding-wallet snapshot is historical and production authorization
remains false. This document requests review; it does not claim or create
independent security approval or constitutional approval. No deployment or live
transaction signing is authorized.
