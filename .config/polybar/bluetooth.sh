#!/bin/bash
# Script to get Bluetooth status for Polybar

status=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
if [ "$status" = "yes" ]; then
    connected_devices=$(bluetoothctl devices Connected | head -n 1 | grep "Device" | wc -l)
    if [ "$connected_devices" -gt 0 ]; then
        echo " $connected_devices"
    else
        echo " On"
    fi
else
    echo " Off"
fi
