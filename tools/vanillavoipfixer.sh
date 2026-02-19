#!/bin/bash
# edit the following path to your DCS core game directory.
PREFIX="/run/media/$USER/SN850X 2TB/games/dcs-world"
DCS_INSTALL_PATH="drive_c/Program Files/Eagle Dynamics/DCS World"


# documentation/explanation

# vanillavoipfixer comments out lines in dcs code to disable the vanilla voip, thus ensuring it doesnt crash on boot, mp lobby, or on connect to server.

# If you want to undo this script, uninstall your mods and
# repair the game files, then reinstall your mods. ( launch-dcs.sh -r )


if [ "$(id -u)" -eq 0 ]; then # ensure our scripts are never run as root
    echo "Please do not run scripts off the internet as root"
    exit 0
fi

if [ ! $# -eq 0 ]; then PREFIX=$1; fi
DCS_INSTALL="$PREFIX/$DCS_INSTALL_PATH"


if grep -q '	voice_chat.onPeerConnect(connectData)' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"; then # the leading space is to ensure no double-run
  sed -i 's|voice_chat.onPeerConnect(connectData)|-- REMOVED BY DoL SCRIPT --voice_chat.onPeerConnect(connectData)|' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"
fi



# voice_chat.onPeerConnect(connectData)
