#!/bin/bash
ver='1.0.3'

# edit the following path to your DCS core game directory.
PREFIX="/run/media/$USER/SN850X 2TB/games/dcs-world"
DCS_INSTALL_PATH="drive_c/Program Files/Eagle Dynamics/DCS World"


# documentation/explanation

# vanillavoipfixer comments out lines in dcs code and renames a dll to disable the vanilla voip, thus ensuring it doesnt crash on boot, mp lobby, on connect to server, or when slotting into an aircraft.
# this is to fix the 'voip bug' at https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-voip-bug-dcslog-cites-voip-related-stuff-game-broken-in-various-ways

# If you want to undo this script, uninstall your mods and
# repair the game files, then reinstall your mods. ( launch-dcs.sh -r )


if [ "$(id -u)" -eq 0 ]; then # ensure our scripts are never run as root
    echo "Please do not run scripts off the internet as root"
    exit 0
fi

if [ ! $# -eq 0 ]; then PREFIX=$1; fi
DCS_INSTALL="$PREFIX/$DCS_INSTALL_PATH"

TASKS_COMPLETED='0'

if grep -q '	voice_chat.onPeerConnect(connectData)' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"; then # the leading space is to ensure no double-run
  sed -i 's|voice_chat.onPeerConnect(connectData)|-- REMOVED BY DoL SCRIPT --voice_chat.onPeerConnect(connectData)|' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"
  TASKS_COMPLETED="$(($TASKS_COMPLETED + 1))"
  echo "vanillavoipfixer.sh removed 'onPeerConnect' line from mul_voicechat.lua"
fi

if grep -q '			voice_chat.changeSlot(playerInfo.side, unitId)' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"; then # the leading space is to ensure no double-run
  sed -i 's|voice_chat.changeSlot(playerInfo.side, unitId)|-- REMOVED BY DoL SCRIPT --voice_chat.changeSlot(playerInfo.side, unitId)|' "$DCS_INSTALL/MissionEditor/modules/mul_voicechat.lua"
  TASKS_COMPLETED="$(($TASKS_COMPLETED + 1))"
  echo "vanillavoipfixer.sh removed 'changeSlot' line from mul_voicechat.lua"
fi

if [[ -f "$DCS_INSTALL/CoreMods/services/VoiceChat/bin/VoiceChat.dll" ]]; then
  mv "$DCS_INSTALL/CoreMods/services/VoiceChat/bin/VoiceChat.dll" "$DCS_INSTALL/CoreMods/services/VoiceChat/bin/VoiceChat-DISABLED.dll"
  TASKS_COMPLETED="$(($TASKS_COMPLETED + 1))"
  echo "vanillavoipfixer.sh renamed 'VoiceChat.dll' to 'VoiceChat-DISABLED.dll'"
fi

echo "vanillavoipfixer.sh has performed $TASKS_COMPLETED/3 tasks, done executing"
