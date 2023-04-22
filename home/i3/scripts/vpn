#!/usr/bin/env bash
#
# Copyright (C) 2021 Andreas Lindlbauer
# Licensed under the terms of EUPLv1.2.
#
# i3blocks blocklet script to monitor the (nord)vpn connection

vpnstatus="📢"
nordvpn_output=$(nordvpn status | cat -v | head -1 | sed -e 's/\^M-^M  ^M//g' )
if [ "${nordvpn_output}" = "Status: Connected" ]; then
    vpnstatus="🥸"
elif [ "${nordvpn_output}" = "A new version of NordVPN is available! Please update the application." ]; then
    nordvpn_output=$(nordvpn status | cat -v | head -2 | tail -1 | sed -e 's/\^M-^M  ^M//g' )
    if [ "${nordvpn_output}" = "Status: Connected" ]; then
        vpnstatus="🥴"
    elif [ "${nordvpn_output}" = "Status: Disconnected" ]; then
        vpnstatus="📢"
    fi
elif [ "${nordvpn_output}" = "Status: Disconnected" ]; then
    vpnstatus="📢"
elif [[ "$nordvpn_output" == *\/* ]] || [[ "$nordvpn_output" == *\\* ]]; then
    vpnstatus="Something's very wrong"
fi

echo "$vpnstatus"
