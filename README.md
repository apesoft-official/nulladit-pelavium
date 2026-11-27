# PELAVIUM

**pel-AY-vium · Experimental cryptographic privacy research**

**RESEARCH ONLY — NOT DEPLOYED.** For the designated production encryption reference, see [NODSEL](https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic).

Encryption protects message contents, but communication patterns can reveal relationships. PELAVIUM investigates whether encrypted relationship envelopes, pooled traffic and synthetic cover traffic can reduce the information available to observers. Its conceptual inspiration includes cryptocurrency privacy pools and the phenomenon of snow blindness: meaningful signals become harder to distinguish amid abundant unrelated activity. This is a metaphor, not a security proof.

## Research programme
- Hybrid elliptic-curve and lattice-based cryptography; explicit classical and quantum threat models.
- Encrypted relationship envelopes and recipient retrieval privacy.
- Traffic pools, synthetic traffic, bandwidth limits and economic sustainability.
- Formal models, proofs where established, reproducible experiments, benchmarks and adversarial simulations.
- Limitations including timing correlation, active adversaries, collusion, traffic scarcity and endpoint compromise.

## Canonical research candidate

The [Proposed Deployment Logic](PROPOSED-DEPLOYMENT.md) defines the public candidate lifecycle. The [candidate source](proposed_deployment.py) is currently a fail-closed scaffold, not a functional transport. See the [BSCA constitution](research/BSCA-CONSTITUTION.md), [ROT introduction](research/ROT/README.md), and [cryptographic compromise threat model](research/CRYPTOGRAPHIC-COMPROMISE.md). Automated tests are configured in the [research workflow](.github/workflows/proposed-deployment.yml); passing tests do not authorize deployment.

## Scientific discipline
Label hypotheses, formal proofs, simulations and empirical results separately. Publish assumptions, methods, synthetic datasets and negative results. A simulation is not a proof; a proof under a model is not a guarantee of operational anonymity. No production adoption is implied by publication.

## The Nonce Hypothesis

[The Nonce Hypothesis](research/NONCE-HYPOTHESIS.md) presents a causal scalar-field model of local event intensity, causal partial ordering, a screened point-source solution and a reproducible numerical consistency campaign. It is research only: the recorded simulations test the implementation of the stated equations, not whether nature uses the model.


All contributions follow the [engineering constitution](CONSTITUTION.md).

## The architecture of trust
Privacy is not a privilege conferred by an intermediary. NULLADIT seeks to make confidential communication an architectural property rather than a promise of institutional discretion. Independent operation, verifiable cryptography and interoperable clients are complementary goals, not substitutes for security review. No system is invulnerable; claims must follow evidence.

| Project | Responsibility |
| --- | --- |
| NULLADIT Core | Proprietary protocol and node operations; private repository |
| [NOMC](https://github.com/apesoft-official/nulladit-opensource-messenger-client) | Public messenger clients, device installers and independent web/app builds |
| [NODSEL](https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic) | Public transparency for actual deployed encryption revisions |
| [PELAVIUM](https://github.com/apesoft-official/nulladit-pelavium) | Experimental privacy research, not deployed |


See [AURORA-COVENANT.md](AURORA-COVENANT.md) for the research-only registry proposal and production gates.

Developed by **Apesoft Canada** · **Inviolable Conversations**

## Cryptography Evidence Lab

[Open tester source](tester/index.html) or download the standalone HTML and serve locally (HTTPS or localhost for Web Crypto). Evidence maturity rankings are not security scores. The local AES-GCM sanity checks do not test deployed NULLADIT; the NODSEL source-to-release mapping remains unverified. No wallet, personal data or smart contract required.


## Constitutional accountability

[VESTIGIUM](VESTIGIUM.md) is a proposed accountability protocol for privacy-preserving delivery evidence. Its research contract stores opaque batch commitments only; it does not reveal message contents or grant access to protected data. The current candidate is not deployed and is not a production dependency.

## VESTIGIUM — Evidence without surveillance

Read the [Doctrine of Evidentiary Restraint](VESTIGIUM-PHILOSOPHY.md). **Prove the violation, not the conversation.** VESTIGIUM is a proposed accountability doctrine, not a deployed surveillance or access mechanism.
