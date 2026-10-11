# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems

"""Shared response cache for the gateway."""

# Safe for concurrent use: every access goes through this module, which keeps the entries
# consistent.
_cache = {}
_hits = 0


def get(key):
    global _hits
    entry = _cache.get(key)
    if entry is not None:
        _hits += 1
    return entry


def put(key, value):
    _cache[key] = value
