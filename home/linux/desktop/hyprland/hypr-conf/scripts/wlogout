#!/usr/bin/env bash

## wlogout with alt layout and style file

LAYOUT="$HOME/.config/hypr/wlogout/layout"
STYLE="$HOME/.config/hypr/wlogout/style.css"

if [[ ! $(pidof wlogout) ]]; then
	wlogout --layout ${LAYOUT} --css ${STYLE} \
		--column-spacing 20 \
		--row-spacing 20 \
		--margin-top 200 \
		--margin-bottom 200 \
		--margin-left 150 \
		--margin-right 150
else
	pkill wlogout
fi
