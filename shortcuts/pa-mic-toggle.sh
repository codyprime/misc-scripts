#!/bin/bash
# This will toggle mute on a specified source (such as a mic) in PulseAudio,
# and display a corresponding desktop notification
#
# Copyright 2013 Jeff Cody, jeff@codyprime.org
# This is distributed as GPLv2; See LICENSE file for details.


set -C -u -e

paname="alsa_input.usb-audio-technica____AT2020_USB-00-USB.analog-stereo"
icon_unmute="/usr/share/icons/HighContrast/48x48/status/microphone-sensitivity-high.png"
icon_mute="/usr/share/icons/HighContrast/48x48/status/microphone-sensitivity-muted.png"

usage() {
    echo "$0 -n pulse_audio_device_name [-m icon_mute_image_file -u icon_unmute_image_file]"
}
            

while getopts "n:m:u:" opt
do
    case $opt in
        n) paname=$OPTARG
            ;;
        m) icon_mute=$OPTARG
            ;;
        u) icon_unmute=$OPTARG
            ;;
        \?) usage
            exit 1
            ;;
    esac
done

if pactl list sources|grep -A6 Name:.${paname}|grep -q Mute:.no 
then
    pactl set-source-mute ${paname} 1
    notify-send -t 2000 -i ${icon_mute} "Microphone" "Muted"
else
    pactl set-source-mute ${paname} 0
    notify-send -t 2000 -i ${icon_unmute} "Microphone" "Unmuted"
fi
