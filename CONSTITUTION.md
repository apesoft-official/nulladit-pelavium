# PELAVIUM — Engineering constitution

Maintain an explicit RESEARCH ONLY — NOT DEPLOYED disclaimer and link to NODSEL. Publish sanitized research, formal models, proofs with assumptions, reproducible experiments, benchmarks and limitations. Clearly label hypotheses versus verified results; never claim operational anonymity or quantum resistance without appropriate evidence. Use synthetic data and isolated experiments. Do not publish proprietary infrastructure, production secrets, real user traffic or confidential operational details. Handle exploitable production vulnerabilities through responsible disclosure. Every relevant research sweep must review public research updates; no automatic production adoption. Require independent review and separate deployment approval before any promotion to NODSEL.

All changes must preserve the repository's trust boundary and distinguish design intent from verified results.

## Equal, privacy-preserving access

A claimant who can prove control of the cryptographic capability bound to an intended recipient must not be charged directly by a node operator to submit or complete a legitimate recipient claim. Node operation and verified service should be funded separately through a transparent, governance-approved mechanism. If a production design imposes unavoidable network transaction costs, it must disclose them and investigate sponsorship or relaying; it must not describe a paid node gate as free access.

A suspicious request may receive a uniform, rate-limited cryptographic challenge. The challenge may ask for a nonce-bound signature or a privacy-preserving proof that the claimant controls the recipient capability. It must not require, solicit, or reward disclosure of legal identity, IP address, browser fingerprint, device identifiers, location, or other unrelated personal information. PELAVIUM must not retaliate against, expose, deanonymize, or secretly profile a claimant.

No message content, recipient identity, relationship, personal information, or raw challenge response belongs on a public ledger. A security challenge must not reveal whether a particular recipient or message exists. Any separate human reporting channel must be clearly optional, consent-based, purpose-limited, and governed by a stated retention and deletion policy. These are design requirements for research; they do not establish that a production implementation exists or has been reviewed.
