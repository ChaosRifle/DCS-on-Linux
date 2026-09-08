#!/bin/bash
ver='1.0.0'

# edit the following path to your DCS core game directory.
PREFIX="/run/media/$USER/SN850X 2TB/games/dcs-world"

# DCS_INSTALL_PATH="drive_c/Program Files/Eagle Dynamics/DCS World"
DCS_SAVEGAMES_PATH="drive_c/users/$USER/Saved Games/DCS" # BUG this will not work for proton installs, as the user is 'steamuser'

# documentation/explanation

# startherefixer.sh changes the starthere auto-start to off, thus ensuring it doesnt freeze on boot.
# this is to fix the 'starthere bug' at https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#20260826-start-here-popup-wont-load-thus-prevents-main-menu-interaction

# If you want to undo this script, uninstall your mods and
# repair the game files, then reinstall your mods. ( launch-dcs.sh -r )


if [ "$(id -u)" -eq 0 ]; then # ensure our scripts are never run as root
    echo "Please do not run scripts off the internet as root"
    exit 0
fi

if [ ! $# -eq 0 ]; then PREFIX=$1; fi
# DCS_INSTALL="$PREFIX/$DCS_INSTALL_PATH"
DCS_SAVEGAMES="$PREFIX/$DCS_SAVEGAMES_PATH"

TASKS_COMPLETED='0'

if grep -q '		\["push_starthere"\] = true,' "$DCS_SAVEGAMES/Config/options.lua"; then # the leading space is to ensure no double-run
sed -i 's|\t\t\["push_starthere"\] = true,|\t\t\["push_starthere"\] = false,|' "$DCS_SAVEGAMES/Config/options.lua"
  TASKS_COMPLETED="$(($TASKS_COMPLETED + 1))"
  echo "startherefixer.sh changed starthere 'push_starthere' to false in options.lua"
fi

echo "startherefixer.sh has performed $TASKS_COMPLETED/1 tasks, done executing"
