# Proposed Deployment Logic (PDL)

**RESEARCH ONLY — NOT DEPLOYED.**

The canonical candidate is [proposed_deployment.py](proposed_deployment.py). It currently contains a fail-closed research boundary, not an implemented messaging transport.

All future candidate changes must be evaluated against the engineering constitution, BSCA and ROT research standards. Tests must exercise the actual candidate rather than unrelated models; synthetic accounting alone cannot establish privacy. Publish reproducible results and limitations.

The CI workflow runs on pushes, pull requests, manual dispatch and a daily schedule. Passing CI is necessary but not sufficient for promotion.

Before any proposed NULLADIT adoption, identify an immutable commit and artifact digest, document compatibility and migration, obtain independent security review, and submit the exact revision through applicable NULLADIT governance. Approval must be independently verified in the production integration process; this public repository cannot grant itself deployment authority. No automatic promotion to NODSEL, no production credentials, and no mining or contract changes are authorized here.

A changed candidate requires fresh evidence and review. NODSEL documents actual deployed encryption only.
