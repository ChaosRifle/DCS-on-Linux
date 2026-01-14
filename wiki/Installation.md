# If you encounter issues please check the [troubleshooting area](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting)

# Select an installation method:
- [Lutris](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#Lutris) [ recommended ]
- [Wine](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#Wine) [ incomplete ]
- [Steam](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#Steam) [ partially incomplete, not recommended, mildly more vr compatible ]




# Lutris
> [!warning]
> Something recently (2025-11-29) has broken lutris alternate launch args, so the DoL autoinstaller must use the dcs launcher for updates. Ensure you are not launching the game with ``--no-launcher``
> Currently, the launcher is only working with recent builds of wine staging, and confirmed with 10.15staging as working. Note that it may still launch black and recover after 1-3 minutes waiting on some configs.

- 1: we ***must*** select a lutris default runner before installation. Open 'Lutris Settings' [1] > 'preferences' [2] > 'Runners' [3] > 'Wine Options' [4] > set 'wine version' to a [known working runner](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#known-working-runners) [5] > 'save' [6]. Unfortunately, the YAML lutris uses will not allow us to define versions that are not in the API (or on your machine), so you must do this to ensure a functional version is used. Lutris needs to add more, and relevant, runners to wine in their API.
<img alt="lutris runner swap" src="https://github.com/user-attachments/assets/0388f8be-028b-4881-90cb-f6fe54a4a8ca" />

> [!note]
> - If you do not have runners you like, use [Proton Plus](https://github.com/Vysp3r/protonplus) or [ProtonUp-QT](https://davidotek.github.io/protonup-qt/) to install and manage runners easily.
> - Alternatively, drop runners in ```~/.local/share/lutris/runners/``` if you know what you are doing

> [!caution]
> - once the runner is selected and install has begun, do not change major versions (ie, wine to proton, or 9.x to 10.x, or vice versa. this can corrupt the prefix, so minor version changes only. you will need to reinstall (though you can copy the game files to not need to download it all again) to change major versions

- 2: by [website](https://lutris.net/games/dcs-world/) or lutris app, browse for add a game, 'DCS World', then select the '```wine``` **DoL Community Choice (Latest)**' version and press install.
<img alt="lutris install game instructions" src="https://github.com/user-attachments/assets/e6a76fbe-7c05-4651-9099-20636fa3fb8a" />

- 3: set your path here in the lutris menu, and absolutely nowhere else. DCS installer will ask if you want to change it later, you will leave the value as default.
<img alt="image" src="https://github.com/user-attachments/assets/85ab9027-ec4f-4738-8063-4e04500553c1" />

> [!caution]
> set your install path in the lutris window. DO NOT CHANGE THE PATH in the dcs installer window, leave that default!

- 4: follow installer prompts carefully if any are presented

> [!note]
> If the game is not launching to main menu now, check your runner from step 1, or proceed to [Troubleshooting](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting)

- 5: close your game client if you tested it, and go to [Finalizing install](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#finalizing-install), you are now nearly done!




# Wine
> [!note]
> this segment is incomplete

- X: go to [Finalizing install](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#finalizing-install), you are now nearly done!




# Steam


#### choose an install method:
- [standalone via steam](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#standalone-via-steam-add-non-steam-game) (add non-steam game) [ no gains but some prefer it, recommend using lutris or wine instead ]
- [dcs world steam edition](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#dcs-world-steam-edition-the-actual-steam-game) (the actual steam game) [incomplete]



## standalone via steam (add non-steam game)
> [!note]
> this segment is a stub, less support is offered for this method, and it is far more manually involved than other methods. please only choose this if you are okay with this, as support for this method is limited

- 1: manually download the game installer
- 2: in steam, click 'Add a Game' in the bottom left corner > 'Add non-steam game' > select your installer.exe. use a [known working runner](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#known-working-runners)
- 3: once it is done install, close it.
- 4: run [protontricks](https://github.com/Matoking/protontricks) to install ``d3dcompiler_47.dll`` to the prefix, or copy one from a windows box manually (vm's work for this)
- 5: in steam, set the working directory to the ``bin`` folder and edit the exe to use dcs.exe over dcs_updater.exe

> [!important]
> you must wrap both paths in double quotes, as they contain spaces

- 6: set your launch argument to ``WINE_SIMULATE_WRITECOPY=1 WINEDLLOVERRIDES='wbemprox=n' %command%``. Check [here](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#current-required-launch-arguments) for the latest info. you may also append `` --no-launcher`` to this command to skip the mostly useless launcher that may or may not even function (this can also be done via options.lua or options menu)
- 7: optionally repeat the add steam game and point it to the dcs_updater.exe with argument ``update``, and again for argument ``repair``
- 8: go to [Finalizing install](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#finalizing-install), you are now nearly done!



## dcs world steam edition (the actual steam game)
> [!note]
> this segment is incomplete

> [!warning]
> Latest versions of proton have broken the client. Using anything newer than ~ 10.17 appears to not work for most users.

> [!important]
> (date unknown) **Opentrack requires the game be installed to your home-folder drive**
> - opentrack proton appid hooking only works on the home-folder drive. it does **not** check other drives with steam app-manifests.
- X: right click the game in steam > ``Properties`` > ``General`` and set your launch options to ``WINE_SIMULATE_WRITECOPY=1 WINEDLLOVERRIDES='wbemprox=n' %command% --no-launcher``
- X: go to [Finalizing install](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#finalizing-install), you are now nearly done!




# Finalizing install
(highly recommended but not technically required to run the game)
#### contents:
- [Mod Manager](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#mod-manager)
- [Fixer scripts](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#Fixer-scripts)
- [SRS](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#srs)
- [Headtracking](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#Headtracking)
- [UDEV rules](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#UDEV-rules)

> [!caution]
> - It is ***highly*** recommended you use a mod manager if you will be modding the game ***at all***, due to both core DCS, and linux case-folding, issues. This is more serious than on windows - I(Chaos) would not recommend modding the game in any way, even saved-games, without a mod manager due to these problems. In some cases, troubleshooting can become near impossible.
> - Use of a mod manager will aid in installing other software, such as SRS hooks, make running of tools more convenient / easier to remember, and allow a clean install for each update to mitigate issues of DCS when patched.


## Mod Manager
We recommend [Limo](https://github.com/limo-app/limo). The flatpak will work just fine and has no known regressions over native. Limo is arguably the future of modding games on linux, and has a ton of functionality not used in this guide. For additional information, see their [wiki](https://github.com/limo-app/limo/wiki).

- 1: create a New Application [1]
<img alt="limo1" src="https://github.com/user-attachments/assets/4a652c54-57a9-4bf7-9489-959bf9e0966c" />

- 2: fill in the red mandatory fields - you want a Name[2] (your pick), and a Staging Directory[3]. Your staging directory will be where the mods are stored and limo holds its data to be able to cleanly un-mod your games. This should be unique per-game. you may want it on the same drive as your game if you intend to use hardlinks. Mine is ``../modding - limo/dcs staging`` for example, on the same drive as dcs is installed. Command[4] is optional and is used to launch the game. shown in the screenshot is the command to launch lutris and run the game. your number will be different, you can in-lutris, create a desktop icon and edit it to get the values. For steam installs, you would use the steam appid launch if you wanted this.
<img alt="limo2-3-4" src="https://github.com/user-attachments/assets/378e891a-8ab3-4a06-933b-22cd193ddb0c" />

- 3: select your ``Deployers`` tab [5], and then create a New Deployer[6]. This is how and where a mod gets put into the games files, effectively the directory to "copy" them to and method of doing so. We will make two of them, in steps 4 and 5. Deployers have types. For our purposes, ``Case Matching`` or ``Simple`` is of note. ``Case Matching`` solves the [case-folding](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#19700101-case-folding) problems, where simple treats it like you just copied the files in raw. If you use a case-folded game install (ext4 users, you would know if you have done this), it is safe to use simple to slightly speed up mod deployment - otherwise you should use Case-Matching. Deployment type can be Symlink, Hardlink, or Copy. Copy just copies the files over and increases file footprint, however if the files in the game dir are mistakenly modified (ex: you updated the game without uninstalling mods), copy will protect your mods from being mangled.
<img alt="limo 5-6" src="https://github.com/user-attachments/assets/a0893b39-e214-4753-b0be-bd743dbea84f" />

- 4: create a Saved Games deployer. name it how you like. Case matching unless case-folded FS. any Deployment Method here is acceptable, as accidental overwrite of the file is unlikely. I personally use Hard Link. This points to the DCS Saved Games root folder (in user), the screenshot shows the open beta version Saved Games folder.
<img alt="limo 6 5" src="https://github.com/user-attachments/assets/d1848d5d-0025-42a5-88f6-52fc3f408718" />

- 5: create a Core Files deployer. name it how you like. Case matching unless case-folded FS. I strongly recommend Copy deployment method as accidental overwrite is a very real possibility by updating the game without un-modding it. File sizes for core files mods are usually pretty small (texture packs, sound packs, small tweaks). This points to the DCS core game files root folder (in program files), the screenshot shows the open beta version Saved Games folder.
<img alt="limo 6 6" src="https://github.com/user-attachments/assets/72eeccfa-2705-444b-a45a-e7b565fd5954" />

> [!note]
> srs hooks mod contains an Export.lua, if you plan to use a custom one, you should edit that now before installing it in the next step example. If you dont know what that is, ignore this.

> [!note]
> You should install SRS hooks now if you intend to play multiplayer and use/hear voip, and are not going to put srs in your dcs prefix. The preferred way to install srs is to have its own prefix (not the dcs prefix).

- 6: installing mods can be done by drag and dropping the files into the Limo ``Mods`` or ``Deployers`` tab. When installing a mod, you will be able to choose the display-name [7] in limo, version [8], Root Level [9], Deployers [10] to add it to, and confirm [11]. Root Level [9] is a depth index, for how many folders deep to remove off the top (like lua's table.unpack()), effectively choosing which depth of sub-folder to "copy" to your deployment folder. With a deployer targeting /savedGames/dcs/ and a mod whos root folder is Liveries, this is the similar to copy pasting the Liveries folder to the /savedgames/dcs/. Red text in the folder tree UI means those files/folders will be stripped off the top, and the green will be used ("copied"). This is for mods that wrap themselves in a self-named folder that must be removed before placement in the game files. For SavedGames mods, the root level should corrospond such that the first green folder name would be a folder in /savedgames/dcs/, like ``Mods``, ``Scripts``, ``Liveries``, ``Kneeboard``, etc. For Core Files mods, this should be something like ``CoreMods``, ``Data``, ``API``, ``bin``, ``Mods``, ``Scripts``, etc. 
> We will use the SRS hooks mod supplied in this repo's code (``mods/srs hooks``) as a demo. First, drag and drop the entire ``srs hooks`` directory into the ``Mods`` or ``Deployers`` tab in Limo. Now fill in the details: choose any name you want ("srs hooks" in this example), version: ``2.1.1.0``, root level: ``0``, deployer is only: ``Savedgames``(or whatever you named it). Click "OK" to save it and move on to step 7. Note that the picture data is correct apart from version number, which may change in the future
<img alt="limo 7-11" src="https://github.com/user-attachments/assets/7cda1920-6729-4c5a-b9c2-e811689fcf16" />

> [!note]
> optionally, due to DCS [IC](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Knowledge-Base#ic-integrity-check), you may want multiple modlists if a mod denotes its breaks IC, and which IC it breaks. These are called Profiles in limo, at the top center of the main window. When you add a mod to a Deployer, you are doing that action on a per-Profile basis. Profiles allow you to have any permutation of IC pass or fail, or multiple modlists for playing with different groups. To add a new Profile, click the plus icon to the right of the Profile selection dropdown. To change Profiles, use the Profile select dropdown.

 - 7: enabling or disabling mods can be done by switching to the Deployers [12] tab and clicking ``Deploy`` or ``Undeploy`` [13]. Best practice is to undeploy before running a game update, **especially** if you have Core Files mods, and then deploy it once patched. DCS updates can corrupt mods, or modify them in ways that a mod manager wont expect. Typically savedgames mods are fine, however have been corrupted by updates rarely in the past.
<img alt="limo 12-13" src="https://github.com/user-attachments/assets/136bdddd-c8d1-4da5-a766-5286ced1d432" />

> creating a Limo mod: Limo mods are just a containing folder to name them, and within are the files that are laid out such that copying the files inside the naming folder to the install directory will function properly. so if ``modded file`` goes in ``/game/mods`` then you would make ``myfirstmod/modded file`` as the limo mod if your deployer pointed at the ``/game/mods`` folder

## Fixer scripts
> [!note]
> if you would like to know more about the scripts, they have documentation inside them. Best practice is to read scripts you download before executing them.

- 1: Under this repo's /tools folder, you will find the above scripts/fonts. download them or git clone the repo
- 2: ***edit the scripts*** to use your game paths
- 3: if using a tool like [Limo](https://github.com/limo-app/limo), you may opt to add these scripts to your App > Tools section to make remembering/launching them easier when you update the game.
- 4: run ``texturefixer.sh`` This breaks texture [IC](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Terminology#ic-integrity-check) when flying those aircraft.
- 5: AH-64 users [crashfix](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-slotting-into-ah-64d-apache-crashes-game): rename the included [note: not currently included. must find one we are allowed to] font file to ``seguisym.ttf`` or grab a copy of the real font from the internet, or a windows box in ``C:/Windows/Fonts``
- 6: AH-64 users [crashfix](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-slotting-into-ah-64d-apache-crashes-game): install the font file to your prefix's ``drive_c/windows/fonts/`` folder
> [!note]
> **you must run the texture fixer every time you update/repair the game**


## SRS
### SRS v2.3.4.0 (+)
> [!note]
> SRS v2.3.4.0 seems to work for some people, but it has not been throughouly tested. If the following does not work for you, revert to [v2.1.1.0](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#srs-v2110). Assuming you've installed Wine Staging 10.20 on your system, follow the below steps:

- 1: Create a new wine prefix (e.g. dcs-srs)
- 2: Download [.NET Desktop Runtime v 9.X](dotnet.microsoft.com/en-us/download/dotnet/9.0) - As of January 2026, 9.0.12 is the latest 9.X version.
- 3: Install the downloaded .NET Desktop Runtime
```bash 
WINEPREFIX=/path/to/new-prefix/dcs-srs wine /path/to/winedesktop-runtime-9.x.x-win-x64.exe
```
- 4: Download [SRS v2.3.4.0 installer](https://github.com/ciribob/DCS-SimpleRadioStandalone/releases) and extract it
- 5: Install SRS
```bash
WINEPREFIX=/path/to/new-prefix/dcs-srs wine /path/to/DCS-SimpleRadioStandalone-2.3.x.x/Installer.exe
```
- **UNCHECK the ``Install DCS Client Scripts`` box**
- 6: Open the ``prefix configuration`` [1] and go to ``Libraries`` [2]
```bash
WINEPREFIX=/path/to/new-prefix/dcs-srs winecfg
```
<img alt="srs-prefix-config" src="https://github.com/user-attachments/assets/9a3bb6f9-6c17-4904-9c9d-03491a84de93" />

- 7: From the ``New Override for Library`` [3],``add`` [4] the following libraries: ``icu``, ``icuin``, and ``icuuc`` [5].
- 8: For each ``library`` [6], ``edit`` [7] it, and make them  ``Native (Windows)`` [8-9]
<img alt="srs-set-libraries-native" src="https://github.com/user-attachments/assets/1f7504d1-8757-4a3d-9a92-52232ad6bf75" />

- 9: All the libraries should now show ``(native)`` [10], ``apply`` [11] the changes and ``ok`` [12] it.
<img alt="srs-all-library-overrides" src="https://github.com/user-attachments/assets/73117fb5-f3d0-4b60-a50a-977156f22c68" />

- 10: Install the hook files to your DCS "Saved Games" folder, preferably with a mod manager. If you have done so in the mod manager guides previously, skip this step.
- 11: Run SRS as normal either as normal wine program or add it to Lutris as a "Locally Installed Game". If using Lutris, set the runner as Wine, select the appropriate prefix from previous step and use "10.20 (Staging)" as Runner Options: Wine Version.
[you are now done with SRS, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#Headtracking)

### SRS v2.1.1.0
> [!caution]
> SRS v2.1.1.0 is the latest known working version for all people on linux, check [troubleshooting for info](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#20250525-srs-version-22xx-and-up-do-not-function)
> 
> [!warning]
> to get SRS v2.1.1.0 or earlier to run, Wine-GE-8.26 is known to work extremely reliably. Versions 9.x and 10.x have been very problematic for many users

> [!note]
> while not created by DoL, there is a lutris installer that lets you skip to step3 and luckily the runner SRS likes is native to lutris, so they were able to force its use. if you would like to try the automated installer for SRS, it is [here](https://lutris.net/games/dcs-simpleradio-standalone/). We provide no support for use of this, however it should work if you install the hooks from step3

- 1: download SRS's installer.exe from the SRS [releases](https://github.com/ciribob/DCS-SimpleRadioStandalone/releases)
- 2: choose to either use lutris to install it (remembering to set lutris' default wine runner), or wine standalone, and run the installer noting to UNCHECK the ``install dcs client scripts`` box if using a standalone prefix. This checkbox will work for same prefix, and if that is your method, you will want to keep it enabled
- 3: use the readme from srs to manually craft the hooks, or, download the ``mods/srs hooks`` folder from this repo
> [!note]
> use of a custom export.lua file will be overwritten by this. if you use a custom one, put those changes into this scripts/export.lua file now
- 4: if using a standalone prefix, install the hook files to your DCS 'saved games' folder, preferably with a mod manager. if you have done so in the mod manager guides previously, skip this step.
> [!caution]
> manual installation (no mod manager) is NOT recommended due to casefolding issues, and the rare dcs oddity. Please use a [mod manager](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager).


## Headtracking
#### Choose your headtracker:
- [opentrack linux](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#opentrack-linux) [ recommended for NON trackIR5 users ]
- [opentrack windows](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#opentrack-windows-inside-dcs-prefix) inside dcs prefix [ incomplete, sub-optimal ]
- [linuxtrack](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#linuxtrack) [ recommended for trackIR5 users ]
- other: the star-citizen Linux User Group maintains an excellent wiki on headtrackers, more info can be found on their wiki, [here](https://github.com/starcitizen-lug/knowledge-base/wiki/Head-Tracking)

### opentrack linux
- install opentrack from [its repo](https://github.com/opentrack/opentrack/wiki/Building-on-Linux), the AUR, or the [SC-LuG version](https://github.com/Priton-CE/opentrack-StarCitizen/blob/master/README.md) that has extra features/fixes (mainly umu). Follow the instructions provided at those links for the installation process, and continue here for setup

> [!note]
> the images provided in the next segment are using a build from SC-LuG, if your UI looks slightly different, that is why.

#### select how your game was installed:
- [wine](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#wine-runner) runner
- [umu](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#umu-proton-runner) runner
- [steam](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#steam-runner) runner

#### wine runner
- 1: select your input method[1] (how you detect your head)
- 2: select output method of``Wine -- Windows layer for Unix``[2]
- 3: open the output method configuration menu[3]
- 4: select the identical version of wine[4] your game install uses.
- 5: point opentrack to your game prefix[5]
- 6: set esync and fsync[6] to be identical to your game installs configuration (usually both enabled)
- 7: select the output protocol[7] that your game should see. (usually this is ``Both``)
<img alt="opentrack wine" src="https://github.com/user-attachments/assets/63b2e1ef-6506-4cda-b41a-cfcc312384a9" />

> [!note]
> Browse Wine path can be unreliable. Opentrack itself may detect your input, but it may not work in-game. 

[you are now done with headtracking, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)


#### umu proton runner
- 1: select your input method[1] (how you detect your head)
- 2: select output method of``Wine -- Windows layer for Unix``[2]
- 3: open the output method configuration menu[3]
- 4: select the identical version of proton[4] your game install uses.
- 5: point opentrack to your game prefix[5]
- 6: set esync and fsync[6] to be identical to your game install's configuration (usually both enabled)
- 7: select the output protocol[7] that your game should see. (usually this is ``Both``)
- 8: set your game client launch parameters to have the umu PROTON_VERB environment variable ``PROTON_VERB=runinprefix`` ``GAMEID=umu-dcs``
<img src="https://github.com/user-attachments/assets/8aa92951-fb5e-4637-9c4c-13ac34e7afa9" />

[you are now done with headtracking, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)


#### steam runner
> [!caution]
> opentrack appid hooking is flawed, see [troubleshooting](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-opentrack-requires-the-game-be-installed-to-your-home-folder-drive)

- 1: select your input method[1] (how you detect your head)
- 2: select output method of``Wine -- Windows layer for Unix``[2]
- 3: open the output method configuration menu[3]
- 4: select the identical version of proton[4] your game install uses.
- 5: set the steamapp id for dcs[5] (223750)
- 6: set esync and fsync[6] to be identical to your game install's configuration (usually both enabled)
- 7: select the output protocol[7] that your game should see. (usually this is ``Both``)
<img alt="opentrack steam" src="https://github.com/user-attachments/assets/d764df23-3327-4ecb-bec3-d644ca35a2a1" />

[you are now done with headtracking, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)


### opentrack windows inside dcs prefix
> [!note]
> this segment is incomplete

> [!tip]
> this method has significant overhead compared to native, especially for cpu heavy stuff like ai-track.
> if you *must* use this because native is somehow broken *and* you want to use cpu-heavy features, running both native and windows in prefix by using UDP input on windows and UDP output on native will actually be lighter weight overall and thus your game will run with higher fps. we recommend avoiding in-prefix windows opentrack where possible but acknowledge native does break, necessitating this

- 1: download windows opentrack installer from the [releases](https://github.com/opentrack/opentrack/releases)
- 2: run the installer exe inside the prefix of your game install
- 3: [ incomplete ]

[you are now done with headtracking, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)


### linuxtrack
- 1: download or build the appimage of fwfa123's fork of uglydwarf's linuxtrack [here](https://gitlab.com/fwfa123/linuxtrackx-ir/-/releases)
- 2: edit the properties of the appimage file with ```alt+enter``` or ```chmod``` and make the file ```executable```
- 3: run the appimage. You will be prompted if you have your trackir5 plugged in to authorize it to automatically create udev rules for the device if you currently lack them, and ask you to enter your sudo password. If you are not comfortable with this, Linuxtrack should provide information on doing this manually as well, or jump to the [UDEV rules](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules) section to import our TrackIR rules or create your own. Please remeber to reload udev rules and re-plug your device, or, restart your system, when modifing udev. the changes will not take effect until you do.
- 4: under the ```gaming``` tab, you will see the ```prerequisites``` section with [trackir firmware](https://www.trackir.com/downloads/) and [mfc42 libraries](https://download.microsoft.com/download/vc60pro/Update/2/W9XNT4/EN-US/VC6RedistSetup_deu.exe), you will need both. go through the install proccess for these.
- 5: in the ```Gaming``` tab, select ```Custom Prefix``` and point to your game prefix. At time of writing, Steam and Lutris did not work correctly (please notify a maintainer if this has changed)
- 6: Configure linuxtrack with your respective hardware under ```device setup``` and ```model setup```, ensuring to save changes at the bottom right.
- 7: Configure profiles in the ``Tracking Setup`` tab. be warned linuxtrack creates new profiles per game, so you will want to edit the default and then remember to ``copy from default`` on that game profile later when you run the game, or your changes here will be ignored.
> [!tip]
> if you are having tracking issues, adjust the settings in device setup, lowering blob size minimum to ~30 helps immensely
> if you are having connetivity issues to the game, try launching and starting linuxtrack before the game is running. Some games only hook headtrackers at launch.

[you are now done with headtracking, handy link to next section](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#udev-rules)


## UDEV rules
udev rules are used to set permissions and operation mode of a device.

- 1: use a premade udev rule, or, create a new file named ``97-yournamehere.rules`` (the number defines load order, just set it in the 90's)
> [!tip]
> the repo contains pre-made rules in the repo's ``udev`` folder
- 2: edit the rule to work for your device if needed (please let us know if pre-made rules do not work on your hardware), where idVendor & idProduct are your $VID & $PID. documentation for udev [here](https://www.man7.org/linux/man-pages/man7/udev.7.html). If you need help, join the [matrix](https://matrix.to/#/#dcs-on-linux:matrix.org) server. your file contents should look similar to the following:
```
# Custom Joystick Udev Rules

# Virpil
ACTION=="add", \
  ATTRS{idVendor}=="3344", ATTRS{idProduct}=="*", \
  MODE="0660", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess", \
  RUN+="/usr/bin/evdev-joystick --e %E{DEVNAME} --d 0"
```

> [!tip]
> to identify your stick/throttle/pedals VID:PID, run ``lsusb`` in terminal. the output will look like the following: ``Bus ### Device ###: ID $VID:$PID $DeviceName``

- 3: move the file into ``/etc/udev/rules.d/``
- 4: reload your rules by running ``udevadm control --reload && udevadm trigger`` in terminal. you will need to replug your devices. Alternatively, restart your system.

> [!tip]
> If you experience further issues with input devices, check [joystick troubleshooting](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#joystick-issues) for more info

# You are now done, enjoy your flights! You may opt to check out [Optional Extras](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#optional-extras)




# Optional Extras
#### contents:
- [Voice activation](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#voice-activation) [ incomplete ]
- [joystick utilities](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#joystick-utilities) [ incomplete ]
- [VR](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#vr) [ incomplete ]

## Voice Activation
> [!note]
> this segment is incomplete

#### Choose your voice input software:
- [LinVAM](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#LinVAM) [ incomplete ]
- [VoiceAttack with modified speech model](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#VoiceAttack-with-modified-speech-model) [ partially incomplete ]

#### LinVAM
linVAM is a community project, housed [here](https://github.com/stele95/LinVAM)

#### [VoiceAttack](https://voiceattack.com/) with modified speech model
> [!tip]
> VA is not free, nor is it made for linux. if you want to go this route, please use the trial to ensure you are satisfied with the results.

- until someone has time to make a proper writeup here, vsTerminus has a great writeup on this [here](https://gist.github.com/vsTerminus/bf4f0247d75b7c0b747ab04bb34a0999)

## Joystick Utilities
> [!note]
> this segment is incomplete

## VR
> [!warning]
> this segment is incomplete and highly volatile, what works for one headset may not work for others. Here be dragons. Please report and successes or failures to maintainers via an issue or matrix server ping. If you would like to help work on this section, please refer to the [issue](https://github.com/ChaosRifle/DCS-on-Linux/issues/2) for vr data.
#### contents:
- [Envision with WiVRn](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#envision-with-wivrn) [ inccomplete, recommended ]
- [ALVR](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#ALVR) [ incomplete ]
- [OpenXR](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation/#OpenXR) [ incomplete ]

#### Envision with WiVRn
some of our penguins recommend the usage of wivrn using [envision](https://lvra.gitlab.io/docs/fossvr/envision/). And the usage of these launch args `WINEJOYSTICK=0 WINEDLLOVERRIDES='wbemprox=n' PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1  %command% --no-launcher --force_enable_VR --force_OpenXR`.

#### ALVR

#### OpenXR
