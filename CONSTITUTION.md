# PELAVIUM — Engineering constitution

Maintain an explicit RESEARCH ONLY — NOT DEPLOYED disclaimer and link to NODSEL. Publish sanitized research, formal models, proofs with assumptions, reproducible experiments, benchmarks and limitations. Clearly label hypotheses versus verified results; never claim operational anonymity or quantum resistance without appropriate evidence. Use synthetic data and isolated experiments. Do not publish proprietary infrastructure, production secrets, real user traffic or confidential operational details. Handle exploitable production vulnerabilities through responsible disclosure. Every relevant research sweep must review public research updates; no automatic production adoption. Require independent review and separate deployment approval before any promotion to NODSEL.

All changes must preserve the repository's trust boundary and distinguish design intent from verified results.

## Equal, privacy-preserving access

A claimant who can prove control of the cryptographic capability bound to an intended recipient must not be charged directly by a node operator to submit or complete a legitimate recipient claim. Node operation and verified service should be funded separately through a transparent, governance-approved mechanism. If a production design imposes unavoidable network transaction costs, it must disclose them and investigate sponsorship or relaying; it must not describe a paid node gate as free access.

A suspicious request may receive a uniform, rate-limited cryptographic challenge. The challenge may ask for a nonce-bound signature or a privacy-preserving proof that the claimant controls the recipient capability. It must not require, solicit, or reward disclosure of legal identity, IP address, browser fingerprint, device identifiers, location, or other unrelated personal information. PELAVIUM must not retaliate against, expose, deanonymize, or secretly profile a claimant.

No message content, recipient identity, relationship, personal information, or raw challenge response belongs on a public ledger. A security challenge must not reveal whether a particular recipient or message exists. Any separate human reporting channel must be clearly optional, consent-based, purpose-limited, and governed by a stated retention and deletion policy. These are design requirements for research; they do not establish that a production implementation exists or has been reviewed.


## Aurora Covenant constitutional boundary
The original eight NULLADIT contracts remain the constitutional base. Aurora Covenant is a research-only, subordinate release registry proposal. It may record a release only after approval of the exact action through the designated governance process; it cannot modify, administer, or override the founding contracts, activate mining, or compel a node to install an update. Repository publication, CI, and research results are not deployment approval. Independent security review and separate constitutional approval are required before production adoption.


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

This is a proposed constitutional requirement, not a grant of technical access. VESTIGIUM's current candidate only anchors opaque batch roots; it does not collect evidence, adjudicate violations, decrypt data, or authorize access. No message content, identity, relationship, IP address, browser fingerprint, key, or raw evidence may be placed on-chain.


## Wallet authentication and pool-observation boundary

Proof of control of a wallet establishes control of a cryptographic account only. It does not establish human identity, benign intent, verified-node status, governance eligibility, or authority to inspect NULLADIT network state.

An ordinary messaging account shall never receive unrestricted ability to enumerate, observe, or query the message or envelope pool. It may request only recipient-scoped results through short-lived, purpose-bound capabilities or equivalent privacy-preserving selectors. A response must not reveal whether an unrelated recipient, message, or relationship exists. Padding, batching, cover traffic, and blinded lookup mechanisms should be used where compatible with the approved protocol.

Pool-wide or operational observation shall be limited to verified nodes and only to the minimum scope required for routing, storage, delivery, or independently authorized security work. Every protected-data request must be authenticated, purpose-scoped, rate-limited, replay-resistant, and capable of producing independently verifiable audit evidence. Creating or rotating to a new wallet does not exempt a requester from these controls.

VESTIGIUM may anchor an opaque commitment to evidence of a signed request, including its network domain, requesting wallet or authorized node key, request nonce, request class, bounded time reference, and policy or result code. It shall not place message content, recipient identity, communication relationships, legal identity, IP address, browser fingerprint, device identifier, location, raw challenge response, or raw evidence on a public ledger. A commitment proves that evidence was submitted under a cryptographic key; it does not prove the human identity or malicious intent of the key's controller. Adverse action requires independent review and must account for ordinary activity, compromise, error, and innocent participation.

Sybil resistance may use transparent, governance-approved registration rules, uniform privacy-preserving rate limits, or capability probation. It shall not convert a legitimate recipient claim into a node-imposed payment gate, identity-disclosure requirement, or surveillance mechanism. A verified node remains subject to least privilege because legitimate access to some traffic does not authorize observation of unrelated traffic.

This article interprets and supplements the existing Presumption of Digital Inviolability and equal-access requirements. It grants no decryption power, administrative privilege, mining authority, governance vote, contract authority, or deployment approval, and it does not modify or override the original eight founding contracts. Documentation alone does not implement these controls; enforceable claims require compatible protocol, node, and client behavior supported by reviewable evidence.

## NULL22 representation and node-reward boundary

Apesoft shall not market or describe NULL22 as legal tender, government-issued money, an investment, a security, a deposit, guaranteed store of value, or promise of profit or appreciation. This rule governs project representations and does not determine legal classification or create a regulatory exemption.

Reward-eligible Proof-of-Service participation is voluntary. An operator choosing to participate must expressly accept the applicable NULL22-denominated reward terms. The intended service-for-token arrangement may be described as barter-like or non-cash consideration, but repository text and proof receipts do not determine legal or tax treatment. Agreed reward quantities do not displace legally required valuation, tax, securities, or other obligations. Electricity and bandwidth costs may inform an operator's decision whether to participate; they do not themselves establish token value, fair market value, or legal adequacy.

See [TOKEN-REPRESENTATION-AND-NODE-REWARDS.md](TOKEN-REPRESENTATION-AND-NODE-REWARDS.md) for the full policy and official CRA/CSA references. This documentation does not amend deployed contracts or existing node agreements and does not prove operator assent.
