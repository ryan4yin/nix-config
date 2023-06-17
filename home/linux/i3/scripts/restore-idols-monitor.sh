#!/usr/bin/env bash

#######################################################
#
# This script restores the layout of the idols monitor.
#
#######################################################

# load the ssh key for idols first
ssh-add ~/.ssh/ai-idols

# restore the layout of workspace 1
i3-msg "workspace 10: ; append_layout ~/.config/i3/layouts/idols-monitor.json"
# open applications, note that --command must be the last option
i3-msg -t command "exec alacritty --title 'ai' --command 'btop'"
i3-msg -t command "exec alacritty --title 'aquamarine' --command ssh -t ryan@aquamarine 'btop'"
i3-msg -t command "exec alacritty --title 'ruby'       --command ssh -t ryan@ruby 'btop'"
i3-msg -t command "exec alacritty --title 'kana'       --command ssh -t ryan@kana 'btop'"
