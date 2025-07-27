#!/bin/bash
# edit the following path to your DCS savedgames directory. 
DCS_SAVEDGAMES="/run/media/$USER/SN850X 2TB/games/dcs-world/drive_c/users/$USER/Saved Games/DCS.openbeta"

# ensure our scripts are never run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run scripts off the internet as root"
    exit 1
fi

rm -rf "$DCS_SAVEDGAMES/metashaders2/"
rm -rf "$DCS_SAVEDGAMES/fxo/"
mkdir "$DCS_SAVEDGAMES/metashaders2/"
mkdir "$DCS_SAVEDGAMES/fxo/"
