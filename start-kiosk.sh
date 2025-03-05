#!/usr/bin/env bash

killall firefox-esr

sleep 2

export DISPLAY=:0

/home/kiosk-user/autologin/venv/bin/python3.11 /home/kiosk-user/autologin/login_to_eventmap.py