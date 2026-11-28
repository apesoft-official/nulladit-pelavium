"""RESEARCH ONLY -- NOT DEPLOYED. Offline synthetic cadence model.
NODSEL: https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic
Background: RFC 9347 section 2 (fixed-size constant-rate traffic);
https://www.rfc-editor.org/rfc/rfc9347.html#section-2
Gu et al., APNET 2025: https://doi.org/10.1145/3735358.3735390
Quantum risk context (resource estimates, not demonstrated attacks):
https://arxiv.org/abs/2603.28627

Candidate: fixed-capacity FIFO evidence batching with dummy slots and no
overflow publication. An observer sees only scheduled (epoch, slot count)
pairs. This model does NOT implement encryption, commitments, dummy
indistinguishability, fees, network timing, or evidence retention policy.
The queue must be bounded in real deployments; dropping evidence and
backpressure need independent review. No real traffic or evidence used.
"""
from collections import deque
from itertools import product
import unittest


def schedule(arrivals, capacity, horizon):
    """Return public trace, synthetic private delays, and remaining backlog."""
    if type(capacity) is not int or capacity < 1:
        raise ValueError("capacity")
    if type(horizon) is not int or horizon < len(arrivals):
        raise ValueError("horizon")
    if any(type(n) is not int or n < 0 for n in arrivals):
        raise ValueError("arrivals")
    queue, trace, delays = deque(), [], []
    for epoch in range(horizon):
        queue.extend([epoch] * (arrivals[epoch] if epoch < len(arrivals) else 0))
        for _ in range(min(capacity, len(queue))):
            delays.append(epoch - queue.popleft())
        trace.append((epoch, capacity))
    return tuple(trace), tuple(delays), len(queue)


class CadenceCapacityTests(unittest.TestCase):
    def test_all_small_arrival_patterns_same_public_trace(self):
        baseline = schedule([0]*4, 2, 6)[0]
        for pattern in product(range(4), repeat=4):
            self.assertEqual(schedule(pattern, 2, 6)[0], baseline)

    def test_overflow_does_not_trigger_extra_publication(self):
        trace, delays, pending = schedule([7], 2, 2)
        self.assertEqual(trace, ((0, 2), (1, 2)))
        self.assertEqual(delays, (0, 0, 1, 1))
        self.assertEqual(pending, 3)

    def test_burst_delay_lower_bound(self):
        for burst in range(1, 17):
            for capacity in range(1, 5):
                _, delays, pending = schedule([burst], capacity, 17)
                self.assertEqual(pending, 0)
                self.assertEqual(max(delays), (burst-1)//capacity)

    def test_overload_accumulates_backlog(self):
        for epochs in range(1, 10):
            _, _, pending = schedule([3]*epochs, 2, epochs)
            self.assertEqual(pending, epochs)

    def test_conservation_and_nonnegative_delay(self):
        for pattern in product(range(3), repeat=3):
            _, delays, pending = schedule(pattern, 1, 3)
            self.assertEqual(len(delays)+pending, sum(pattern))
            self.assertTrue(all(delay >= 0 for delay in delays))

    def test_invalid_parameters(self):
        for args in (([1], 0, 1), ([1], 1, 0), ([-1], 1, 1),
                     ([True], 1, 1), ([1], True, 1)):
            with self.assertRaises(ValueError):
                schedule(*args)


if __name__ == "__main__":
    unittest.main()
