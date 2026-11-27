# The Nonce Hypothesis

## A causal field model in which reality advances through local events rather than a universal clock

**PELAVIUM research publication | Apesoft Canada | 27 November 2026**

> **RESEARCH ONLY - NOT DEPLOYED.** This document presents a hypothesis and a
> reproducible internal-consistency experiment. It is not a proof, an accepted
> physical theory, or part of deployed NULLADIT encryption. For the designated
> production encryption reference, see
> [NODSEL](https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic).

![The Nonce Hypothesis](../assets/nonce-hypothesis-thumbnail.jpeg)

Physics gives us two extraordinarily successful descriptions of nature.
General relativity describes gravity as the geometry of spacetime. Quantum
mechanics describes physical systems through states, amplitudes and
probabilistic outcomes. Each succeeds within its domain, while their basic
pictures remain difficult to reconcile.

The Nonce Hypothesis begins with a different question:

**What if time is not a universal background through which reality moves, but
the measured rate at which causally permitted events become actual?**

In this picture the universe does not require one global clock or one agreed
sequence of distant events. Every region advances locally. Events are ordered
when one can causally influence another. Observable time emerges from local
updates and their synchronization.

The word *nonce* is borrowed from distributed computation, but the hypothesis
does not assert that the universe literally operates a blockchain. There are
no proposed cosmic miners, digital blocks or central ledger. The useful part
of the analogy is narrower: a changing local state governs event activity,
while causally connected observers can reconcile their records.

## The proposed nonce field

Let \(q(x)\) be a dimensionless scalar field defined at every point \(x\) in
spacetime. A first field equation is

$$
\Box_g q-\frac{1}{\ell^2}U'(q)
=-\frac{\beta}{M_{\mathrm P}^{2}}T.
$$

Here \(\Box_g\) is the covariant wave operator, \(U(q)\) is the potential,
\(\ell\) is a characteristic range, \(T\) is the trace of the matter
stress-energy tensor, \(\beta\) is a matter coupling, and \(M_{\mathrm P}\)
is the reduced Planck mass. Matter changes the field, disturbances propagate
through spacetime, and the potential tends to return the field toward an
equilibrium state.

This is a relativistic field ansatz. It presupposes a spacetime metric and does
not yet derive that geometry.

## From the field to an event rate

The hypothesis connects \(q\) to a positive local event intensity:

$$
\lambda(x)=\lambda_0 e^{\gamma q(x)}.
$$

The constant \(\lambda_0\) is a reference intensity and \(\gamma\) controls
the response. For \(|\gamma q|\ll1\),

$$
\lambda(x)\approx\lambda_0[1+\gamma q(x)].
$$

An event intensity is not automatically a clock reading. A physical clock is
made of matter, so a clock-shift prediction requires a specified coupling of
the field to atomic transitions and measuring devices.

## Causality replaces a universal ledger

Relativity forbids a universal ordering of all distant events. The hypothesis
therefore uses a causal partial order:

$$
e_i\prec e_j\quad\Longleftrightarrow\quad x_j\in J^+(x_i).
$$

Event \(e_i\) precedes event \(e_j\) when \(e_j\) lies in the causal future of
\(e_i\). Spacelike-separated events need not have an observer-independent
order. The invariant structure is the network of possible influence, rather
than a universal timestamp.

## Static point-source solution

For a stationary point mass \(M\), a weak background and
\(U(q)=q^2/2\), the static flat-space equation is

$$
\left(\nabla^2-\frac{1}{\ell^2}\right)q
=\frac{\beta M}{M_{\mathrm P}^{2}}\delta^3(\mathbf r).
$$

With the stated sign convention, its spherically symmetric solution is

$$
q(r)=-\frac{\beta M}{4\pi M_{\mathrm P}^{2}}
\frac{e^{-r/\ell}}{r}
=-2\beta\frac{GM}{r}e^{-r/\ell}.
$$

The corresponding intensity is

$$
\lambda(r)=\lambda_0\exp\left[-2\beta\gamma
\frac{GM}{r}e^{-r/\ell}\right],
$$

and its weak-field fractional change is

$$
\frac{\lambda(r)-\lambda_0}{\lambda_0}
\approx-2\beta\gamma\frac{GM}{r}e^{-r/\ell}.
$$

This toy model therefore predicts a screened inverse-distance change in event
intensity. The free parameters must be derived or constrained before this can
become a quantitative physical prediction.

## Reproducible computational check

The companion reference implementation ran ten independently seeded rounds
with 40,500,000 counted numerical cases in total. The campaign checked:

- field and intensity domains over randomized parameter values;
- \(d\ln\lambda/dq=\gamma\);
- Lorentz preservation of causal classifications;
- transitivity of future-directed causal relations;
- Poisson event counts generated from the stated intensity;
- the Yukawa radial equation away from the point source.

All ten recorded rounds passed the programmed tolerances. The largest absolute
Poisson deviation was about 1.48 standard deviations. Maximum numerical errors
are preserved in
[`validation_results.json`](../experiments/nonce_hypothesis/validation_results.json).
The source and reproduction command are in the
[`nonce_hypothesis` experiment](../experiments/nonce_hypothesis/README.md).

These results establish only that the reference implementation behaves
consistently with the equations inside the tested domains. Repeating a model's
assumptions cannot prove the assumptions. Physical evidence requires a
measurement capable of distinguishing the hypothesis from existing theories.

## A possible quantum extension

The classical field equation does not derive quantum mechanics. One possible
research direction assigns each causally admissible history \(\mathcal H\) a
complex amplitude

$$
\mathcal A[\mathcal H]=\exp\left(\frac{i}{\hbar}S[\mathcal H]\right),
$$

then sums over admissible histories:

$$
\mathcal K(A\rightarrow B)=
\sum_{\mathcal H:A\rightarrow B}\mathcal A[\mathcal H],
\qquad
P(A\rightarrow B)=|\mathcal K(A\rightarrow B)|^2.
$$

This is a proposed research route, not a derivation. A complete formulation
would have to specify the action, integration measure, measurement interaction
and limit in which established quantum field theory is recovered.

## Falsifiability and open work

The hypothesis becomes a physical theory only if it can:

1. explain or consistently couple to relativistic geometry;
2. recover established general-relativistic and quantum predictions in their
   tested limits;
3. specify how matter and clocks couple to \(q\);
4. derive or experimentally constrain \(\beta\), \(\gamma\) and \(\ell\);
5. predict a measurable departure from existing theories.

Candidate tests include deviations from inverse-square gravity, anomalous
transition-frequency shifts, composition-dependent effects if couplings are
not universal, and correlations in precision timing. Existing scalar-force,
equivalence-principle and clock experiments constrain any viable parameter
space and must be incorporated before a numerical experimental claim is made.

## The proposal in one statement

The Nonce Hypothesis proposes that matter influences a local physical state,
that state influences event intensity, events form a causal partial order, and
shared macroscopic history emerges as locally advancing systems exchange
information. Interference among admissible causal histories is a possible path
toward quantum behavior, but remains to be derived.

The analogy supplied the intuition. The equations define a testable toy model.
The computational experiment checks its implementation. Observation must
decide whether it describes nature.
