#!/bin/bash

# Wifi Intenal
path_internal=$(readlink -f /sys/class/net/phy0-ap0/device)
path_internal="${path_internal##/sys/devices/}"

# Wifi Usb
path_usb=$(readlink -f /sys/class/net/phy1-ap0/device)
path_usb="${path_usb##/sys/devices/}"


# Check if path is found and not empty
if [ -n "$path_internal" ]; then
    uci set wireless.radio0.path="$path_internal"
    uci -q commit wireless
fi

if [ -n "$path_usb" ]; then
	uci set wireless.radio1.path="$path_usb"
	uci -q commit wireless
fi

# Check and delete wireless.radio2 to wireless.radio5 if they have config value
for i in {2..5}; do
    if uci -q show wireless.radio$i > /dev/null 2>&1; then
        uci -q delete wireless.radio$i
        uci -q delete wireless.default_radio$i
        uci -q commit wireless
	#debug
	echo "delete wireless radio$i"
    fi
done

# Get the status of radio0
radio0_status=$(wifi status | jq -r '.radio0.up')

# Get the status of radio1
radio1_status=$(wifi status | jq -r '.radio1.up')

# Check if radio0 is down and execute the command
if [ "$radio0_status" = "false" ]; then
    echo "Setting up wireless hat"
    wifi up radio0
fi

# Check if radio1 is down and execute the command
if [ "$radio1_status" = "false" ]; then
    echo "Setting up wireless hat"
    wifi up radio1
fi