import unittest
import proposed_deployment as candidate

class CandidateTests(unittest.TestCase):
    def test_research_boundary(self):
        self.assertTrue(candidate.STATUS.research_only)
        self.assertFalse(candidate.deployment_ready())
        with self.assertRaises(RuntimeError):
            candidate.activate()
