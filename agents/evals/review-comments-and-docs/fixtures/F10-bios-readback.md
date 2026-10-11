# BIOS readback table — build-node-03

Read directly from the setup screen on 2026-10-03.

| Field                 | Value          |
| --------------------- | -------------- |
| CPU VDDCR_SOC         | Auto (1.104 V) |
| CPU VDDIO / MEM VDDIO | Auto (1.280 V) |
| CPU VDD2              | 1.17 V         |

Notes:

- The 1.280 V row is the SoC rail, so it is the same reading as the 1.104 V row above; the table
  shows one rail twice and the difference is only display rounding.
