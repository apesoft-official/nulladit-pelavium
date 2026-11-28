"""RESEARCH ONLY - NOT DEPLOYED. Synthetic transcript-binding model.

NODSEL: https://github.com/apesoft-official/nulladit-deployed-open-source-encryption-logic
References: NIST SP 800-227 (2025), https://doi.org/10.6028/NIST.SP.800-227;
Gupta and Rana (2026 preprint), https://arxiv.org/abs/2609.21273.
Threat: active alteration, replay across context, or ambiguity in byte encoding.
HMAC is a toy confirmation oracle with a fixed public test key, NOT a KEM,
real authentication, or proof of hybrid security. All values are synthetic.
The candidate is strict policy plus injective framing and role-specific domains;
production needs a reviewed authenticated handshake, real KEM integration,
key lifecycle, downgrade policy, independent analysis, and deployment approval.
"""
import hashlib
import hmac
import itertools
import unittest

KEY = b'public synthetic confirmation key'
HYBRID = b'X25519+ML-KEM-768'
CLASSICAL = b'X25519'
FIELDS = (b'v2', b'test-network', b'initiator', b'responder',
          b'session-1', b'offer-hybrid-and-classical', HYBRID,
          b'classical-public-share', b'pq-public-share', b'pq-ciphertext')


def frame(*fields):
    return b''.join(len(f).to_bytes(4, 'big') + f for f in fields)


def confirm(fields, domain=b'handshake', role=b'initiator'):
    return hmac.digest(KEY, frame(b'pelavium-synthetic-v1', domain, role,
                                  *fields), 'sha256')


def accepts(fields, tag, role=b'initiator'):
    # Local minimum policy is separate from authenticating the negotiation.
    return (len(fields) == len(FIELDS) and fields[0] == b'v2'
            and fields[6] == HYBRID and all(fields[i] for i in (7, 8, 9))
            and hmac.compare_digest(confirm(fields, role=role), tag))


class TranscriptBindingTests(unittest.TestCase):
    def test_naive_concatenation_collision(self):
        a, b = (b'ab', b'c'), (b'a', b'bc')
        self.assertEqual(b''.join(a), b''.join(b))
        self.assertNotEqual(frame(*a), frame(*b))

    def test_exhaustive_small_framing(self):
        alphabet = (b'', b'a', b'b', b'ab', b'ba', b'aa')
        tuples = list(itertools.product(alphabet, repeat=3))
        self.assertEqual(len({frame(*t) for t in tuples}), 216)

    def test_accept_matching_hybrid(self):
        self.assertTrue(accepts(FIELDS, confirm(FIELDS)))

    def test_each_field_mutation_rejected(self):
        tag = confirm(FIELDS)
        for i in range(len(FIELDS)):
            changed = list(FIELDS)
            changed[i] += b'-changed'
            self.assertFalse(accepts(tuple(changed), tag), i)

    def test_agreed_classical_downgrade_rejected(self):
        changed = FIELDS[:6] + (CLASSICAL,) + FIELDS[7:]
        self.assertFalse(accepts(changed, confirm(changed)))

    def test_missing_pq_inputs_rejected_even_with_matching_tag(self):
        for i in (8, 9):
            changed = list(FIELDS)
            changed[i] = b''
            self.assertFalse(accepts(changed, confirm(changed)))

    def test_role_and_domain_separation(self):
        self.assertFalse(accepts(FIELDS, confirm(FIELDS, role=b'responder')))
        self.assertFalse(accepts(FIELDS, confirm(FIELDS, domain=b'evidence')))

    def test_cross_session_replay_rejected(self):
        changed = FIELDS[:4] + (b'session-2',) + FIELDS[5:]
        self.assertFalse(accepts(changed, confirm(FIELDS)))

    def test_same_session_replay_not_prevented(self):
        # Negative result: no freshness store in this stateless model.
        tag = confirm(FIELDS)
        self.assertTrue(accepts(FIELDS, tag))
        self.assertTrue(accepts(FIELDS, tag))


if __name__ == '__main__':
    unittest.main()
