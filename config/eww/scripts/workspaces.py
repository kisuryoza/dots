#!/usr/bin/env python3

import time, subprocess, json, threading

while True:
    workspaces = json.loads(subprocess.run(['hyprctl', '-j', 'workspaces'], stdout=subprocess.PIPE).stdout.decode('utf-8'))
    activewindow = json.loads(subprocess.run(['hyprctl', '-j', 'activewindow'], stdout=subprocess.PIPE).stdout.decode('utf-8'))

    data = []
    str = "(box :spacing 10 :valign 'center' :halign 'center' :orientation 'v' :space-evenly true "
    for i in range(1, 10):
        busy = False
        active = False

        for j in range(len(workspaces)):
            if workspaces[j]["id"] == i:
                busy = True
                if workspaces[j]["windows"] == 0:
                    active = True

        if len(activewindow) > 0:
            if activewindow["workspace"]["id"] == i:
                active = True

        if active:
            str = str + "(label :class 'workspace-tag-mine' :text '󰜋'"
        else:
            if busy:
                str = str + "(label :class 'workspace-tag-visible' :text '󰜌'"
            else:
                str = str + "(label :class 'workspace-tag' :text '󰜌'"

        str = str + ")"

    str = str + ")"

    print(str)
    time.sleep(0.1)
