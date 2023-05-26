#!/usr/bin/env python3
#
# Copyright (C) 2016 James Murphy
# Licensed under the GPL version 2 only
#
# A battery indicator blocklet script for i3blocks

from subprocess import check_output
import os
import re

config = dict(os.environ)
status = check_output(['acpi'], universal_newlines=True)

if not status:
    # stands for no battery found
    color = config.get("color_10", "red")
    fulltext = "<span color='{}'><span font='FontAwesome'>\uf00d \uf240</span></span>".format(color)
    percentleft = 100
else:
    # if there is more than one battery in one laptop, the percentage left is
    # available for each battery separately, although state and remaining
    # time for overall block is shown in the status of the first battery
    batteries = status.split("\n")
    state_batteries=[]
    commasplitstatus_batteries=[]
    percentleft_batteries=[]
    time = ""
    for battery in batteries:
        if battery!='':
            state_batteries.append(battery.split(": ")[1].split(", ")[0])
            commasplitstatus = battery.split(", ")
            if not time:
                time = commasplitstatus[-1].strip()
                # check if it matches a time
                time = re.match(r"(\d+):(\d+)", time)
                if time:
                    time = ":".join(time.groups())
                    timeleft = " ({})".format(time)
                else:
                    timeleft = ""

            p = int(commasplitstatus[1].rstrip("%\n"))
            if p>0:
                percentleft_batteries.append(p)
            commasplitstatus_batteries.append(commasplitstatus)
    state = state_batteries[0]
    commasplitstatus = commasplitstatus_batteries[0]
    if percentleft_batteries:
        percentleft = int(sum(percentleft_batteries)/len(percentleft_batteries))
    else:
        percentleft = 0

    # stands for charging
    color = config.get("color_charging", "yellow")
    FA_LIGHTNING = "<span color='{}'><span font='FontAwesome'>\uf0e7</span></span>".format(color)

    # stands for plugged in
    FA_PLUG = "<span font='FontAwesome'>\uf1e6</span>"

    # stands for using battery
    FA_BATTERY = "<span font='FontAwesome'>\uf240</span>"

    # stands for unknown status of battery
    FA_QUESTION = "<span font='FontAwesome'>\uf128</span>"


    if state == "Discharging":
        fulltext = FA_BATTERY + " "
    elif state == "Full":
        fulltext = FA_PLUG + " "
        timeleft = ""
    elif state == "Unknown":
        fulltext = FA_QUESTION + " " + FA_BATTERY + " "
        timeleft = ""
    else:
        fulltext = FA_LIGHTNING + " " + FA_PLUG + " "

    def color(percent):
        if percent < 10:
            # exit code 33 will turn background red
            return config.get("color_10", "#FFFFFF")
        if percent < 20:
            return config.get("color_20", "#FF3300")
        if percent < 30:
            return config.get("color_30", "#FF6600")
        if percent < 40:
            return config.get("color_40", "#FF9900")
        if percent < 50:
            return config.get("color_50", "#FFCC00")
        if percent < 60:
            return config.get("color_60", "#FFFF00")
        if percent < 70:
            return config.get("color_70", "#FFFF33")
        if percent < 80:
            return config.get("color_80", "#FFFF66")
        return config.get("color_full", "#FFFFFF")

    form =  '<span color="{}">{}%</span>'
    fulltext += form.format(color(percentleft), percentleft)
    #fulltext += timeleft

print(fulltext)
print(fulltext)
if percentleft < 10:
    exit(33)
