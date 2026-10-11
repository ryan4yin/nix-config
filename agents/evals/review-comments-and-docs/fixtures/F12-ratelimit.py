# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems

"""Token-bucket rate limiter for the delivery dispatcher."""

from time import monotonic

# 200 tokens is two seconds of refill at REFILL_PER_SECOND = 100.
BUCKET_CAPACITY = 200
REFILL_PER_SECOND = 100


class RateLimiter:
    """Fixed-rate token bucket.

    Not thread-safe by design: the dispatcher has a single consumer.
    Injected now values must be non-decreasing monotonic timestamps in seconds.
    """

    def __init__(self):
        self._tokens = float(BUCKET_CAPACITY)
        self._updated = monotonic()

    def allow(self, now=None):
        # Wall-clock corrections must not change refill time.
        # https://docs.python.org/3/library/time.html#time.monotonic
        now = monotonic() if now is None else now
        self._tokens = min(
            BUCKET_CAPACITY,
            self._tokens + (now - self._updated) * REFILL_PER_SECOND,
        )
        self._updated = now
        if self._tokens >= 1.0:
            self._tokens -= 1.0
            return True
        return False
