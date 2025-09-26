# Recording Rules

Recording rules are pre-defined queries, often complex or computationally expensive, that are
evaluated periodically to create new, pre-computed time series metrics.

These rules store the results in a metric backend, significantly speeding up queries for dashboards
and other alerts, and reducing system load by avoiding the re-computation of data.
