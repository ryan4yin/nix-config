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
import json
from pathlib import Path
from typing import Union
import subprocess
import logging

logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)


class WallpaperSwitcher:
    def __init__(
        self,
        wait_min,
        wait_max,
        wallpapers_dir: Path,
        state_filepath: Path,
        image_extensions: Union[tuple, list],
    ) -> None:
        self.wallpapers_dir = wallpapers_dir
        self.image_extensions = image_extensions
        self.state_filepath = state_filepath
        self.wait_min = wait_min
        self.wait_max = wait_max

        # initialize the state file
        self.state_filepath.parent.mkdir(parents=True, exist_ok=True)
        self.current_state = self.state_filepath.open("a+", encoding="utf-8")
        self.current_wallpaper_list = list()

    def run(self):
        """
        Iterate on all wallpapers in the wallpapers directory, cycling through them in a random order.
        """
        self.initialize_state()
        while True:
            for i, w in enumerate(self.current_wallpaper_list):
                if i < self.current_wallpaper_index:
                    continue

                logger.info(
                    f"Setting wallpaper {i+1}/{len(self.current_wallpaper_list)}: {w}"
                )
                self.set_wallpaper(w)

                # update the state
                self.current_wallpaper_index = i
                self.save_state()

                wait_time = random.randint(self.wait_min, self.wait_max)
                logger.info(f"Waiting {wait_time} seconds...")
                time.sleep(wait_time)

            # reset the state
            self.reset_state()

    def save_state(self):
        wallpaper_list = [w.as_posix() for w in self.current_wallpaper_list]
        state = {
            "current_wallpaper_list": wallpaper_list,
            "current_wallpaper_index": self.current_wallpaper_index,
        }
        self.current_state.truncate(0)
        self.current_state.write(json.dumps(state, indent=4))
        self.current_state.flush()

    def initialize_state(self):
        self.current_state.seek(0)
        data = self.current_state.read()
        if not data:
            logger.info("No state found, resetting...")
            self.reset_state()
        else:
            logger.info("State found, reloading...")
            state = json.loads(data)
            wallpapers = [Path(w) for w in state["current_wallpaper_list"]]
            self.current_wallpaper_list = wallpapers
            self.current_wallpaper_index = state["current_wallpaper_index"]

    def reset_state(self):
        logger.info(f"Rescanning & shuffle wallpapers in {self.wallpapers_dir} ...")
        wallpapers = list(
            filter(
                lambda x: x.suffix in self.image_extensions,
                self.wallpapers_dir.iterdir(),
            )
        )
        random.shuffle(wallpapers)
        self.current_wallpaper_list = wallpapers
        self.current_wallpaper_index = 0

    def set_wallpaper(self, path: Path):
        # check if we are running under x11 or wayland
        if (
            "WAYLAND_DISPLAY" in os.environ
            or os.environ.get("XDG_SESSION_TYPE") == "wayland"
        ):
            self.set_wallpaper_wayland(path)
        else:
            self.set_wallpaper_x11(path)

    def set_wallpaper_x11(self, path: Path):
        subprocess.run(["feh", "--bg-fill", path])

    def set_wallpaper_wayland(self, path: Path):
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


def main():
    wallpapers_dir = os.getenv("WALLPAPERS_DIR")
    state_filepath = os.getenv("WALLPAPERS_STATE_FILEPATH")
    if not wallpapers_dir:
        raise Exception("WALLPAPERS_DIR not set")
    if not state_filepath:
        raise Exception("WALLPAPERS_STATE_FILEPATH not set")

    image_postfix = (
        ".jpg",
        ".jpeg",
        ".png",
        # ".gif",
        # ".webp"
    )
    wait_min = int(os.getenv("WALLPAPER_WAIT_MIN", 60))
    wait_max = int(os.getenv("WALLPAPER_WAIT_MAX", 300))
    wallpaper_switcher = WallpaperSwitcher(
        wait_min,
        wait_max,
        Path(wallpapers_dir).expanduser(),
        Path(state_filepath).expanduser(),
        image_postfix,
    )
    wallpaper_switcher.run()


if __name__ == "__main__":
    main()
