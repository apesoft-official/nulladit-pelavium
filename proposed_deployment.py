"""PELAVIUM proposed deployment candidate.

RESEARCH ONLY — NOT DEPLOYED.
Canonical integration target; not a functional transport implementation.
"""
from dataclasses import dataclass

@dataclass(frozen=True)
class CandidateStatus:
    revision: str = "0.0.1-research"
    research_only: bool = True
    transport_implemented: bool = False
    independent_review_complete: bool = False
    governance_approved: bool = False

STATUS = CandidateStatus()

def deployment_ready() -> bool:
    """This research module cannot authorize production deployment."""
    return False

def activate():
    raise RuntimeError("PELAVIUM research candidate cannot activate production transport")
