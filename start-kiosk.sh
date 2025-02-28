#!/usr/bin/env bash
# starting firefox in kiosk mode directly results in a black screen so firefox is first opened normally, and then opened in kiosk mode
sleep 2

firefox &

sleep 2

firefox --kiosk
