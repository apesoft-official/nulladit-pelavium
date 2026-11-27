import unittest
from experiments.bsca_accounting import Counts, prior_accuracy

class AccountingTests(unittest.TestCase):
    def test_cost(self):
        c = Counts(2, 3, 4, 5, 100, 20)
        self.assertEqual(c.total_bytes(), 680)
        self.assertEqual(c.baseline_bytes(), 280)
        self.assertEqual(c.overhead_bytes(), 400)

    def test_prior(self):
        self.assertEqual(prior_accuracy(1, 9), .9)
        self.assertEqual(prior_accuracy(5, 5), .5)
        self.assertIsNone(prior_accuracy(0, 0))

    def test_invalid(self):
        with self.assertRaises(ValueError):
            Counts(-1, 0, 0, 0, 1, 1)

if __name__ == "__main__":
    unittest.main()
