#!/bin/bash

# Enable or disable application access to the MacOS webcam.

if [[ $EUID != 0 ]]; then
    echo "please run as root"
    exit
fi

declare -a components=(
    /System/Library/Frameworks/CoreMediaIO.framework/Versions/A/Resources/VDC.plugin/Contents/MacOS/VDC
    /System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/AVC.plugin/Contents/MacOS/AVC
    /System/Library/QuickTime/QuickTimeIIDCDigitizer.component/Contents/MacOS/QuickTimeIIDCDigitizer
    /Library/CoreMediaIO/Plug-Ins/DAL/AppleCamera.plugin/Contents/MacOS/AppleCamera
    /Library/CoreMediaIO/Plug-Ins/FCP-DAL/AppleCamera.plugin/Contents/MacOS/AppleCamera
)

if [[ $1 == on ]]; then
    for c in "${components[@]}"; do
        echo "enabling: $c"
        chmod 'a+r' "$c"
    done
elif [[ $1 == off ]]; then
    for c in "${components[@]}"; do
        echo "disabling: $c"
        chmod 'a-r' "$c"
    done
else
    echo "usage:"
    echo "  $0 on   enable the webcam"
    echo "  $0 off  disable the webcam"
fi
