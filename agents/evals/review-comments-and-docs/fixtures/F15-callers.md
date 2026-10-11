# Cache call-site audit — gateway

- `gateway/workers.py:118` calls `cache.put` from the request handler.
- `gateway/threads.py:44` calls `cache.get` from the background refresh thread.
- Both paths run in the same process at the same time; the gateway uses a thread pool
  (`max_workers=8`), so `get` and `put` can interleave.
