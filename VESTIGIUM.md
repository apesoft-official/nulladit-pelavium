# VESTIGIUM

**Constitutional Delivery Accountability Protocol**  
Apesoft Canada · NULLADIT · PELAVIUM

**Pronunciation:** ves-TIJ-ee-um  
**Meaning:** Latin *vestigium* — a footprint, trace, or evidence left behind.

## Constitutional purpose

**Responsibility follows conduct, not association.** No participant inherits responsibility merely because a message passed through independently operated infrastructure. Accountability must distinguish proven misconduct from suspicion, technical failure, ordinary network activity, and innocent participation.

## Presumption of Digital Inviolability

Apesoft Canada shall possess no inherent contractual entitlement to access, decrypt, reconstruct, inspect or demand disclosure of a user's protected communications, private relationships, cryptographic secrets or vulnerable personal information.

Participation in NULLADIT shall not constitute consent to surveillance.

An exceptional claim for narrowly restricted access may arise only where:

1. A demonstrable violation of PELAVIUM's security or integrity requirements has occurred.
2. VESTIGIUM has recorded independently verifiable cryptographic evidence attributable to the responsible participant.
3. That evidence has undergone independent review and cannot reasonably be explained by ordinary network activity, technical failure or innocent participation.
4. The proposed access is necessary, proportionate and independently lawful.

Suspicion alone shall never constitute authorization. Nor shall a violation extinguish a participant's general right to privacy.

Apesoft Canada shall not introduce a backdoor, universal decryption key or privileged surveillance mechanism to facilitate such access.

The burden of establishing justification shall remain with the party seeking access, never with the participant seeking privacy.

## On-chain boundary

The current Solidity candidate anchors only an opaque batch root and monotonically increasing epoch. It does not store message content, sender or recipient identity, relationships, IP addresses, browser fingerprints, cryptographic secrets, or raw evidence. It contains no method to decrypt, inspect, reconstruct, or grant access to protected data.

A batch root is a tamper-evident commitment, not proof that an individual committed misconduct. The current candidate does not yet verify individual delivery receipts, authenticate a security violation, or decide whether an access request is lawful. Any future evidence review must be independent, purpose-limited, and conducted off-chain under a separately lawful process. No root or governance vote can create a decryption capability.

## Aurora Covenant integration

The private candidate deployment graph now includes Vestigium alongside Aurora Covenant. Vestigium remains inactive until Aurora records the exact instance configuration under the required governance approval. This is source-level integration only: the graph, evidence scheme, snapshot provider, implementation interfaces, compilation, review, and tests remain deployment gates. Repository publication does not authorize deployment.

## Status and limits

**PROPOSED — RESEARCH ONLY — NOT DEPLOYED.** This specification states a proposed constitutional commitment; it does not by itself amend an executed contract or settle what applicable law requires. It makes no claim of trademark registration or clearance. See [the Solidity candidate](research/Vestigium.sol), [Aurora Covenant status](AURORA-COVENANT.md), and [the PELAVIUM constitution](CONSTITUTION.md).
