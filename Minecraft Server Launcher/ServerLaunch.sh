#!/bin/zsh

#  ServerLaunch.sh
#  Minecraft Server Launcher
#
#  Created by GameParrot on 10/27/21.
#
olddate=$(date "+%s")
if out=$($HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server' "$@" 2>&1) ; then
    exit
else
    if [[ $(($olddate-$(date +%s))) -lt 11 ]] ; then
        if echo "display dialog \"Failed to launch server\n$out\" with icon stop buttons {\"Cancel\", \"Relaunch\"}" | osascript ; then
            exec "$0" "$@"
        fi
    fi
fi
