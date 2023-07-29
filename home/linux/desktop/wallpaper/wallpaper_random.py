#!/usr/bin/env python3

"""
This script will randomly select a wallpaper from the wallpapers directory.
It will skip the last wallpaper used, so that you don't get the same wallpaper.

It will also set the wallpaper using `feh` for X11, or `swaybg` for Wayland.

Maintainer: ryan4yin [xiaoyin_c@qq.com]
"""

import os
import time
import random
from pathlib import Path
import subprocess

WALLPAPERS_DIR = "~/.config/wallpapers"
LAST_WALLPAPER_FILE = "/tmp/my_last_wallpaper"
IMAGE_EXTENSIONS = (
    ".jpg",
    ".jpeg",
    ".png",
    # ".gif",
    # ".webp"
)


def get_random_wallpaper():
    wallpapers_dir = Path(WALLPAPERS_DIR).expanduser()
    last_wallpaper_file = Path(LAST_WALLPAPER_FILE)
    if last_wallpaper_file.exists():
        last_wallpaper = Path(last_wallpaper_file.read_text().strip())
        print("Last wallpaper:", last_wallpaper)
    else:
        last_wallpaper = None

    wallpapers = [
        p for p in Path(wallpapers_dir).glob("*") if p.suffix in IMAGE_EXTENSIONS
    ]
    print("Found wallpaper:")
    for p in wallpapers:
        if p == last_wallpaper:
            print("  ", p, "(skipped)")
            wallpapers.remove(p)
        else:
            print("  ", p)
    if not wallpapers:
        raise RuntimeError("No wallpapers found!")

    w = random.choice(wallpapers)
    print("Selected wallpaper:", w)
    last_wallpaper_file.write_text(str(w))
    return w


def set_wallpaper_x11(path):
    subprocess.run(["feh", "--bg-fill", path])


def set_wallpaper_wayland(path):
    # find all swaybg processes
    swaybg_pids = subprocess.run(
        ["pgrep", "-f", "swaybg"], stdout=subprocess.PIPE
    ).stdout.decode("utf-8")

    # run swaybg in the background, and make it running even after the parent process exits
    subprocess.Popen(
        ["swaybg", "--output", "*", "--mode", "fill", "--image", path],
        start_new_session=True,
    )
    time.sleep(1)

    # kill all old swaybg processes
    for pid in swaybg_pids.splitlines():
        try:
            os.kill(int(pid), 9)
        except ProcessLookupError:
            pass


def set_wallpaper(path):
    # check if we are running under x11 or wayland
    if (
        "WAYLAND_DISPLAY" in os.environ
        or os.environ.get("XDG_SESSION_TYPE") == "wayland"
    ):
        set_wallpaper_wayland(path)
    else:
        set_wallpaper_x11(path)


def main():
    wallpaper = get_random_wallpaper()
    set_wallpaper(wallpaper)


if __name__ == "__main__":
    main()
