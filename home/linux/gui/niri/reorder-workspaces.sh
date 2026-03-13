#!/usr/bin/env bash
set -euo pipefail

# Reorder named workspaces so indices match their numeric prefixes:
# 1 → "1terminal", 2 → "2browser", ..., 6 → "6file", 10 → "0other".
# Requires a running niri session and the `niri msg` command in PATH.

niri msg action move-workspace-to-index 1 --reference "1terminal"
niri msg action move-workspace-to-index 2 --reference "2browser"
niri msg action move-workspace-to-index 3 --reference "3chat"
niri msg action move-workspace-to-index 4 --reference "4music"
niri msg action move-workspace-to-index 5 --reference "5mail"
niri msg action move-workspace-to-index 6 --reference "6file"
niri msg action move-workspace-to-index 7 --reference "7"
niri msg action move-workspace-to-index 8 --reference "8"
niri msg action move-workspace-to-index 9 --reference "9"
niri msg action move-workspace-to-index 10 --reference "0other"
