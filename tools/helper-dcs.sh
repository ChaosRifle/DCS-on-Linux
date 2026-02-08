#!/bin/bash
ver='0.0.2'
# a small portion of this script was taken from the SC LUG Helper on 26/01/27 and cannot be relicensed until removed. get_latest_release() was taken from their GPLv3 source. The rest was written by Chaos initially.


###################################################################################################
#block root use, keep this as the FIRST lines of code in the script
###################################################################################################
if [ "$(id -u)" -eq 0 ]; then
  echo 'You have run this as root, please dont run scripts off the internet as root.'
  exit 0
fi


###################################################################################################
#variables and config
###################################################################################################
disable_zenity=0
use_zenity=0
dir_cfg="/home/$USER/.config/dcs-on-linux"
cfg_dir_prefix="prefix.cfg"
cfg_firstrun="firstrun.cfg"
cfg_preferred_dir_wine="preferred_wine.cfg"

      dir_prefix="" #/home/$USER/games/dcs-world #set default FIXME ensure this actually works

subdir_dcs_corefiles="drive_c/Program Files/Eagle Dynamics/DCS World"
subdir_dcs_savedgames="drive_c/users/$USER/Saved Games/DCS"


###################################################################################################
#urls
###################################################################################################
url_dcs='https://www.digitalcombatsimulator.com/upload/iblock/959/d33ul8g3arxnzc1ejgdaa8uev8gvmew2/DCS_World_web.exe'
file_dcs='DCS_World_web.exe'

url_srs='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.1.1.0/DCS-SimpleRadioStandalone-2.1.1.0.zip'
file_srs='DCS-SimpleRadioStandalone-2.1.1.0.zip'

url_srs_latest='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.3.4.0/DCS-SimpleRadioStandalone-2.3.4.0.zip'
file_srs_latest='DCS-SimpleRadioStandalone-2.3.4.0.zip'



url_wine_9='https://github.com/Kron4ek/Wine-Builds/releases/download/9.22/wine-9.22-amd64.tar.xz'
file_wine_9='wine-9.22-amd64.tar.xz'
dir_wine_9='wine-9.22-amd64'

url_wine_9_staging='https://github.com/Kron4ek/Wine-Builds/releases/download/9.22/wine-9.22-staging-amd64.tar.xz'
file_wine_9_staging='wine-9.22-staging-amd64.tar.xz'
dir_wine_9_staging='wine-9.22-staging-amd64'

url_wine_10='https://github.com/Kron4ek/Wine-Builds/releases/download/10.20/wine-10.20-amd64.tar.xz'
file_wine_10='wine-10.20-amd64.tar.xz'
dir_wine_10='wine-10.20-amd64'

url_wine_10_staging='https://github.com/Kron4ek/Wine-Builds/releases/download/10.20/wine-10.20-staging-amd64.tar.xz'
file_wine_10_staging='wine-10.20-staging-amd64.tar.xz'
dir_wine_10_staging='wine-10.20-staging-amd64'

url_wine_11='https://github.com/Kron4ek/Wine-Builds/releases/download/11.1/wine-11.1-amd64.tar.xz'
file_wine_11='wine-11.1-amd64.tar.xz'
dir_wine_11='wine-11.1-amd64' #known bad due to 'debugger detected'

url_wine_11_staging='https://github.com/Kron4ek/Wine-Builds/releases/download/11.1/wine-11.1-staging-amd64.tar.xz'
file_wine_11_staging='wine-11.1-staging-amd64.tar.xz'
dir_wine_11_staging='wine-11.1-staging-amd64' #known good



url_dol='https://github.com/ChaosRifle/DCS-on-Linux'
url_troubleshooting='https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting'
url_matrix='https://matrix.to/#/#dcs-on-linux:matrix.org'


###################################################################################################
#constants
###################################################################################################
array_files_dxvk=( # files shipped with dxvk that need to be removed from registry when modifying setup. check latest git release for filenames.
  "d3d8"
  "d3d9"
  "d3d10core"
  "d3d11"
  "dxgi"
)


###################################################################################################
#function defines
###################################################################################################
check_dependency() { #startup dep-check
 selftest='pass'
  if [ ! -x "$(command -v wine)" ]; then selftest='fail'; echo 'ERROR: WINE MISSING'; fi
  #if ! command -v winetricks > /dev/null 2>&1; then selftest='fail'; echo 'ERROR: WINETRICKS MISSING'; fi
  if [ ! -x "$(command -v winetricks)" ]; then selftest='fail'; echo 'ERROR: WINETRICKS MISSING'; fi #FIXME this is broken in script but not in terminal. what the heck is going on?!
  if [ ! -x "$(command -v git)" ]; then selftest='fail'; echo 'ERROR: GIT MISSING'; fi
  if [ ! -x "$(command -v wget)" ]; then selftest='fail'; echo 'ERROR: WGET MISSING'; fi
  if [ ! -x "$(command -v curl)" ]; then selftest='fail'; echo 'ERROR: CURL MISSING'; fi
  if [ ! -x "$(command -v cabextract)" ]; then selftest='fail'; echo 'ERROR: CABEXTRACT MISSING'; fi
  if [ ! -x "$(command -v unzip)" ]; then selftest='fail'; echo 'ERROR: UNZIP MISSING'; fi
  if [ ! -x "$(command -v touch)" ]; then selftest='fail'; echo 'ERROR: touch missing'; fi
  if [ ! -x "$(command -v mkdir)" ]; then selftest='fail'; echo 'ERROR: mkdir missing'; fi
  if [ ! -x "$(command -v chmod)" ]; then selftest='fail'; echo 'ERROR: chmod missing'; fi
  if ! grep -q "avx" /proc/cpuinfo; then selftest='fail'; echo 'ERROR: your cpu doesnt support avx'; fi

  if [ ! $selftest = 'pass' ]; then echo 'dependency check failed, exiting..' ; exit 0; fi

  if [ ! "$disable_zenity" -eq 1 ]; then
    if [ -x "$(command -v zenity)" ]; then
      if zenity --version >/dev/null; then
        use_zenity=1
      else #zenity busted
        use_zenity=0
      fi
    else #zenity not installed
      use_zenity=0
    fi
  fi
}

stringify_menu() { #TODO unwritten - for auto generating terminal menus from zenity arrays
  dummy=0
}

query() { #TODO unwritten - for generating multiple choice menus (and possible checklist menus later?)
  if [ $use_zenity = 1 ]; then
    dummy=0
  else
    dummy=0
  fi
}

query_filepath() { #TODO unwritten - for asking the user for a filepath
  if [ $use_zenity = 1 ]; then
    dummy=0
  else
    dummy=0
  fi
}

notify(){ #TODO unwritten - for generating information click-thorugh (or just an echo for terminal) dialogues
  if [ $use_zenity = 1 ]; then
    dummy=0
  else
    dummy=0
  fi
}

confirm(){ #TODO unwritten - for generating confirmation 'are you sure, this will do X' dialogues
  if [ $use_zenity = 1 ]; then
    dummy=0
  else
    dummy=0
  fi
}

format_urls() { #TODO unwritten - for dynamically generating menu hyperlinks and possibly disk links, in conjunction with message() or others
  local dummy=0
}

select_prefix(){ #TODO: fix cancel button returning dir of '' beause cancel just sets empty var. exit script or return to menu if done!. install_dcs() has the same problem. use menu_main() handeling for zenity nil reply
  if [ $use_zenity = 1 ]; then
    dir_prefix="$(zenity --file-selection --directory --title="Select your DCS prefix")" #-filename="$wine_prefix/$default_install_path" 2>/dev/null)"
  else
    read -p "enter the full path to your DCS prefix
    " dir_prefix
    if [ ! -d "$dir_prefix" ]; then echo 'the path you specified could not be found. You should try again..' ; fi
  fi
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"

  menu_main
}

install_dcs(){ #TODO - hardcoded for wine 11, add switching later. Also has issues with closing or clicking cancel on the zenity path selection similar to select_prefix()
  preferred_url_wine=$url_wine_11_staging
  preferred_file_wine=$file_wine_11_staging
  preferred_dir_wine=$dir_wine_11_staging
  echo $preferred_dir_wine > "$dir_prefix/runners/$cfg_preferred_dir_wine"

  anchor_dir="$(pwd)"

  dir_install="$(zenity --file-selection --directory --title="Select the directory to install DCS")"
  dir_prefix="$dir_install/dcs-world"
  echo "install path: $dir_install"
  echo "install prefix: $dir_prefix"

  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"

  if [ -d "$dir_install/dcs-world" ]; then #ensure no existing prefix before we install to it FIXME
    dummy=0
    exit
  else
    mkdir -p "$dir_prefix/cache" "$dir_prefix/runners" "$dir_prefix/files"

    if [ ! -f "/files/$file_dcs" ]; then #dcs installer
      cd "$dir_prefix/files"
      wget "$url_dcs" --force-progress
    fi

    if [ ! -d "$dir_prefix/runners/$preferred_dir_wine" ]; then #wine runner
      cd "$dir_prefix/runners"
      wget "$preferred_url_wine" --force-progress
      tar -xvf "$preferred_file_wine"
      rm -rf "$preferred_file_wine"
    fi

    cd "$dir_prefix"
    export WINEPREFIX="$dir_prefix"
    export WINEDLLOVERRIDES='wbemprox=n'
    export WINE="$dir_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q corefonts xact_x64 d3dcompiler_47 vcrun2022 win10 dxvk
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k #ensure that wine isnt running https://linux.die.net/man/1/wineserver

#TODO message the user about what TO and NOT to do in the coming install. namely, not changing filepath, allowed to remove desktop icon, possibly notify about how to not re-download by using old prefix and make script for it

    export WINEPREFIX="$dir_prefix"
    export WINEDLLOVERRIDES='wbemprox=n'
    "$dir_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_prefix/files/$file_dcs"
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k
    cd "$anchor_dir"
    echo 'DCS installed.'
  fi
  menu_main
}

install_srs(){ #TODO unwritten - also add optional hook install
#winetricks dotnet9
# dll overrides d3d9=n, data from lutris installer
  dummy=0
}

install_srs_2.1.1.0(){ #TODO unwritten - also add optional hook install
  dummy=0
}

menu_main(){
  menu_main=(
    [0]=" exit_script"
    [1]=" install_DCS"
    [2]=" Install_SRS_2.1.1.0"              #
    [3]=" Install_SRS_2.4+_(unreliable)"    #
    [4]=" change_target_DCS_prefix"
    [5]=" manage_runners"
    [6]=" manage_dxvk"
    [7]=" troubleshooting"
  )
  zen_options=( ${menu_main[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'

  menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_dol}'>Github</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server"

  menu_text="active prefix: ${dir_prefix}
DoL Github: ${url_dol}
DoL Matrix chat/help server: ${url_matrix}"
  menu_height='575'
  cancel_label='exit'
  stringify_menu $menu_main

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DCS on Linux Community Helper" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      #echo $input
      if [ "$input" = "$nil" ] ; then #handle cancel button
        input='0'
      else
        for key in "${!menu_main[@]}"; do
          #echo ${menu_main[$key]}
          if [ ${menu_main[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-7]:
  [0]=exit_script
  [1]=install_DCS
  [2]=Install_SRS_2.1.1.0
  [3]=Install_SRS_2.4+_(unreliable)
  [4]=change_target_DCS_prefix
  [5]=manage_runners
  [6]=manage_dxvk
  [7]=troubleshooting

" input
    fi
    case $input in
      0) exit 1 ; break ;;
      1) install_dcs ;;
      2) install_srs ;;
      3) install_srs_2.1.1.0 ;;
      4) select_prefix ;;
      5) menu_runners ;;
      6) menu_dxvk ;;
      7) menu_troubleshooting ;;
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

menu_troubleshooting(){
  menu_troubleshooting=(
    [0]=" exit_script"
    [1]=" return_to_main_menu"
    [2]=" run_winetricks"
    [3]=" run_wine_control_panel"
    [4]=" run_wine_configuration"
    [5]=" run_wine_regedit"
    [6]=" run_wineboot_-u_(update_prefix)"
    [7]=" run_fix_textures"
    [8]=" run_fix_vanilla_voip_crash"       #
    [9]=" run_shaders_delete"
    [10]=" kill_wineserver"
  )
  zen_options=( ${menu_troubleshooting[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'  #'radiolist'

  menu_text_zenity="<a href='${url_troubleshooting}'>Troubleshooting resources</a>
active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server"

  menu_text="Troubleshooting resources: ${url_troubleshooting}
active prefix: ${dir_prefix}
DoL Matrix chat/help server: ${url_matrix}"

  menu_height='600' #575
  cancel_label='main menu'
  stringify_menu $menu_troubleshooting

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DoL - Troubleshooting menu" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      #echo $input
      if [ "$input" = "$nil" ] ; then #handle cancel button
        input='1'
      else
        for key in "${!menu_troubleshooting[@]}"; do
          if [ ${menu_troubleshooting[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-10]:
  [0]=exit_script
  [1]=return_to_main_menu
  [2]=run_winetricks
  [3]=run_wine_control_panel
  [4]=run_wine_configuration
  [5]=run_wine_regedit
  [6]=run_wineboot_-u_(update_prefix)
  [7]=run_fix_textures
  [8]=run_fix_vanilla_voip_crash
  [9]=run_shaders_delete
  [10]=kill_wineserver

" input
    fi
    case $input in
      0) exit 1 ; break ;;
      1) menu_main; break ;;
      2) run_winetricks ;;
      3) run_wine_control_panel ;;
      4) run_wine_configuration ;;
      5) run_wine_regedit ;;
      6) run_wine_wineboot_update ;;
      7) fixerscript_textures ;;
      8) fixerscript_vanilla_voip_crash ;;
      9) fixerscript_delete_shaders ;;
      10) kill_wineserver ;;
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

menu_runners(){ #TODO unwritten
  menu_runners=(
    [0]=" exit_script"
    [1]=" return_to_main_menu"
  )
  zen_options=( ${menu_runners[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'  #'radiolist'

  menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>"

  menu_text="active prefix: ${dir_prefix}"

  menu_height='575'
  cancel_label='main menu'
  stringify_menu $menu_runners

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DoL - Runner menu" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      #echo $input
      if [ "$input" = "$nil" ] ; then #handle cancel button
        input='1'
      else
        for key in "${!menu_runners[@]}"; do
          if [ ${menu_runners[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-5]:
  [0]=exit_script
  [1]=return_to_main_menu

" input
    fi
    case $input in
      0) exit 1 ; break ;;
      1) menu_main; break ;;
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

menu_dxvk(){
  menu_dxvk=(
    [0]=" exit_script"
    [1]=" return_to_main_menu"
    [2]=" remove_all_dxvk"
    [3]=" install_dxvk_standard"
    [4]=" install_dxvk_nvapi"
    [5]=" install_dxvk_git"                 #
  )
  zen_options=( ${menu_dxvk[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'  #'radiolist'

  menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>"

  menu_text="active prefix: ${dir_prefix}"

  menu_height='575'
  cancel_label='main menu'
  stringify_menu $menu_dxvk

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DoL - DXVK menu" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      #echo $input
      if [ "$input" = "$nil" ] ; then #handle cancel button
        input='1'
      else
        for key in "${!menu_dxvk[@]}"; do
          if [ ${menu_dxvk[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-5]:
  [0]=exit_script
  [1]=return_to_main_menu
  [2]=remove_all_dxvk
  [3]=install_dxvk_standard
  [4]=install_dxvk_nvapi
  [5]=install_dxvk_git

" input
    fi
    case $input in
      0) exit 1 ; break ;;
      1) menu_main; break ;;
      2) remove_all_dxvk ; menu_dxvk ;;
      3) install_dxvk_standard ; menu_dxvk ;;
      4) install_dxvk_nvapi ; menu_dxvk ;;
      5) install_dxvk_git ; menu_dxvk ;;
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

run_winetricks() {
  export WINEPREFIX="$dir_prefix"
  export WINE="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wine"
  export WINESERVER="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineserver"
  winetricks
}

run_wine_control_panel() {
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wine" control
}

run_wine_configuration() {
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/winecfg" #winecfg
}

run_wine_regedit() {
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/regedit" #regedit
}

run_wine_wineboot_update(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineboot" -u
  #wineboot -u
}

kill_wineserver(){ #bugfix for non-closing wine windows
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineserver" '-k'
}

fixerscript_textures(){
  "$(dirname $(readlink -f $0))/texturefixer.sh" "$dir_prefix"
}

fixerscript_vanilla_voip_crash(){ #TODO unwritten script, literally doesnt exist yet
  #"$(dirname $(readlink -f $0))/removevanillavoip.sh" "$dir_prefix"
  echo 'NOT IMPLEMENTED YET'
}

fixerscript_delete_shaders(){ #TODO needs granularity options added for not just nuking dcs, mesa, AND dxvk every run
  rm -rf "$dir_prefix/cache"
  mkdir "$dir_prefix/cache"
  "$(dirname $(readlink -f $0))/deleteshaders.sh" "$dir_prefix"
}

get_latest_release() { # TODO - from SCLUG, GPLv3, by TheSane, unused at the moment.
  # Sanity check
  if [ "$#" -lt 1 ]; then
    debug_print exit "Script error: The get_latest_release function expects one argument. Aborting."
  fi

  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                            # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

remove_all_dxvk(){
  export WINEPREFIX="$dir_prefix"
  path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/"

  for value in "${array_files_dxvk[@]}"; do
    rm -rf "$dir_prefix/drive_c/windows/system32/$value.dll"
    rm -rf "$dir_prefix/drive_c/windows/syswow64/$value.dll"
    "$path_wine/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v "*$value" /f
  done
  rm -rf "$dir_prefix/drive_c/windows/system32/nvapi.dll"
  rm -rf "$dir_prefix/drive_c/windows/syswow64/nvapi64.dll"
  rm -rf "$dir_prefix/drive_c/windows/syswow64/nvofapi64.dll"
  "$path_wine/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v '*nvapi' /f
  "$path_wine/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v '*nvapi64' /f
  "$path_wine/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v '*nvofapi64' /f
# $wine reg delete 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v $1 /f > /dev/null 2>&1 sourced from dxvk installer script from 2.0 and earlier
  run_wine_wineboot_update #rebuild prefix using default wine data
  unset $path_wine
}

install_dxvk_standard(){
  remove_all_dxvk
  export WINEPREFIX="$dir_prefix"
  export WINE="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wine"
  export WINESERVER="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineserver"
  winetricks -f dxvk
  unset $path_wine
}

install_dxvk_nvapi(){ #TODO warning, I do not know how to undo this fully when installed from winetricks
  export WINEPREFIX="$dir_prefix"
  export WINE="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wine"
  export WINESERVER="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineserver"
  winetricks -f dxvk_nvapi
  unset $path_wine
}

install_dxvk_git(){ #TODO FIXME this is totally non functional as it has no input for the url. this is pseudocode that will eventually work.
echo 'not implemented!'
#   anchor_dir="$(pwd)"
#   remove_all_dxvk
#   export WINEPREFIX="$dir_prefix"
#   path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/"
#
#   wget https://github.com/doitsujin/dxvk/releases/download/vX.X.X/dxvk-X.X.X.tar.gz
#   tar -xzf dxvk-X.X.X.tar.gz
#   cd dxvk-X.X.X
#
#   # Copy DLLs to your Wine prefix (replace ~/.wine with your prefix path)
#   cp x64/*.dll "$dir_prefix/drive_c/windows/system32/"
#   cp x32/*.dll "$dir_prefix/drive_c/windows/syswow64/"
#   cd $anchor_dir
#
#   if [ $old = '1' ]; then
#     # Register the DLLs, old method based on dxvk.org install instructions and install script form 2.0 and earlier
#     #winecfg and manually add native DLL overrides for d3d8, d3d9, d3d10core, d3d11 and dxgi under the Libraries tab
# #     "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /d native /f
# #     "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /d native /f
#     for value in "${array_files_dxvk[@]}"; do
#       "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v $value /d native /f
#     done
#   else
#     # new method, from git readme.md install steps, i think it just opens winecfg for you to manually do it
#     winecfg
#   fi
}


###################################################################################################
#startup
###################################################################################################
echo "you are running v$ver of the helper script."

#argument parsing
if [ $# -eq 0 ]; then #default run
  #   $0 -n
  #   exit 1
  echo 'default run detected'
else
  while getopts "ht" arg; do #arg run
    case $arg in
      h) printf "DCS on Linux Helper Script (based on SC-LUG)
exeution: $0
[-h] help (this message)
[-t] terminal mode (disable zenity even if present)
"; exit 1 ;;
      t) disable_zenity=1 ; echo 'zenity overridden' ;;
      ?) echo "error: option -$OPTARG is not implemented, use -h to see available swithes"; exit ;;
    esac
  done
fi



if [ ! -d "$dir_cfg" ]; then # load or create configs
  echo "config not found, generating one at $dir_cfg"
  mkdir -p "$dir_cfg"
  is_firstrun='true'
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
  echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
else
  if [ -f "$dir_cfg/$cfg_dir_prefix" ]; then #prefix
    dir_prefix="$(cat "$dir_cfg/$cfg_dir_prefix")"
  else
    echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
    echo "config file $cfg_dir_prefix missing, regenerated"
  fi
  if [ -f "$dir_cfg/$cfg_firstrun" ]; then #first run
    is_firstrun="$(cat "$dir_cfg/$cfg_firstrun")"
  else
    is_firstrun='true'
    echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
    echo "config file $cfg_firstrun missing, regenerated"
  fi
fi


###################################################################################################
#main script
###################################################################################################
check_dependency
menu_main
