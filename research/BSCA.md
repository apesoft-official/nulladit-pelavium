# Bidirectional Stochastic Cover Activity (BSCA)

RESEARCH ONLY — NOT DEPLOYED.

Research hypothesis: synthetic submission and synthetic discovery may reduce the information disclosed by observable communication events. A running client, not a wallet itself, performs network activity. Offline devices cannot independently participate.

## Evaluation requirements
Measure submission and discovery leakage separately and jointly. Compare against a prior-only classifier, accounting for class imbalance. Report uncertainty intervals, assumptions, bandwidth, storage, battery and latency costs. Include negative results and offline participation limitations. A chance-level result in a simulation is not a proof of indistinguishability against real adversaries.

## Scope
Use synthetic datasets and isolated experiments only. No live wallet integration, production network traffic, mining rewards, or deployment. Do not claim statistical impossibility without a formal model and proof. Production encryption remains separately documented in NODSEL.

## Initial executable research
The accompanying offline accounting model measures hypothetical traffic costs and prior-only classification baselines. It does not implement a network protocol or establish privacy properties.
