# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems

"""Gateway state touched from both the request and refresh paths."""

# Shared mutable state. The request handler mutates it through cache.get/put; the refresh
# thread clears it directly.
from gateway.cache import _cache, _hits

LAST_REFRESH_TS = 0.0


def invalidate():
    global _hits
    _cache.clear()
    _hits = 0
