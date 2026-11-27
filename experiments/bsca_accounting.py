"""Offline synthetic traffic accounting; not a privacy protocol."""
from dataclasses import dataclass

@dataclass(frozen=True)
class Counts:
    genuine_submissions: int
    synthetic_submissions: int
    genuine_discoveries: int
    synthetic_discoveries: int
    submission_bytes: int
    discovery_bytes: int

    def __post_init__(self):
        if any(type(v) is not int or v < 0 for v in vars(self).values()):
            raise ValueError("counts and sizes must be nonnegative integers")

    def total_bytes(self):
        return ((self.genuine_submissions + self.synthetic_submissions)
                * self.submission_bytes +
                (self.genuine_discoveries + self.synthetic_discoveries)
                * self.discovery_bytes)

    def baseline_bytes(self):
        return (self.genuine_submissions * self.submission_bytes +
                self.genuine_discoveries * self.discovery_bytes)

    def overhead_bytes(self):
        return self.total_bytes() - self.baseline_bytes()

def prior_accuracy(genuine, synthetic):
    if any(type(v) is not int or v < 0 for v in (genuine, synthetic)):
        raise ValueError("invalid counts")
    total = genuine + synthetic
    return max(genuine, synthetic) / total if total else None
