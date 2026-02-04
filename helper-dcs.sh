#!/bin/bash
ver='0.0.1'
# significant portions of this script were taken from the SC LUG Helper on 26/01/27. Zenity version checking, first run checking, config saving, were all taken from their GPL3 source. The rest was written by Chaos initially


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

      dir_prefix="/home/$USER/games/dcs-world"
      subdir_runners="$dir_prefix/runners"
      dir_winepath="$dir_prefix/runners/$downloaded_item_name/bin"

subdir_dcs_corefiles="drive_c/Program Files/Eagle Dynamics/DCS World/"
subdir_dcs_savedgames="drive_c/users/$USER/Saved Games/DCS/"


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
dir_wine_11='wine-11.1-amd64'

url_wine_11_staging='https://github.com/Kron4ek/Wine-Builds/releases/download/11.1/wine-11.1-staging-amd64.tar.xz'
file_wine_11_staging='wine-11.1-staging-amd64.tar.xz'
dir_wine_11_staging='wine-11.1-staging-amd64'



url_dol='https://github.com/ChaosRifle/DCS-on-Linux'
url_troubleshooting='https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting'
url_matrix='https://matrix.to/#/#dcs-on-linux:matrix.org'


###################################################################################################
#function defines
###################################################################################################
format_urls() { #TODO
  local dummy=0
}

check_dependency() {
 selftest='pass'
  if [ ! -x "$(command -v wine)" ]; then selftest='fail'; echo 'ERROR: WINE MISSING'; fi
  #if ! command -v winetricks > /dev/null 2>&1; then selftest='fail'; echo 'ERROR: WINETRICKS test1 MISSING'; else echo 'winetricks test 1 success!!!'; fi
  if [ ! -x "$(command -v winetricks)" ]; then selftest='fail'; echo 'ERROR: WINETRICKS MISSING'; fi #FIXME this is broken in script but not in terminal. what the heck is going on?!
  if [ ! -x "$(command -v git)" ]; then selftest='fail'; echo 'ERROR: GIT MISSING'; fi
  if [ ! -x "$(command -v wget)" ]; then selftest='fail'; echo 'ERROR: WGET MISSING'; fi
  if [ ! -x "$(command -v curl)" ]; then selftest='fail'; echo 'ERROR: CURL MISSING'; fi
  if [ ! -x "$(command -v cabextract)" ]; then selftest='fail'; echo 'ERROR: CABEXTRACT MISSING'; fi
  if [ ! -x "$(command -v unzip)" ]; then selftest='fail'; echo 'ERROR: UNZIP MISSING'; fi
  if [ ! -x "$(command -v touch)" ]; then selftest='fail'; echo 'ERROR: touch missing'; fi
  if [ ! -x "$(command -v mkdir)" ]; then selftest='fail'; echo 'ERROR: mkdir missing'; fi
  if [ ! -x "$(command -v chmod)" ]; then selftest='fail'; echo 'ERROR: chmod missing'; fi

  if [ ! $selftest = 'pass' ]; then echo 'dependency check failed, exiting..' ; exit 0; fi
}
message() { #TODO
  if [ $use_zenity = 1 ]; then
    dummy=0
  else
    dummy=0
  fi
}

select_prefix(){ #TODO: fix cancel button returning dir of '' beause cancel just sets empty var. exit script or return to menu if done!
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

install_dcs(){ #TODO - hardcoded for wine 11 atm, add switching later
  preferred_url_wine=$url_wine_11_staging
  preferred_file_wine=$file_wine_11_staging
  preferred_dir_wine=$dir_wine_11_staging
  echo $preferred_dir_wine > "$dir_prefix/runners/$cfg_preferred_dir_wine"

  anchor_dir="$(pwd)"

  dir_install="$(zenity --file-selection --directory --title="Select the directory to install DCS")"
  dir_prefix="$dir_install/dcs-world"
  echo $dir_install
  echo $dir_prefix
#read -p "continue?" input #FIXME
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
    #git files?
    export WINEPREFIX="$dir_prefix"
    export WINEDLLOVERRIDES='wbemprox=n'
    export WINE="$dir_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks

    winetricks -q corefonts xact_x64 d3dcompiler_47 vcrun2022 win10
    echo 'debug 1'
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k #ensure that wine isnt running https://linux.die.net/man/1/wineserver

#TODO message the user about what TO and NOT to do in the coming install. namely, not changing filepath, allowed to remove desktop icon, possibly notify about how to not re-download by using old prefix and make script for it

    export WINEPREFIX="$dir_prefix"
    export WINEDLLOVERRIDES='wbemprox=n'
    echo 'debug 2'
    "$dir_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_prefix/files/$file_dcs"
    echo 'debug 3'
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k
    cd "$anchor_dir"
    echo 'DCS installed.'
  fi
  menu_main
}

install_srs(){ #TODO, also add optional hook install
  menu_main
}

install_srs_2.1.1.0(){ #TODO, also add optional hook install
  menu_main
}

stringify_menu() { #TODO
  dummy=0
}

menu_main(){
  menu_main=(
    [0]=" exit_script"
    [1]=" change_target_DCS_prefix"
    [2]=" install_DCS"
    [3]=" Install_SRS_2.1.1.0"
    [4]=" Install_SRS_2.4+_(unreliable)"
    [5]=" troubleshooting"
  )
  zen_options=( ${menu_main[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'  #'radiolist'

  menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL Github: <a href='${url_dol}'>${url_dol}</a>
DoL Matrix server: <a href='${url_matrix}'>${url_matrix}</a>"

  menu_text="active prefix: ${dir_prefix}
DoL Github: ${url_dol}
DoL Matrix server: ${url_matrix}"
  menu_height='575'
  cancel_label='exit'
  stringify_menu menu_main

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DCS on Linux Community Helper" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"

      echo $input
      if [ "$input" = "$nil" ] ; then
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

enter a choice [0-5]:
[0]=exit_script
[1]=change_target_DCS_prefix
[2]=install_DCS
[3]=Install_SRS_2.1.1.0
[4]=Install_SRS_2.4+_(unreliable)
[5]=troubleshooting

" input
    fi
    case $input in
      0) exit 1 ; break ;;
      1) select_prefix ;;
      2) install_dcs ;;
      3) install_srs ;;
      4) install_srs_2.1.1.0 ;;
      5) menu_troubleshooting ;;
      6) break ;;
      7) break ;;
      8) break ;;
      9) break ;;
      10) break ;;
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
    [8]=" run_fix_vanilla_voip_crash"
    [9]=" run_shaders_delete"

    #[9]=" run_dependency_check"
  )
  zen_options=( ${menu_troubleshooting[@]/#/"FALSE"} )
  menu_type='radiolist'   # 'checklist'  #'radiolist'

  menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
Troubleshooting resources: <a href='${url_troubleshooting}'>${url_troubleshooting}</a>
DoL Matrix server: <a href='${url_matrix}'>${url_matrix}</a>"

  menu_text="active prefix: ${dir_prefix}
Troubleshooting resources: ${url_troubleshooting}
DoL Matrix server: ${url_matrix}"

  menu_height='575'
  cancel_label='main menu'
  stringify_menu menu_troubleshooting

  while true; do
    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DCS on Linux Community Helper" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      echo $input
      if [ "$input" = "$nil" ] ; then
        input='1'
      else
        for key in "${!menu_troubleshooting[@]}"; do
          #echo ${menu_troubleshooting[$key]}
          if [ ${menu_troubleshooting[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-9]:
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
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

run_winetricks() { #TODO
  export WINEPREFIX="$GAME_DIR"
  winetricks
}

run_wine_control_panel() { #TODO
  export WINEPREFIX="$GAME_DIR"
  wine control
}

run_wine_configuration() { #TODO
  export WINEPREFIX="$GAME_DIR"
  wine winecfg
}

run_wine_regedit() { #TODO
  export WINEPREFIX="$GAME_DIR"
  wine regedit
}

run_wine_wineboot_update(){ #TODO
  export WINEPREFIX="$GAME_DIR"
  wineboot -u
}

fixerscript_textures(){ #TODO
  echo 'NOT IMPLEMENTED YET'
  # ./texturefixer.sh $dir_prefix
}

fixerscript_vanilla_voip_crash(){ #TODO
  # ./removevanillavoip.sh $dir_prefix
  echo 'NOT IMPLEMENTED YET'
}

fixerscript_delete_shaders(){ #TODO
  echo 'NOT IMPLEMENTED YET'
  # rm -rf "$dir_prefix/cache"
  # mkdir "$dir_prefix/cache"
  # ./deleteshaders.sh $dir_prefix
}

get_latest_release() { # TODO - from SCLUG, GPLv3, by TheSane
  # Sanity check
  if [ "$#" -lt 1 ]; then
    debug_print exit "Script error: The get_latest_release function expects one argument. Aborting."
  fi

  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                            # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

###################################################################################################
#startup
###################################################################################################
echo "you are running v$ver of this script."

#argument parsing
if [ $# -eq 0 ]; then #default run
#   $0 -n
#   exit 1
echo 'default run detected'
else
  while getopts "ht" arg; do #arg run
    case $arg in
      h) printf 'DCS on Linux Helper Script (based on SC-LUG)
      usage: $0
      [-h] help (this message)
      [-t] terminal mode (disable zenity even if present)
      ';;
      t) disable_zenity=1 ;;
      ?) echo 'error: option -$OPTARG is not implemented, use -h to see available swithes'; exit ;;
    esac
  done
fi

#SC LUG CODE:
# Zenity availability/version check
menu_option_height="0"
menu_text_height_zenity4="0"
menu_height_max="0"

if [ -x "$(command -v zenity)" ]; then  #from SCLUG, GPLv3, by TheSane
  if zenity --version >/dev/null; then
    use_zenity=1
    zenity_version="$(zenity --version)"

    # Zenity 4.0.0 uses libadwaita, which changes fonts/sizing
    # Add pixels to each menu option depending on the version of zenity in use
    # used to dynamically determine the height of menus
    # menu_text_height_zenity4 = Add extra pixels to the menu title/description height for libadwaita bigness
    if [ "$zenity_version" != "4.0.0" ] &&
      [ "$zenity_version" = "$(printf "%s\n%s" "$zenity_version" "4.0.0" | sort -V | head -n1)" ]; then
      # zenity 3.x menu sizing
      menu_option_height="26"
      menu_text_height_zenity4="0"
      menu_height_max="400"
    else
      # zenity 4.x+ menu sizing
      menu_option_height="26"
      menu_text_height_zenity4="0"
      menu_height_max="800"
    fi
  else
    # Zenity is broken
    debug_print continue "Zenity failed to start. Falling back to terminal menus"
  fi
fi

if [ $disable_zenity = 1 ]; then
  use_zenity=0
  echo 'zenity overridden'
fi



if [ "$#" -eq 0 ]; then #from SCLUG, GPLv3, by TheSane
  format_urls
fi

if [ ! -d "$dir_cfg" ]; then # load or create configs
  echo "config not found, generating one at $dir_cfg"
  mkdir -p "$dir_cfg"
  is_firstrun='true'
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
  echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
else
  if [ -f "$dir_cfg/$cfg_dir_prefix" ]; then
    dir_prefix="$(cat "$dir_cfg/$cfg_dir_prefix")"
  else
    echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
    echo "config file $cfg_dir_prefix missing, regenerated"
  fi
  if [ -f "$dir_cfg/$cfg_firstrun" ]; then
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
