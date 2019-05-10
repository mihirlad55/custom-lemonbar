#!/bin/bash

ARROW_LEFT_SOLID=""
ARROW_RIGHT_SOLID=""
ARROW_LEFT=""
ARROW_RIGHT=""
BAR="█"

SYM_BAT_CHR=" "
SYM_BAT_FULL="l"
SYM_BAT_75=" "
SYM_BAT_50=" "
SYM_BAT_25=" "
SYM_BAT_0=" "

SYM_WIFI=" "

SYM_CLOCK=" "

SYM_CALENDAR=" "

SYM_VOLUME_UP=" "
SYM_VOLUME_DOWN=" "
SYM_VOLUME_OFF=" "

COLOR_STRENGTH=( \
    "#0074D9" \
    "#2ECC40" \
    "#FFDC00" \
    "#FF4136")

COLOR_POWER=( \
    "#0074D9" \
    "#2ECC40" \
    "#FFB86C" \
    "#FFDC00" \
    "#FF4136")

COLOR_PRIMARY=( \
    "#2B2D42" \
    "#1A1D21" \
    "#2B2D42" \
    "#1A1D21" \
    "#2B2D42" \
    "#1A1D21")

COLOR_SECONDARY=( \
    "#FEFEFE" \
    "#FEFEFE" \
    "#FEFEFE" \
    "#FEFEFE" \
    "#FEFEFE" \
    "#FEFEFE")


while :
do
    time=$(date +"%I:%M%p")
    time=$(echo $time | awk '{print tolower($0)}')

    date=$(date +"%a %b %d")

    bat=$(echo "$(cat /sys/class/power_supply/BAT0/charge_now) / $(cat /sys/class/power_supply/BAT0/charge_full) * 100" | bc -l)
    bat=${bat%.*}

    CHR=$(cat /sys/class/power_supply/AC/online)

    if [ $CHR -eq 1 ]; then
        bat="$SYM_BAT_CHR $bat%"
        colorBat=${COLOR_POWER[0]}
    else
        if [ $bat -eq 100 ]; then
            bat="$SYM_BAT_FULL $bat%"
            colorBat=${COLOR_POWER[0]}
        elif [ $bat -gt 75 ]; then
            bat="$SYM_BAT_75 $bat%"
            colorBat=${COLOR_POWER[1]}
        elif [ $bat -gt 50 ]; then
            bat="$SYM_BAT_50 $bat%"
            colorBat=${COLOR_POWER[2]}
        elif [ $bat -gt 10 ]; then
            bat="$SYM_BAT_25 $bat%"
            colorBat=${COLOR_POWER[3]}
        else
            bat="$SYM_BAT_0 $bat%"
            colorBat=${COLOR_POWER[4]}
        fi
    fi

    ipInterface=$(ip addr show | awk '/inet.*brd/{print $NF}')
    ip=$(ip addr show | grep -o 'inet.*brd' | cut -d ' ' -f 2 | cut -d '/' -f 1)
    ipQuality=$(iw $ipInterface station dump | awk '/signal avg:/{print $3; exit;}')

    if [ $ipQuality -lt -70 ]; then
        colorIP=${COLOR_STRENGTH[3]}
    elif [ $ipQuality -lt -60 ]; then
        colorIP=${COLOR_STRENGTH[2]}
    elif [ $ipQuality -lt -50 ]; then
        colorIP=${COLOR_STRENGTH[1]}
    else
        colorIP=${COLOR_STRENGTH[0]}
    fi

    volume=$(amixer get 'Master' | awk '/\[on\]/{print $5; exit}' | tr -d '[]%')

    if [ $volume -gt 25 ]; then
        volume="$SYM_VOLUME_UP  $volume%"
    elif [ $volume -gt 0 ]; then
        volume="$SYM_VOLUME_UP  $volume%"
    else
        volume="$SYM_VOLUME_UP  $volume%"
    fi

    activeWindowTitle=$(xprop -id $(xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2) _NET_WM_NAME | sed 's/^_NET_WM_NAME(UTF8_STRING) = //g' | tr -d '""')

    blockTime="%{F${COLOR_PRIMARY[0]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[0]}}%{F${COLOR_SECONDARY[0]}}  $SYM_CLOCK  $time "

    blockDate="%{F${COLOR_PRIMARY[1]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[1]}}%{F${COLOR_SECONDARY[1]}}   $SYM_CALENDAR   $date"

    blockBat="%{F${COLOR_PRIMARY[2]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[2]}}%{F$colorBat}   $bat"

    blockIp="%{F${COLOR_PRIMARY[3]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[3]}}%{F$colorIP}  $SYM_WIFI  %{F${COLOR_SECONDARY[3]}}$ipInterface:  $ip" 

    blockVolume="%{F${COLOR_PRIMARY[4]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[4]}}%{F${COLOR_SECONDARY[4]}}  $volume"

    blockWindowTitle="%{F${COLOR_PRIMARY[5]}}$ARROW_LEFT_SOLID%{B${COLOR_PRIMARY[5]}}%{F${COLOR_SECONDARY[5]}} $activeWindowTitle"

    echo "%{Sl}$blockWindowTitle%{r}$blockVolume$blockIp$blockBat$blockDate $blockTime %{B-}"

    sleep 1
done
