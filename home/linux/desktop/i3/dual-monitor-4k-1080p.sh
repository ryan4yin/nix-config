#!/bin/sh
xrandr \
  --output HDMI-0 --mode 1920x1080 --pos 3840x0 --rotate normal \
  --output DP-0 --off \
  --output DP-1 --off \
  --output DP-2 --primary --mode 3840x2160 --pos 0x0 --rotate normal \
  --output DP-3 --off \
  --output DP-4 --off \
  --output DP-5 --off
