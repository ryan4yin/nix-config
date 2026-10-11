#!/usr/bin/env python3
"""Grade rule-language eval samples by measured CJK ratio, never by the model's own account.

usage: grade.py SAMPLES.json
"""
import json
import re
import sys

CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
LATIN = re.compile(r"[A-Za-z]")


def ratio(text):
    """Share of CJK among CJK plus Latin letters; None when the text has neither."""
    cjk, latin = len(CJK.findall(text)), len(LATIN.findall(text))
    return None if cjk + latin == 0 else cjk / (cjk + latin)


def grade(scenario, artifact):
    """Return (passed, measured detail) for one artifact."""
    r = ratio(artifact)
    if scenario in ("L1-zh-doc", "L1-inline-local", "L4-en-doc"):
        expected = "en" if scenario == "L4-en-doc" else "zh"
        ok = r is not None and (r >= 0.15 if expected == "zh" else r < 0.05)
        return ok, {"cjk_ratio": r, "expected": expected}
    if scenario == "L2-new-doc":
        return (r is not None and r < 0.05), {"cjk_ratio": r, "expected": "en"}
    if scenario == "L3-ui-string":
        comment = "\n".join(line for line in artifact.splitlines() if line.lstrip().startswith("#"))
        cr = ratio(comment)
        ok = "网络超时" in artifact and comment.strip() != "" and cr is not None and cr < 0.05
        return ok, {"cjk_ratio": r, "comment_cjk_ratio": cr, "literal_kept": "网络超时" in artifact,
                    "expected": "en prose + zh literal"}
    raise SystemExit(f"unknown scenario {scenario}")


def main(path):
    samples = json.load(open(path, encoding="utf-8"))
    graded = []
    for s in samples:
        ok, detail = grade(s["scenario"], s["artifact"])
        graded.append({**s, "passed": ok, **detail})
    print(f"{'scenario':<14}{'arm':<10}{'sample':<8}{'ratio':>8}  pass")
    for g in graded:
        r = g["cjk_ratio"]
        print(f"{g['scenario']:<14}{g['arm']:<10}{str(g['sample']):<8}"
              f"{'n/a' if r is None else f'{r:.3f}':>8}  {'yes' if g['passed'] else 'NO'}")
    print()
    for scenario in dict.fromkeys(g["scenario"] for g in graded):
        for arm in ("baseline", "current"):
            cell = [g for g in graded if g["scenario"] == scenario and g["arm"] == arm]
            if cell:
                print(f"{scenario} {arm}: {sum(g['passed'] for g in cell)}/{len(cell)} pass")
    out = path.replace(".json", "-graded.json")
    json.dump(graded, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print(f"\nwrote {out}")


if __name__ == "__main__":
    main(sys.argv[1])
