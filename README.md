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

## Scientific discipline
Label hypotheses, formal proofs, simulations and empirical results separately. Publish assumptions, methods, synthetic datasets and negative results. A simulation is not a proof; a proof under a model is not a guarantee of operational anonymity. No production adoption is implied by publication.

All contributions follow the [engineering constitution](CONSTITUTION.md).

## The architecture of trust
Privacy is not a privilege conferred by an intermediary. NULLADIT seeks to make confidential communication an architectural property rather than a promise of institutional discretion. Independent operation, verifiable cryptography and interoperable clients are complementary goals, not substitutes for security review. No system is invulnerable; claims must follow evidence.

| Project | Responsibility |
| --- | --- |
| NULLADIT Core | Proprietary protocol and node operations; private repository |
| [NOMC](https://github.com/apesoft-official/nulladit-opensource-messenger-client) | Public messenger clients, device installers and independent web/app builds |
| [NODSEL](https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic) | Public transparency for actual deployed encryption revisions |
| [PELAVIUM](https://github.com/apesoft-official/nulladit-pelavium) | Experimental privacy research, not deployed |

Developed by **Apesoft Canada** · **Inviolable Conversations**
