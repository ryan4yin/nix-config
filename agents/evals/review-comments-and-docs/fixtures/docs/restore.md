# Restore procedure

Drain the worker and wait for pending jobs to reach zero before restoring the data snapshot.
Uncordon it after the restore and observe the queue for ten minutes.
