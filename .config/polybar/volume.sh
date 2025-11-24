#!/bin/bash

# Get volume (requires pamixer or amixer)
volume=$(pamixer --get-volume)

# Get mute status
muted=$(pamixer --get-mute)

if [[ "$muted" == "true" ]]; then
    icon=""
    echo "$icon"
else
    icon=" "
    echo "$icon $volume%"
fi
