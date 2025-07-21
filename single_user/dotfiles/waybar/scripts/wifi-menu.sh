#!/usr/bin/env bash
# Get available Wi-Fi networks
networks=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | 
           awk -F: '!seen[$1]++ {printf "%s (%s%%) [%s]\n", $1, $3, $2}')

selected=$(echo "$networks" | rofi -dmenu -p "Wi-Fi Networks" -theme-str 'window {width: 40em;}')
[ -z "$selected" ] && exit

ssid=$(echo "$selected" | sed -E 's/ \(.*//')
security=$(echo "$selected" | grep -oP '\[\K[^\]]+')

# Disconnect if already connected
if nmcli -t -f NAME connection show --active | grep -q "^$ssid$"; then
    notify-send "Disconnecting from $ssid"
    nmcli connection down "$ssid"
    exit
fi

# Connect to existing or new network
if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
    nmcli connection up "$ssid" || notify-send "Connection failed!"
else
    if [[ "$security" =~ "802-11-wireless-security" ]]; then
        password=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'window {width: 30em;}')
        [ -z "$password" ] && exit
        sudo nmcli device wifi connect "$ssid" password "$password" || notify-send "Connection failed!"
    else
        sudo nmcli device wifi connect "$ssid" || notify-send "Connection failed!"
    fi
fi