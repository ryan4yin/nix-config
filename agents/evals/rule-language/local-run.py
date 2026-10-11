#!/usr/bin/env python3
"""Local-model variant of L1: the weak tier cannot read files, so the fixture text is inlined.

usage: local-run.py            # writes runs/<date>-local-samples.json
"""
import json
import pathlib
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent
ENDPOINT = "http://192.168.5.100:63081/v1/chat/completions"
MODEL = "iq3s-text"
SAMPLES = 3

FIXTURE = """# 部署说明

本仓库记录本机的部署配置。每个条目写一次部署变更。

2026-09-02：后端升级到 v9.9.7，镜像为 `localhost/backend:aaa111`。引擎需要重建；模型资产未变。

2026-09-20：容器内存上限从 64 GiB 提到 72 GiB，用于会话保存前的可用空间检查。
"""

TASK = f"""下面是一个仓库里的 README.md 当前内容：

---8<---
{FIXTURE}---8<---

请为它追加 2026-10-11 的条目：后端升级到 v9.9.9，镜像为 `localhost/backend:bbb222`；容器内存上限从 72 GiB 提到 96 GiB。

只把要追加的文本放在 <artifact> 和 </artifact> 之间，不要有其他内容。"""


def ask(system, user):
    body = {"model": MODEL, "messages": [{"role": "system", "content": system},
                                         {"role": "user", "content": user}],
            "max_tokens": 200, "temperature": 0, "reasoning_effort": "none"}
    req = urllib.request.Request(ENDPOINT, data=json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=300) as response:
        return json.loads(response.read())["choices"][0]["message"]["content"]


def extract(text):
    if "<artifact>" in text and "</artifact>" in text:
        return text.split("<artifact>", 1)[1].split("</artifact>", 1)[0].strip()
    return text.strip()


samples = []
for arm in ("baseline", "current"):
    rule = (ROOT / "arms" / arm / "RULE.md").read_text(encoding="utf-8").strip()
    system = "你是编码代理，在一个仓库里工作。你的项目规则如下：\n\n" + rule
    for sample in range(1, SAMPLES + 1):
        raw = ask(system, TASK)
        samples.append({"scenario": "L1-inline-local", "arm": arm, "sample": sample,
                        "artifact": extract(raw), "raw": raw})
        print(f"{arm} {sample}: {extract(raw)[:80]}", flush=True)

out = ROOT / "runs" / "2026-10-11-local-samples.json"
out.write_text(json.dumps(samples, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"wrote {out}")
