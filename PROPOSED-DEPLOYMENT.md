# Proposed Deployment Logic (PDL)

**RESEARCH ONLY — NOT DEPLOYED.**

The canonical candidate is [proposed_deployment.py](proposed_deployment.py). It currently contains a fail-closed research boundary, not an implemented messaging transport.

All future candidate changes must be evaluated against the engineering constitution, BSCA and ROT research standards. Tests must exercise the actual candidate rather than unrelated models; synthetic accounting alone cannot establish privacy. Publish reproducible results and limitations.

The CI workflow runs on pushes, pull requests, manual dispatch and a daily schedule. Passing CI is necessary but not sufficient for promotion.

## Conditional governance-gated deployment contract

A future PELAVIUM deployment authorization contract may accept an encryption release only after the designated NULLADIT governance contract has approved that exact release. Approval must bind to an immutable version and artifact digest, plus the target network, compatibility and migration information, and review record. The deployment contract records the approved release and its status; it must not accept an administrator-only bypass or treat a mutable branch, tag, or download URL as the approved artifact.

The contract cannot compile, host, or install software on nodes. A release pipeline must publish a signed artifact whose digest matches the approved record, and node software must verify both the artifact signature and governance authorization before accepting it. Node operators retain control over whether and when to install an authorized update. An approval authorizes a candidate; it does not establish security or force an installation. Emergency suspension, revocation, and rollback rules must be explicit, auditable, and governed.

Before any proposed NULLADIT adoption, identify an immutable commit and artifact digest, document compatibility and migration, obtain independent security review, and submit the exact revision through applicable NULLADIT governance. Approval must be independently verified in the production integration process; this public repository cannot grant itself deployment authority. No automatic promotion to NODSEL, no production credentials, and no mining or contract changes are authorized here.

A changed candidate requires fresh evidence and review. NODSEL documents actual deployed encryption only.
