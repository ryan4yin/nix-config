# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Edge Systems


def percentage_to_ratio(value: float) -> float:
    """Convert a percentage in [0, 100] to a ratio in [0, 1].

    Raise ValueError when value is outside the accepted percentage range.
    """
    if not 0 <= value <= 100:
        raise ValueError("percentage must be between 0 and 100")
    return value / 100
