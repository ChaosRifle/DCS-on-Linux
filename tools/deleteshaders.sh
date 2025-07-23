#!/bin/bash
# edit the following path to your DCS savedgames directory. 
dcs_savedgames="/run/media/$USER/SN850X 2TB/games/dcs-world/drive_c/users/$USER/Saved Games/DCS.openbeta"

rm -rf "$dcs_savedgames/metashaders2/"
rm -rf "$dcs_savedgames/fxo/"
mkdir "$dcs_savedgames/metashaders2/"
mkdir "$dcs_savedgames/fxo/"
