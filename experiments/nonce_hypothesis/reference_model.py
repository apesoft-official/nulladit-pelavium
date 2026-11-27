"""Reference implementation of the screened nonce-field toy model.

Natural units are used. The model is phenomenological; this program checks
its stated algebra and numerical invariants, not whether nature uses it.
"""
from __future__ import annotations
import argparse
import json
import math
import numpy as np


def yukawa_q(r, beta, gm, ell):
    """Static point-source field q(r) = -2 beta GM exp(-r/ell) / r."""
    r = np.asarray(r, dtype=np.float64)
    if np.any(np.asarray(ell) <= 0) or np.any(r <= 0):
        raise ValueError("ell and r must be positive")
    return -2.0 * beta * gm * np.exp(-r / ell) / r


def event_intensity(q, gamma, gamma0=1.0):
    """Positive scalar event intensity per invariant four-volume."""
    if gamma0 <= 0:
        raise ValueError("gamma0 must be positive")
    return gamma0 * np.exp(gamma * np.asarray(q, dtype=np.float64))


def causal_future(dt, dr2, atol=0.0):
    """Minkowski (-,+,+,+) future-causal test for coordinate differences."""
    dt = np.asarray(dt, dtype=np.float64)
    dr2 = np.asarray(dr2, dtype=np.float64)
    return (dt > 0.0) & (dt * dt + atol >= dr2)


def boost_x(events, velocity):
    """Apply an active Lorentz boost to events [t,x,y,z]."""
    events = np.asarray(events, dtype=np.float64)
    if not -1.0 < velocity < 1.0:
        raise ValueError("boost speed must satisfy |v| < 1")
    g = 1.0 / math.sqrt(1.0 - velocity * velocity)
    out = events.copy()
    t, x = events[..., 0], events[..., 1]
    out[..., 0] = g * (t - velocity * x)
    out[..., 1] = g * (x - velocity * t)
    return out


def _causal_from_events(a, b):
    d = b - a
    return causal_future(d[..., 0], np.sum(d[..., 1:] ** 2, axis=-1))


def run_validation(n=1_000_000, seed=20261127):
    rng = np.random.default_rng(seed)

    # 1. Randomized field and intensity domain checks.
    r = rng.uniform(0.03, 30.0, n)
    beta = rng.uniform(0.0, 0.8, n)
    gm = rng.uniform(1e-4, 0.2, n)
    ell = np.exp(rng.uniform(math.log(0.05), math.log(50.0), n))
    gamma = rng.uniform(0.0, 2.0, n)
    q = yukawa_q(r, beta, gm, ell)
    lam = event_intensity(q, gamma)
    assert np.isfinite(q).all() and np.isfinite(lam).all()
    assert (q <= 1e-15).all() and (lam > 0.0).all()

    # Check the analytic response slope d ln(lambda)/dq = gamma numerically.
    eps = 1e-6
    slope = (np.log(event_intensity(q + eps, gamma)) -
             np.log(event_intensity(q - eps, gamma))) / (2.0 * eps)
    slope_err = float(np.max(np.abs(slope - gamma)))
    assert slope_err < 2e-8

    # 2. Lorentz invariance of timelike/null/spacelike classification.
    a = rng.normal(size=(n, 4))
    d = rng.normal(size=(n, 4))
    b = a + d
    v = rng.uniform(-0.95, 0.95, n)
    before = _causal_from_events(a, b)
    after = np.empty(n, dtype=bool)
    # Vectorize boosts with per-row velocities.
    gg = 1.0 / np.sqrt(1.0 - v * v)
    ap = a.copy(); bp = b.copy()
    ap[:, 0] = gg * (a[:, 0] - v * a[:, 1])
    ap[:, 1] = gg * (a[:, 1] - v * a[:, 0])
    bp[:, 0] = gg * (b[:, 0] - v * b[:, 1])
    bp[:, 1] = gg * (b[:, 1] - v * b[:, 0])
    after[:] = _causal_from_events(ap, bp)
    # Also compare the invariant interval numerically.
    s0 = d[:, 0] ** 2 - np.sum(d[:, 1:] ** 2, axis=1)
    dp = bp - ap
    s1 = dp[:, 0] ** 2 - np.sum(dp[:, 1:] ** 2, axis=1)
    interval_err = float(np.max(np.abs(s0 - s1)))
    assert np.array_equal(before, after)
    assert interval_err < 2e-10

    # 3. Transitivity: sums of future-directed causal vectors remain causal.
    v1 = rng.normal(size=(n, 3))
    v2 = rng.normal(size=(n, 3))
    # Pick times at least as large as spatial lengths, with strict margin.
    d1 = np.column_stack((np.linalg.norm(v1, axis=1) + rng.uniform(0.01, 1.0, n), v1))
    d2 = np.column_stack((np.linalg.norm(v2, axis=1) + rng.uniform(0.01, 1.0, n), v2))
    assert causal_future(d1[:, 0], np.sum(d1[:, 1:] ** 2, axis=1)).all()
    assert causal_future(d2[:, 0], np.sum(d2[:, 1:] ** 2, axis=1)).all()
    d12 = d1 + d2
    assert causal_future(d12[:, 0], np.sum(d12[:, 1:] ** 2, axis=1)).all()

    # 4. Poisson event-count calibration across a million independent cells.
    # Each cell has unit invariant 4-volume in normalized units.
    expected = event_intensity(q, gamma, gamma0=0.4)
    observed = rng.poisson(expected)
    sum_expected = float(expected.sum())
    sum_observed = int(observed.sum())
    z = (sum_observed - sum_expected) / math.sqrt(sum_expected)
    assert abs(z) < 7.0

    # 5. Check static Yukawa radial equation away from the point source.
    # Analytic identity: (d²/dr² + 2/r d/dr) (e^-r/l/r) = e^-r/l/(l²r).
    rr = np.exp(rng.uniform(math.log(0.02), math.log(50.0), 50_000))
    ll = np.exp(rng.uniform(math.log(0.05), math.log(50.0), 50_000))
    aa = rng.uniform(0.01, 2.0, 50_000)
    f = aa * np.exp(-rr / ll) / rr
    fp = f * (-1.0 / ll - 1.0 / rr)
    fpp = f * (1.0 / (ll * ll) + 2.0 / (ll * rr) + 2.0 / (rr * rr))
    residual = fpp + 2.0 * fp / rr - f / (ll * ll)
    residual_rel = float(np.max(np.abs(residual) / np.maximum(np.abs(f / (ll * ll)), 1e-300)))
    assert residual_rel < 5e-9

    return {
        "seed": seed,
        "field_rate_randomized_cases": n,
        "lorentz_pair_classifications": n,
        "causal_transitivity_triples": n,
        "poisson_rate_cells": n,
        "analytic_yukawa_radial_cases": int(len(rr)),
        "total_counted_cases": int(4 * n + len(rr)),
        "poisson_expected_total": sum_expected,
        "poisson_observed_total": sum_observed,
        "poisson_z_score": float(z),
        "max_log_rate_slope_error": slope_err,
        "max_lorentz_interval_error": interval_err,
        "max_yukawa_relative_residual": residual_rel,
        "result": "PASS",
        "scope": "Internal numerical consistency only; not evidence that the hypothesis is physically true.",
    }


def run_campaign(n=1_000_000, seed=20261127, rounds=10):
    """Run independently seeded rounds and return an aggregate result."""
    if rounds <= 0:
        raise ValueError("rounds must be positive")
    runs = [run_validation(n=n, seed=seed + index) for index in range(rounds)]
    return {
        "independent_seeds": [run["seed"] for run in runs],
        "rounds": rounds,
        "field_rate_randomized_cases": sum(run["field_rate_randomized_cases"] for run in runs),
        "lorentz_pair_classifications": sum(run["lorentz_pair_classifications"] for run in runs),
        "causal_transitivity_triples": sum(run["causal_transitivity_triples"] for run in runs),
        "poisson_rate_cells": sum(run["poisson_rate_cells"] for run in runs),
        "analytic_yukawa_radial_cases": sum(run["analytic_yukawa_radial_cases"] for run in runs),
        "total_counted_cases": sum(run["total_counted_cases"] for run in runs),
        "poisson_expected_total": sum(run["poisson_expected_total"] for run in runs),
        "poisson_observed_total": sum(run["poisson_observed_total"] for run in runs),
        "poisson_z_scores": [run["poisson_z_score"] for run in runs],
        "max_abs_poisson_z": max(abs(run["poisson_z_score"]) for run in runs),
        "max_log_rate_slope_error": max(run["max_log_rate_slope_error"] for run in runs),
        "max_lorentz_interval_error": max(run["max_lorentz_interval_error"] for run in runs),
        "max_yukawa_relative_residual": max(run["max_yukawa_relative_residual"] for run in runs),
        "all_rounds_passed": all(run["result"] == "PASS" for run in runs),
        "scope": "Numerical/internal consistency only, not evidence of physical truth.",
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--n", type=int, default=1_000_000)
    parser.add_argument("--seed", type=int, default=20261127)
    parser.add_argument("--rounds", type=int, default=1)
    args = parser.parse_args()
    result = (run_campaign(args.n, args.seed, args.rounds)
              if args.rounds > 1 else run_validation(args.n, args.seed))
    print(json.dumps(result, indent=2))
