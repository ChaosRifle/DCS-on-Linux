#!/bin/bash
# edit the following path to your DCS savedgames directory. 
dcs_savedgames="/run/media/$USER/SN850X 2TB/games/dcs-world/drive_c/users/$USER/Saved Games/DCS.openbeta"

# ensure our scripts are never run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run scripts off the internet as root"
    exit 1
fi

rm -rf "$dcs_savedgames/metashaders2/"
rm -rf "$dcs_savedgames/fxo/"
mkdir "$dcs_savedgames/metashaders2/"
mkdir "$dcs_savedgames/fxo/"
