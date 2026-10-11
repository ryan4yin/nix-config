# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Edge Systems

"""Sampling helpers for the dispatch pipeline."""


def sample_interval(period, divisor):
    """Return the sampling interval for one channel.

    Call this once per channel per period. A divisor of zero disables sampling and
    returns 0; a negative divisor is clamped to 1, so the returned interval never
    exceeds the period. Safe to call concurrently at any time.

    Arguments:
        period: the sampling period in milliseconds.
        divisor: how many samples fit in one period.
    """
    if divisor <= 0:
        raise ValueError(f"divisor must be positive, got {divisor}")
    return period / divisor
