#### contents:
- [Information](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Knowledge-Base/#information)
- [Terminology](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Knowledge-Base/#terminology)



#
# Information
#
## changing game branch
- on steam, just use the 'game > properties > betas > beta participation' dropdown menu
- for all other install types, launch the updater like so: ``DCS_updater.exe update @openbeta`` where @openbeta is the branch you want to change your install to. This can be any arbitrary string, and if your account has access to a branch of that name, it will install it, if not, it will default to stable. This means you could use ``DCS_updater.exe update @linux`` and your savedgames folder would now be ``DCS.linux`` and your game files would be ``DCS World linux``, but run the stable, windows, branch of the game due to no branch existing named 'linux'.
> [!note]
> - doing this will change your clients binaries filepaths, so you will need to update this for lutris and wine installs. 
> - [incomplete, testing needed] for lutris, we use multiple launch params, which can't all be modified with the gui. ``~/.local/share/lutris/games/DoL-Community-Choice-(Latest)-##########.yml`` may contain some of the values you need to change to fix this




#
# Terminology
#
# DCS terms:
### IC (integrity check)
### ED (eagle dynamics, developer of the game)
### SRS (Simple Radio Standalone, by Ciribob)

# Linux terms:
### case-folding (case-insensitivity for file systems)
linux is case sensitive, while windows is case IN-sensitive. This means we can have file.txt and File.txt in the same folder
See [Troubleshooting](https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#19700101-case-folding) for solutions.

# Limo terms:

# Lutris terms:

# Wine terms:

# Proton terms:
> [!note]
> proton **IS** wine, modified. everything from wine mirrored in proton. 
### UMU (standalone proton)
umu proton is just proton bundled up with the steam runtime (sniper at time of writing) so it can run standalone without steam itself. basically just proton when run on a non-steam game