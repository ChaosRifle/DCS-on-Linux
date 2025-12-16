# Live chat [matrix](https://matrix.to/#/#dcs-on-linux:matrix.org) community for any and all questions
#### contents:
- [Lutris issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#lutris-install-issues)
- [Wine issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#wine-install-issues)
- [Steam issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#steam-install-issues)
- [Joystick issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#joystick-issues)
- [Headtracking issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#headtracking-issues)
- [SRS issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#srs-issues)
- [Linux issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#linux-issues)
- [DCS issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#dcs-issues)
- [AMD issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#amd-issues)
- [NVidia issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#nvidia-issues)
- [VR issues](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#vr-issues)
- [Troubleshooting steps](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#troubleshooting-steps)
- [Troubleshooting resources](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#troubleshooting-resources)

# Lutris install issues
> [!important]
> #### (date unknown) **lutris fails to launch game after install when un-checking install files now**
> - unchecking "install files now" during the installation process will require you to manually run the updater, because the lutris installer we provide uses dcs.exe instead of dcs_updater.exe. While we do provide an alt-launch config for updating, if the main exe is not there, lutris has a bug where it never offers the alt-launch menu 
> - To fix this: put the dcs.exe file in the right spot. either move a copy of the game files into the prefix, or, click ``DCS World`` in Lutris > ``up arrow to the right of the wine icon`` > ``run EXE inside Wine prefix`` > Choose ``DCS_updater.exe`` in the game directory and run the updater manually. alternatively, delete the prefix/files and resintall via lutris without unchecking the install files button.
> <img width="285" height="208" alt="image" src="https://github.com/user-attachments/assets/934fb4bc-166b-473c-b02c-beea9830f731" />

# Wine install issues

# Steam install issues
> [!important]
> #### (date unknown) **permanent crashing after a single crash**
> - If your game crashes in the Steam version, it will permanently fail to start after that. 
> - remove ``prefix/drive_c/system32/lsteamclient.dll``. It was created in the crash, the game should start back up fine after its gone.

> [!important]
> #### (date unknown) **crash on F10 keystroke**
> - the issue is with the F10 keybind specifically. change the keybind.

> [!important]
> #### (date unknown) **crash on opening communication issue**
> - the issue is with the keybind specifically. change the keybind.

> [!important]
> #### (date unknown) **module disabled by user**
> - caused by porting a standalone config to steam. ``$CONFIG_DIR/enabled.lua`` as reported by deleterium, just delete it for steam use.

# Joystick issues
> [!important]
> #### (date unknown) **joysticks report as xinput / only partially work**
> - cause: device is not using dinput (direct input) on wine, it is defaulted to xinput because the PID/VID has not explicitly been recognized. this is an issue in wine, and thus, proton too
> - open Wine Control Panel > Game Controllers > in joystick tab, click the 'override' button to move the devices from 'xinput' to 'connected'. it should now register in the DInput tab. to open this on the steam version ```protontricks -c "wine control" 223750```, on lutris open the ```Wine Control Panel```
> - if this happens to you, please also run ```lsusb``` and give the results for that device as well as the devices name and brand to a maintainer so we can be fix it for you and other users in future versions of Wine.

# Headtracking issues
> [!important]
> #### (date unknown) **Opentrack requires the game be installed to your home-folder drive**
> - opentrack proton appid hooking only works on the home-folder drive. it does **not** check other drives with steam app-manifests.
> - if you intend to use opentrack, you **must** use your home folder drive with steam. (``~/.steam/steam/steamapps/common/``)

# SRS issues
> [!important]
> #### (2025/05/25) **srs version 2.2.x.x and up do not function**
> - the dotnet8 refactor appears to have removed the fix from [issue 621](https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/621), resulting in it no longer working. other info can be found in the srs discord on [this thread](https://discord.com/channels/298054423656005632/1391492248574885918), and the [new issue is here](https://github.com/ciribob/DCS-SimpleRadioStandalone/issues/800).
> - Possibly fixed as of 2.3.0.1, user reports vary, needs further testing and information

# Linux issues
> [!important]
> #### (1970/01/01) **[case-folding](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Terminology#case-folding-case-insensitivity-for-file-systems)**
> - use of a mod manager or case-folding filesystem/directory can help avoid crashes and bugs when you modify your files. Troubleshooting this is next to impossible, so preventative action like use of a mod manager or specialized filesystem is critical. 
> - this can cause bugs or crashes the moment you modify your game files. Windows games expect only one file of a given name to exist, however when you paste files in a directory, sometimes a user didnt use an identical capitalization. This means the game gets both, and can run the wrong file, or, crash. 

> [!important]
> #### (date unknown) **input devices not showing up in DCS, even though it shows in game controller testing applications?**
> - UDEV rules, documentation [here](https://www.man7.org/linux/man-pages/man7/udev.7.html) and guide [here](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)

> [!important]
> #### (date unknown) **input devices working at all on linux, but functions on other machines**
> - UDEV rules, documentation [here](https://www.man7.org/linux/man-pages/man7/udev.7.html) and guide [here](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)

# DCS issues
> [!important]
> #### (2024/07/12) **game launches to a black window**
> - this is the launcher, it doesn't render properly. use launch parameter '--no-launcher' or an options.lua 

> [!important]
> #### (date unknown) **game launches to a black screen entirely or multiplayer crashes on connect, dcs.log cites voice chat related things**
> - this is the native voice chat. uncommon issue, fix must be reapplied every time the file(not the game) gets an update. this will disable your vanilla voip entirely, but its crap and everyone uses SRS so its no real loss. One user was able to fix this issue by reinstalling, with a possible change to runner or other supporting tool fixing it. The cause of the fix is still unclear, if you figure it out PLEASE notify a maintainer or open a github issue, thank you.
> - for the on-boot issue: comment out ``../drive_c/Program Files/Eagle Dynamics/DCS World/MissionEditor/modules/Options/optionsDb.lua`` lines 118-131 (``local function getVoiceChatDevices``) and line 455 (``sound('voice_chat'):setValue(true):checkbox()``). These line numbers are not always exact, updates change them. The text itself should be the same and in a roughly similar area of the files. If these numbers change, please notify a maintainer with the new line numbers.
> - for the on-mp-connect issue: comment out ``../drive_c/Program Files/Eagle Dynamics/DCS World OpenBeta/MissionEditor/modules/mul_voicechat.lua`` line 2440 (``voice_chat.onPeerConnect(connectData)``)
> - please note this information was derived itteratively with two different bugs on an uncommon issue that cant be reproduced, this may require both actions performed to rectify one or both of these issues. Please notify a maintainer with your results if you are affected.
> <img alt="voip bug 1" src="https://github.com/user-attachments/assets/450e4fe8-4b64-42eb-a099-a117cc646aa6" />
> <img alt="voip bug 2" src="https://github.com/user-attachments/assets/2a3fae47-9dfd-415d-8229-3b995a627164" />
> <img alt="voip bug 3" src="https://github.com/user-attachments/assets/114949a1-2069-4892-9ed6-60452ded3a73" />


> [!important]
> #### (date unknown) **puffy non-continuous contrails and smoke trails**
> - Currently unfixable, however there is a lead on starting opentrack in the same prefix, first, somehow fixing it, but turning the entire game green. Investigation required. Current work to resolve this [here](https://github.com/doitsujin/dxvk/issues/4327#issuecomment-3109439142).
> - (2025/08/07) steam version running Proton Experimental appears to fix this issue now

> [!important]
> #### (2024/05/21) **jester ui and other heatblur functions are broken (hbui.exe)**
> - this all uses a separate .exe running an overlay, see [currently required launch args](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#current-required-launch-arguments).

> [!important]
> #### (2025/11/28) **Full fidelity MiG-29 Flanker crashes on startup**
> - Install `vcrun2015`

> [!important]
> #### (date unknown) **error 500 when launching the game**
> - this is caused by system clock being off from what is expected by looking at your IP address. 
> - If you duel-boot, set your bios to use UTC and ensure windows uses offset to UTC instead of the bios clock. (search for "How to Fix Windows and Linux Showing Different Times" if you don't know how to)

> [!important]
> #### (date unknown) **missing textures**
> - see [Fixer Scripts](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#fixer-scripts). some files are saved incorrectly and have off-by-ones in the formats. (256 values for 0-255 fields, as an example), others were not sure why. re-saving them fixes this but breaks [Texture IC](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Knowledge-Base#ic-integrity-check). You will need to run the fixer script every time you update/repair the game.

> [!important]
> #### (date unknown) **fx_5_0 error shaders not compiling**
> - d3dcompiler_47.dll is missing. winetricks or protontricks it.

> [!important]
> #### (date unknown) **can log in but have black screen on game start (not launcher)**
> - copy ``$CORE_FILES/bin/webrtc_plugin.dll`` to ``$CORE_FILES/webrtc_plugin.dll`` or create a symlink

> [!important]
> #### (date unknown) **game wont launch**
> - WINEDLLOVERRIDES are needed, specifically ``wbemprox=n`` and in rare cases ``msdmo=n``. see [current required overrides](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#current-required-launch-arguments) for the usual list.

> [!important]
> #### (date unknown) **slotting into AH-64D Apache crashes game**
> - missing font ``seguisym.ttf``, either get a copy from a VM/box/internet (stored in ``C:/Windows/Fonts``) or rename an existing font with the required symbols
> - install the font file to your prefix's ``drive_c/windows/fonts/`` folder

# AMD issues

> [!important]
> (date unknown) **screen flashes black every couple of frames**
> - This is a known problem with RDNA3 based AMD GPUs. It can be fixed by adding ``RADV_DEBUG=llvm`` to your launch parameters.

> [!important]
> (date unknown) **framerate goes down after opening F10 map**
> - the map loads a bunch of textures, this is probably vram exhaustion you are experiencing. lower your settings or try to run on wined3d to see if it helps. wined3d has its own issues. steam param: ``PROTON_USE_WINED3D=1``

# Nvidia issues

> [!important]
> (date unknown) **vram exhaustion issues causing severe FPS drops**
> - there is no known fix for the exhaustion issues, as DCS doesn't respect requests to limit VRAM properly. 
> - mitigation is possible by lowering VRAM requirements with inferior textures. 

# VR issues

# Troubleshooting steps
## known working runners:
#### Lutris / Wine
- Proton 9.27 GE
- Wine 10.12
#### Steam
- Proton Experimental (2025/07/27)


## current required launch arguments
- ``WINE_SIMULATE_WRITECOPY=1`` for F4's hbui.exe to work correctly
- ``WINEDLLOVERRIDES='wbemprox=n'`` for .. some reason. If you remember, ping chaos or open a PR.

## Logs
- dcs: ``drive_c/users/$USERNAME/Saved Games/DCS World/Logs/dcs.log``
- proton: set env vars ``PROTON_LOG=1`` and ``PROTON_LOG_DIR=$path-to-desired-directory/`` to dump to said location


# Troubleshooting resources
### a list of all the recommended information currently available (@ me or make a PR if you find something useful!)
If something is missing, it is probably deliberately left out.
- Budderpards [guide](https://github.com/budderpard/DCS_Standalone_on_linux/tree/master?tab=readme-ov-file)
- live chat [matrix](https://matrix.to/#/#dcs-on-linux:matrix.org) community if this page or the above guide does not work
- Deleterium's [updated](https://github.com/deleterium/dcs_on_linux) version of zoq2's guide

old resources that contain older, less useful, or duplicate information, but may be of use for extended troubleshooting in edge cases.
- hoggit [wiki](https://wiki.hoggitworld.com/view/DCS_on_linux)
- proton [issues](https://github.com/ValveSoftware/Proton/issues/1722) if you are in a pinch, a pain to search but occasionally useful
