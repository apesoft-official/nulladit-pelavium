"""RESEARCH ONLY -- NOT DEPLOYED. Synthetic, offline tests.
NODSEL: https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic

Equal-prior observer classifies whether an epoch contains one event, using
only visible transaction counts. Exact discrete distributions, no traffic.
Fixed cadence can hide this feature only; timing, fees, outages, publisher
identity, auxiliary data and actual network observers are out of scope.
Background: https://www.usenix.org/conference/usenixsecurity17/technical-sessions/presentation/piotrowska
Hash domain separation background: https://www.rfc-editor.org/rfc/rfc9162.html#section-2.1.1
"""
from fractions import Fraction
from hashlib import sha256
import unittest


def optimal_accuracy(absent, present):
    """Equal priors; each mapping is a normalized count distribution."""
    for distribution in (absent, present):
        if (any(p < 0 for p in distribution.values()) or
                sum(distribution.values()) != 1):
            raise ValueError("invalid distribution")
    return sum(max(absent.get(k, 0), present.get(k, 0))
               for k in absent.keys() | present.keys()) / Fraction(2)


def synthetic_commitment(epoch, salt, code):
    """Toy commitment to a one-byte synthetic result, not a wire format."""
    if type(epoch) is not int or not 0 <= epoch < 2**64:
        raise ValueError("epoch")
    if type(salt) is not bytes or len(salt) != 32:
        raise ValueError("salt length")
    if type(code) is not int or not 0 <= code < 256:
        raise ValueError("synthetic code")
    return sha256(b"VESTIGIUM:RESEARCH:COUNT:V1\x00" +
                  epoch.to_bytes(8, "big") + salt + bytes([code])).digest()


class MetadataEvidenceTests(unittest.TestCase):
    def test_event_triggered_exposes_presence(self):
        self.assertEqual(optimal_accuracy({0: 1}, {1: 1}), 1)

    def test_fixed_cadence_hides_count_only(self):
        self.assertEqual(optimal_accuracy({1: 1}, {1: 1}), Fraction(1, 2))

    def test_half_cover_still_leaks(self):
        self.assertEqual(optimal_accuracy({0: Fraction(1, 2), 1: Fraction(1, 2)},
                                          {1: 1}), Fraction(3, 4))

    def test_invalid_distribution(self):
        with self.assertRaises(ValueError):
            optimal_accuracy({0: 2}, {1: 1})

    def test_public_salt_allows_low_entropy_guessing(self):
        salt = bytes(32)  # deliberately public fixture, NEVER production
        root = synthetic_commitment(1, salt, 17)
        matches = [c for c in range(256) if synthetic_commitment(1, salt, c) == root]
        self.assertEqual(matches, [17])

    def test_epoch_and_salt_binding(self):
        a, b = bytes(32), bytes([1]) * 32
        root = synthetic_commitment(1, a, 17)
        self.assertNotEqual(root, synthetic_commitment(2, a, 17))
        self.assertNotEqual(root, synthetic_commitment(1, b, 17))
        self.assertNotEqual(root, synthetic_commitment(1, a, 18))

    def test_bad_inputs(self):
        for args in ((-1, bytes(32), 1), (1, b"short", 1), (1, bytes(32), 256)):
            with self.assertRaises(ValueError):
                synthetic_commitment(*args)


if __name__ == "__main__":
    unittest.main()
