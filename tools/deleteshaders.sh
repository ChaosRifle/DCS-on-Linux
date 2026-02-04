#!/bin/bash
# edit the following path to your DCS savedgames directory. 
PREFIX="/run/media/$USER/SN850X 2TB/games/dcs-world/"
DCS_INSTALL_PATH="/drive_c/users/$USER/Saved Games/DCS"  #/DCS.openbeta"


# documentation/explanation

# deleteshaders.sh will delete your dcs shaders (*not* to be confused with shader cache on linux when launching any proton game).
# ED recommends to do this every patch, however most users do not. If you see something weird or have horrible performance, try this.




if [ "$(id -u)" -eq 0 ]; then # ensure our scripts are never run as root
    echo "Please do not run scripts off the internet as root"
    exit 0
fi

if [ ! $# -eq 0 ]; then PREFIX=$1; fi
DCS_SAVEDGAMES="$PREFIX/$DCS_INSTALL_PATH"


rm -rf "$DCS_SAVEDGAMES/metashaders2/"
rm -rf "$DCS_SAVEDGAMES/fxo/"
mkdir "$DCS_SAVEDGAMES/metashaders2/"
mkdir "$DCS_SAVEDGAMES/fxo/"
