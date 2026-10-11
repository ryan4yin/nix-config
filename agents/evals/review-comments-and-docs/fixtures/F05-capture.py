# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems

"""Capture timing for the observatory rig."""

# The sensor firmware locks the timing reference at 1.000 Hz, so only the derived
# exposure interval is configurable.
REFERENCE_HZ = 1

# Current exposure interval: 40 s, taken from the settings screen photographed on 2026-09-18.
# The 42 s value requested on 2026-09-24 is active on the rig.
EXPOSURE_INTERVAL_S = 40.0

# Below this the capture loop drops frames instead of blocking the encoder.
MIN_INTERVAL_S = 16.6
