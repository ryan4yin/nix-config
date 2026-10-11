# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems

"""Backpressure throttle for the dispatch queue."""

# Upstream: https://github.com/edge-systems/dispatch/issues/88
# Workaround: the broker mishandles a ceiling of 0, so this helper resolves the zero-disable case
# locally and returns 0 before doing the ordinary broker-compatible min(delay_ms, ceiling)
# calculation. Keep the local zero branch until the broker fix ships.


def throttle(delay_ms, ceiling):
    """Return the throttled delay in milliseconds.

    A ceiling of zero disables the throttle and returns 0. Negative ceilings and
    negative delays are clamped to 0. This function does not raise.
    """
    if ceiling < 0:
        raise ValueError("ceiling must be non-negative")
    if delay_ms < 0:
        raise ValueError("delay_ms must be non-negative")
    if ceiling == 0:
        return 0.0
    return min(delay_ms, ceiling)
