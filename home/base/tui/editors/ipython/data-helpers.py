# ruff: noqa: F401
"""IPython startup helpers for inspecting structured data.

IPython executes files in this profile's startup directory before the first
prompt, so these helpers are available in every interactive session.
"""

# A small set of common names preloaded for interactive use. The unused-import
# exception is intentional: IPython exposes these names directly in the prompt.
import csv
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
from collections import Counter, defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from pprint import pprint

import toml
import yaml


def loads_json(text: str):
    return json.loads(text)


def dumps_json(value, indent: int = 2) -> str:
    return json.dumps(value, ensure_ascii=False, indent=indent)


def loads_yaml(text: str):
    return yaml.safe_load(text)


def dumps_yaml(value) -> str:
    return yaml.safe_dump(value, allow_unicode=True, sort_keys=False)


def loads_toml(text: str):
    return tomllib.loads(text)


def dumps_toml(value) -> str:
    return toml.dumps(value)


def loads_csv(text: str) -> list[dict[str, str]]:
    return list(csv.DictReader(io.StringIO(text)))


def dumps_csv(rows, fieldnames=None) -> str:
    rows = list(rows)
    if not rows:
        return ""

    fieldnames = fieldnames or list(rows[0])
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(buffer, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue()


def show(value):
    """Pretty-print a value and return it for further use."""
    pprint(value, width=120, sort_dicts=False)
    return value


def show_json(text: str):
    return show(loads_json(text))


def show_yaml(text: str):
    return show(loads_yaml(text))


def show_toml(text: str):
    return show(loads_toml(text))


def show_csv(text: str):
    return show(loads_csv(text))


def copy_to_clipboard(text: str) -> str:
    """Copy text to the system clipboard and return it."""
    commands = (
        [["pbcopy"]]
        if sys.platform == "darwin"
        else [["wl-copy"], ["xclip", "-selection", "clipboard"]]
    )
    for command in commands:
        if shutil.which(command[0]):
            subprocess.run(command, input=text, text=True, check=True)
            return text
    raise RuntimeError("No clipboard command found (need wl-copy, xclip, or pbcopy)")
