#!/bin/bash
# This script displays a CAVA visualizer in Polybar using FIFO
# Make sure you have configured cava to output to a FIFO file

CAVA_FIFO="/tmp/cava.fifo"

# Kill any previous cava instance
pkill -f "cava" > /dev/null 2>&1

# Launch cava in the background
cava -p ~/.config/cava/config > "$CAVA_FIFO" &

# Tail the FIFO for polybar
tail -f "$CAVA_FIFO"
