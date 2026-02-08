#!/bin/bash
# edit the following path to your DCS core game directory.
PREFIX="/run/media/$USER/SN850X 2TB/games/dcs-world"
DCS_INSTALL_PATH="drive_c/Program Files/Eagle Dynamics/DCS World"


# documentation/explanation

# texturefixer.sh repairs ED's faulty textures - dependency of ImageMagick (usually pre-installed in most distro)

# this script breaks Integrity Check for Textures, if you fly that aircraft. IC sounds scary but all it does is prevent
# you from joining servers blocking that type, if already broken, or kick you to menu if you break it on-server.
# there are zero punishments for breaking IC, it is just there to keep files normal. This can happen normally to users by corrupted files. restart your game client
# and you will be able to rejoin just fine. if you want to undo this script to fly that aircraft on IC servers, uninstall your mods and
# repair the game files, then reinstall your mods

# This works by re-saving the files. This means any time you update/repair the game, you must run the script
# Long story short, ED screwed up and got off-by-one's in some files, others files.. we're not really sure why it fixes those, but it does.


if [ "$(id -u)" -eq 0 ]; then # ensure our scripts are never run as root
    echo "Please do not run scripts off the internet as root"
    exit 0
fi

if [ ! $# -eq 0 ]; then PREFIX=$1; fi
DCS_INSTALL="$PREFIX/$DCS_INSTALL_PATH"

BROKEN_FILES="Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/FontMPD_64.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/FontMPD_64_bold.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/FontMPD_64_inv.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/FontMPD_64_inv_bold.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/indication_MPD.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/indication_MPD_1024.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/indication_MPD_WPN.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/indication_MPD_WPN_fon.tga
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MFD_dark_green.dds
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MFD_gray.dds
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MFD_green.dds
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MFD_white.dds
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MPD_VideoSymbology.dds
Mods/aircraft/AH-64D/Cockpit/IndicationResources/Displays/MPD/MPD_VideoSymbology_font.dds
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_bg.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Fixed_Grid.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Grid_3x.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Grid_3x_backlight.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Grid_10x.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Grid_10x_backlight.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/9K113_Ready.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/ASP17_flex_sight.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/font_arcade.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/font_general.tga
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/GOST_BU.TTF
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/HelperAI_common.dds
Mods/aircraft/Mi-24P/Cockpit/IndicationTextures/PKV_Grid.tga
Mods/aircraft/Ka-50_3/Cockpit/IndicationTextures/SHKVAL_MASK.bmp
Mods/aircraft/FA-18C/Cockpit/IndicationResources/MDG/font_TGP_ATFLIR.tga"

while read -r file; do
    FULL_PATH="$DCS_INSTALL/$file"
    echo "Converting ${FULL_PATH}"
    cp "${FULL_PATH}" "${FULL_PATH}.original"
    convert "${FULL_PATH}" "${FULL_PATH}"
done <<< "$BROKEN_FILES"
