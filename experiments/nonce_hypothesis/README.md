# Nonce Hypothesis reference experiment

**RESEARCH ONLY - NOT DEPLOYED.** This experiment tests internal properties of
the mathematical toy model described in
[`research/NONCE-HYPOTHESIS.md`](../../research/NONCE-HYPOTHESIS.md). It does
not test whether nature uses the model and does not alter NULLADIT production
software.

## Reproduce the recorded campaign

Requires Python 3.10 or later and NumPy.

```bash
python -m pip install -r requirements.txt
python reference_model.py --n 1000000 --rounds 10 --seed 20261127 > validation_results.json
```

The recorded run counts 40,500,000 checks across four one-million-case test
families per round and 50,000 Yukawa residual cases per round. The JSON file
records seeds, aggregate counts, numerical errors and Poisson deviations.

## What is checked

- finite, positive event intensities over randomized parameters;
- the response identity `d ln(lambda) / dq = gamma`;
- preservation of causal classification under Lorentz boosts;
- transitivity of future-directed causal relations;
- Poisson counts drawn from the proposed event intensity;
- the screened point-source equation away from its singular source.

Passing these checks means that the implementation agrees with the stated
identities within its numerical tolerances. It is not experimental evidence
for the Nonce Hypothesis.
