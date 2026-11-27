# Cryptographic compromise threat model

RESEARCH ONLY — NOT DEPLOYED.

PELAVIUM must evaluate privacy claims under explicit confidentiality failure assumptions. Distinguish passive metadata observation, envelope plaintext disclosure, relationship disclosure, key compromise and endpoint compromise. These are separate threat models, not interchangeable assumptions.

The research hypothesis is that metadata observations may disclose less information than conventional messaging observations. No claim of statistical meaninglessness or chance-only inference is established.

Plaintext can directly disclose identities, relationships and intent. Synthetic traffic cannot erase information already disclosed. Full endpoint compromise may expose genuine activity directly. These are fundamental limitations and must appear in research conclusions.

Require reproducible synthetic-data evaluations, explicit priors, uncertainty intervals, longitudinal evaluation and publication of negative results. No deployment or production integration is authorized by this research standard.
