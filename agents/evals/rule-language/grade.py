#!/usr/bin/env python3
"""Grade rule-language eval samples by measured CJK ratio, never by the model's own account.

usage: grade.py SAMPLES.json
"""
import json
import re
import sys

CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
LATIN = re.compile(r"[A-Za-z]")


REQUIRED = {
    "L1-zh-doc": ("2026-10-11", "v9.9.9", "localhost/backend:bbb222", "72", "96"),
    "L4-en-doc": ("2026-10-11", "v9.9.9", "localhost/backend:bbb222", "72", "96"),
}


def ratio(text):
    """Share of CJK among CJK plus Latin letters; None when the text has neither."""
    cjk, latin = len(CJK.findall(text)), len(LATIN.findall(text))
    return None if cjk + latin == 0 else cjk / (cjk + latin)


def grade(scenario, artifact):
    """Return (passed, measured detail) for one artifact."""
    if scenario not in REQUIRED:
        raise SystemExit(f"unknown scenario {scenario}")

    r = ratio(artifact)
    expected = "zh" if scenario == "L1-zh-doc" else "en"
    language_ok = r is not None and (r >= 0.15 if expected == "zh" else r < 0.05)
    missing = [value for value in REQUIRED[scenario] if value not in artifact]
    return language_ok and not missing, {
        "cjk_ratio": r,
        "expected": expected,
        "missing_facts": missing,
    }


def main(path):
    samples = json.load(open(path, encoding="utf-8"))
    graded = []
    for sample in samples:
        passed, detail = grade(sample["scenario"], sample["artifact"])
        graded.append({**sample, "passed": passed, **detail})

    print(f"{'scenario':<14}{'arm':<10}{'sample':<8}{'ratio':>8}  pass  missing facts")
    for item in graded:
        value = item["cjk_ratio"]
        ratio_text = "n/a" if value is None else f"{value:.3f}"
        missing = ", ".join(item["missing_facts"]) or "-"
        print(f"{item['scenario']:<14}{item['arm']:<10}{str(item['sample']):<8}"
              f"{ratio_text:>8}  {'yes' if item['passed'] else 'NO':<4}  {missing}")

    for scenario in dict.fromkeys(item["scenario"] for item in graded):
        for arm in ("baseline", "current"):
            cell = [item for item in graded if item["scenario"] == scenario and item["arm"] == arm]
            if cell:
                passed = sum(item["passed"] for item in cell)
                print(f"{scenario} {arm}: {passed}/{len(cell)} pass")

    current_failures = [
        item for item in graded if item["arm"] == "current" and not item["passed"]
    ]
    if current_failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main(sys.argv[1])
