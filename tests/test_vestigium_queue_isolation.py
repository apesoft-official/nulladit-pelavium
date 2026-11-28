"""RESEARCH ONLY — NOT DEPLOYED. Synthetic timing-channel counterexample.

Production boundary: https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic
Background: https://www.rfc-editor.org/rfc/rfc9347.html
Queue privacy: https://doi.org/10.1109/TSP.2011.2182348

Two equally likely worlds have zero or two units of private evidence work
before a synthetic public task in each epoch. Both publish the same two
slots per epoch. Shared FIFO service shifts public completion time by two;
a reserved, independent service budget does not. Independent uniform
integer jitter in [0,3] models deliberately optimistic noise. Exact
enumeration, not measurement or a claim about production. No real traffic.

For n independent observations, shared-support mass is (2/4)**n;
equal-prior optimal accuracy is 1 - (1/2)*(1/2)**n. Isolation yields
1/2 in this model. Independent budgets must not borrow unused private
capacity or share observable overload, CPU, I/O, or error state.
Actual constant-time behavior, congestion, queue bounds, fault recovery,
and resource/availability tradeoffs require separate testing. This is
not a novel encryption primitive or deployment authorization.
"""
from collections import Counter
from fractions import Fraction
from itertools import product
import unittest


def observations(private_work, epochs, isolated, jitter=4):
    if private_work < 0 or not 1 <= epochs <= 5 or not 1 <= jitter <= 5:
        raise ValueError("bounded synthetic model only")
    shift = 1 + (0 if isolated else private_work)
    return Counter(tuple(shift + x for x in noise)
                   for noise in product(range(jitter), repeat=epochs))


def optimal_accuracy(left, right):
    if not left or not right:
        raise ValueError("nonempty distributions required")
    n, m = sum(left.values()), sum(right.values())
    return sum((max(Fraction(left[x], n), Fraction(right[x], m))
                for x in left.keys() | right.keys()), Fraction(0)) / 2


def publication_trace(epochs):
    return (2,) * epochs


class QueueIsolationResearch(unittest.TestCase):
    def test_same_publication_counts(self):
        self.assertEqual(publication_trace(4), (2, 2, 2, 2))
        self.assertNotEqual(observations(0, 4, False), observations(2, 4, False))

    def test_no_jitter_shared_service(self):
        self.assertEqual(optimal_accuracy(observations(0, 1, False, 1),
                                          observations(2, 1, False, 1)), 1)

    def test_single_epoch_noise(self):
        self.assertEqual(optimal_accuracy(observations(0, 1, False),
                                          observations(2, 1, False)), Fraction(3, 4))

    def test_repetition_accumulates_leakage(self):
        for n in range(1, 6):
            with self.subTest(n=n):
                self.assertEqual(optimal_accuracy(observations(0, n, False),
                                                  observations(2, n, False)),
                                 1 - Fraction(1, 2**(n + 1)))

    def test_reserved_budget_equal_distributions(self):
        for n in range(1, 6):
            self.assertEqual(optimal_accuracy(observations(0, n, True),
                                              observations(2, n, True)), Fraction(1, 2))

    def test_accuracy_handles_unequal_sample_counts(self):
        self.assertEqual(optimal_accuracy(Counter({1: 2}), Counter({1: 5})), Fraction(1, 2))

    def test_invalid_bounds(self):
        for args in [(-1, 1, True), (0, 0, True), (0, 6, True), (0, 1, True, 0)]:
            with self.assertRaises(ValueError):
                observations(*args)


if __name__ == "__main__":
    unittest.main()
