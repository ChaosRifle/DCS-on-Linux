#!/bin/bash
ver='0.3.0'
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
dir_cfg="/home/$USER/.config/dcs-on-linux"
cfg_dir_prefix="prefix.cfg"
cfg_firstrun="firstrun.cfg"
cfg_dir_srs_prefix="srs_prefix.cfg"
cfg_preferred_dir_wine="preferred_wine.cfg"
subdir_dcs_corefiles="drive_c/Program Files/Eagle Dynamics/DCS World"
subdir_dcs_savedgames="drive_c/users/$USER/Saved Games/DCS"
self_path=$(dirname $(readlink -f $0))


###################################################################################################
#urls
###################################################################################################
url_dcs='https://www.digitalcombatsimulator.com/upload/iblock/959/d33ul8g3arxnzc1ejgdaa8uev8gvmew2/DCS_World_web.exe'
file_dcs='DCS_World_web.exe'

url_srs='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.1.1.0/DCS-SimpleRadioStandalone-2.1.1.0.zip'
file_srs='SR-ClientRadio.exe'
archive_srs='DCS-SimpleRadioStandalone-2.1.1.0.zip'

url_srs_latest='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.3.4.0/DCS-SimpleRadioStandalone-2.3.4.0.zip'
file_srs_latest='SR-ClientRadio.exe'
archive_srs_latest='DCS-SimpleRadioStandalone-2.3.4.0.zip'


url_wine_8='https://github.com/Kron4ek/Wine-Builds/releases/download/8.21/wine-8.21-amd64.tar.xz'
file_wine_8='wine-8.21-amd64.tar.xz'
dir_wine_8='wine-8.21-amd64'

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

url_dxvk_gplasync='https://gitlab.com/Ph42oN/dxvk-gplasync/-/jobs/11383149837/artifacts/download?file_type=archive'
file_dxvk_gpl_async='download?file_type=archive'


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
check_dependency(){
 selftest='pass'
  if [ ! -x "$(command -v wine)" ]; then selftest='fail'; echo 'ERROR: wine missing'; fi
                                                                                              #if ! command -v winetricks > /dev/null 2>&1; then selftest='fail'; echo 'ERROR: WINETRICKS MISSING'; fi # FIXME
  if [ ! -x "$(command -v winetricks)" ]; then selftest='fail'; echo 'ERROR: winetricks missing'; fi
  if [ ! -x "$(command -v git)" ]; then selftest='fail'; echo 'ERROR: git missing'; fi
  if [ ! -x "$(command -v wget)" ]; then selftest='fail'; echo 'ERROR: wget missing'; fi
  if [ ! -x "$(command -v curl)" ]; then selftest='fail'; echo 'ERROR: curl missing'; fi
  if [ ! -x "$(command -v cabextract)" ]; then selftest='fail'; echo 'ERROR: cabextract missing'; fi
  if [ ! -x "$(command -v tar)" ]; then selftest='fail'; echo 'ERROR: tar missing'; fi
  if [ ! -x "$(command -v unzip)" ]; then selftest='fail'; echo 'ERROR: unzip missing'; fi
  if [ ! -x "$(command -v touch)" ]; then selftest='fail'; echo 'ERROR: touch missing'; fi
  if [ ! -x "$(command -v mkdir)" ]; then selftest='fail'; echo 'ERROR: mkdir missing'; fi
  if [ ! -x "$(command -v chmod)" ]; then selftest='fail'; echo 'ERROR: chmod missing'; fi
  if ! grep -q "avx" /proc/cpuinfo; then selftest='fail'; echo 'ERROR: your cpu doesnt support avx'; fi
  if [ ! -x "$(command -v tty)" ]; then selftest='fail'; echo 'ERROR: tty missing'; fi

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
  else
    use_zenity=0
  fi
}

terminate(){ #for subshell "exit" functionality in the event of errors
  kill 0 $PPID
}

stringify_menu(){ #TODO unwritten - for auto generating terminal menus from zenity arrays
  dummy=0
}

query(){ #TODO unwritten - for generating multiple choice menus (and possible checklist menus later?)
  menu=(
    [0]=" exit_not_script"
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
    [11]=" run_winetricks"
  )

  menu_text_zenity="<a href='${url_troubleshooting}'>Troubleshooting resources</a>
active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server"


menu_text_zenity_line_count=$((3-1))
  menu_text="Troubleshooting resources: ${url_troubleshooting}
active prefix: ${dir_prefix}
DoL Matrix chat/help server: ${url_matrix}"

  cancel_label='main menu'
  menu_title="DoL - Troubleshooting menu"

unset input
  if [ $use_zenity -eq 1 ]; then
    menu_type='radiolist'   # 'checklist'  #'radiolist'
    zen_options=( ${menu[@]/#/"FALSE"} )
    decimal_offset=2
    menu_text_height=$((273+$decimal_offset+18+(18*$menu_text_zenity_line_count))) #minimum: 325, nominal base(title, zero/one line): 273 ---#
    menu_height="$((30 * (${#menu[@]}-2) + $menu_text_height))"
    input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="$menu_title" --hide-header --cancel-label "$cancel_label" --column="t" --column="o" "${zen_options[@]}")"
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
    menu_text="${menu_text}

enter a choice [0-$((${#menu[@]}-1))]:"
    for key in "${!menu[@]}"; do
      menu_text="${menu_text}
  [$key] = ${menu[$key]}"
    done
    menu_text="${menu_text}

"
    read -p "$menu_text" input
  fi

  unset menu_text
  unset menu_text_zenity
  unset cancel_label
  unset input
  unset menu
}

query_filepath(){ #    $1_prompt_text
  while true; do
    unset filepath_input
    if [ $use_zenity = 1 ]; then
      filepath_input="$(zenity --file-selection --directory --title="$1")"
      if [ $? -eq 1 ]; then
        filepath_input="$nil"
      fi
    else
      read -p "
$1
" filepath_input
    fi

    if [ "$filepath_input" = "$nil" ] ; then #user supplied empty path or hit zenity cancel
      if [ $(confirm 'this will exit the program, are you sure?') == true ]; then
        terminate
      fi
    else
      break
    fi
  done
  echo "$filepath_input"
}

notify(){ #    $1_info_text
  if [ $use_zenity = 1 ]; then
    zenity --info --title="" --text="$1"
  else
    read -p "
$1
press [enter] to continue
" dummy
#     echo "
# $1
# "
  fi
}

confirm(){ #    $1_question_text
unset confirm_input
  if [ $use_zenity = 1 ]; then
    zenity --question --title="Confirmation" --text="$1"
    case $? in
      0) echo true ;;
      1) echo false ;;
      ?) echo "ERROR: zenity confirmation returned value $?, terminating" > /dev/tty; terminate ;;
    esac
  else
    read -p "
$1
[y/n]?
" confirm_input
    if [ "$confirm_input" == "$nil" ] ; then
      echo "ERROR: confirmation option nil is not available, terminating" > /dev/tty
      terminate
    fi
    case $confirm_input in
      y) echo true ;;
      Y) echo true ;;
      yes) echo true ;;
      n) echo false ;;
      N) echo false ;;
      no) echo false ;;
      ?) echo "ERROR: confirmation option $confirm_input is not available, terminating" > /dev/tty; terminate
      ;;#exit;;
    esac
  fi
}

format_urls(){ #TODO unwritten - for dynamically generating menu hyperlinks and possibly disk links
  local dummy=0
}

select_target_dcs_prefix(){
  while true; do
    dir_prefix=$(query_filepath "enter the full path to your DCS prefix ('path/to/games/dcs-world')")
    if [ ! -d "$dir_prefix" ]; then
      if [ $(confirm 'the path you specified could not be found. would you like to try again?') == false ]; then
        break
      fi
    else
      break
    fi
  done
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
  echo $dir_prefix
}

select_target_srs_prefix(){
  while true; do
    dir_srs_prefix=$(query_filepath "enter the full path to your SRS prefix ('path/to/games/srs(-2.1.1.0)')")
    if [ ! -d "$dir_srs_prefix" ]; then
      if [ $(confirm 'the path you specified could not be found. would you like to try again?') == false ]; then
        break
      fi
    else
      break
    fi
  done
  echo $dir_srs_prefix > "$dir_cfg/$cfg_dir_srs_prefix"
  echo $dir_srs_prefix
}

install_dcs(){
  preferred_url_wine=$url_wine_11_staging
  preferred_file_wine=$file_wine_11_staging
  preferred_dir_wine=$dir_wine_11_staging

  anchor_dir="$(pwd)"
  dir_install="$(query_filepath 'Select the directory to install DCS into')"

runtype=0 # "$(query )" # FIXME TODO # 0=fresh clean install, 1=file install, 2=prefix reinstall

  if [ ! -d "$dir_install" ]; then
    notify 'invalid path, directory doesnt exist!'
    exit 1
  fi
  dir_prefix="$dir_install/dcs-world"
  echo "install path: $dir_install"
  echo "install prefix: $dir_prefix"
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
  if [ -d "$dir_install/dcs-world" ]; then
    notify "Invalid path, you gave an existing prefix!
Please rename, remove, or move the exisiting prefix ($dir_install/dcs-world).
Aternatively, choose a different path to install to"
    exit
  fi
  case $runtype in # 0=fresh clean install, 1=file install, 2=prefix reinstall
    0) ;;

    1) notify "this should be safe, but please ensure anything important (keybinds/scripts/missions) are backed up before continuing.
Core-Files should be structured as:
$dir_install/dcs-files/DCS World

SavedGames-Files should be structured as:
$dir_install/dcs-files/DCS

WARNING: If they are not, this will fail, however manual file copy or 'launch-dcs.sh -u' can recover from this" ;;

    2) if [ -d "$dir_install/dcs-files" ]; then
      notify "You have existing files at $dir_install/dcs-files and thus should use file-install instead of prefix-reinstall, or, delete/rename that folder. Exiting."
        exit 0
    fi
    notify 'this should be safe, but please ensure anything important (keybinds/scripts/missions) are backed up before continuing.
The next screen will ask for a prefix to destroy to collect the files.
WARNING: this will only work for a stable release install of dcs - openbeta and closedbeta will not work.'

    dir_sacrificial_prefix="$(query_filepath 'Select the SACRIFICIAL prefix (parent folder to drive_c) you wish to DESTROY to gather files for the rebuild')"
    if [ ! -d "$dir_sacrificial_prefix/$subdir_dcs_corefiles" ] || [ ! -d "$dir_sacrificial_prefix/$subdir_dcs_savedgames" ]; then
      notify 'could not identify directories to consume for prefix deconstruction. Exiting.'
      exit 1
    fi
    mkdir -p "$dir_install/dcs-files"
    mv "$dir_sacrificial_prefix/$subdir_dcs_corefiles" "$dir_install/dcs-files"
    mv "$dir_sacrificial_prefix/$subdir_dcs_savedgames" "$dir_install/dcs-files"
    rm -r "$dir_sacrificial_prefix"
    unset $dir_sacrificial_prefix
    runtype=1 ;; #to route the end

    ?) echo "ERROR: unexpected $runtype was given. Exiting."; exit 0 ;;
  esac
  mkdir -p "$dir_prefix/cache" "$dir_prefix/runners" "$dir_prefix/files"
  echo $preferred_dir_wine > "$dir_prefix/runners/$cfg_preferred_dir_wine"
  if [ ! -f "/files/$file_dcs" ]; then #dcs installer
    cd "$dir_prefix/files"
    wget "$url_dcs" #--force-progress
  fi
  if [ ! -d "$dir_prefix/runners/$preferred_dir_wine" ]; then #wine runner
    cd "$dir_prefix/runners"
    wget "$preferred_url_wine" #--force-progress
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

  case $runtype in # 0=fresh clean install, 1=file install, 2=prefix reinstall
    0) temp_string_notify="Do NOT change the default install path!

you may opt to disable the desktop icon
you may opt to download the game later by unticking the 'Start Download' box and clicking finish, then use the 'launch-dcs.sh -u' to initiate the download later"
;;
    1) temp_string_notify="Do NOT change the default install path!
DO untick the 'Start Download' box before you click 'finish'!

you may opt to disable the desktop icon"
    ;;
    ?) echo "ERROR: unexpected $runtype was given. Exiting."; exit ;;
  esac
  notify "$temp_string_notify"
  unset $temp_string_notify
  export WINEPREFIX="$dir_prefix"
  export WINEDLLOVERRIDES='wbemprox=n'
  "$dir_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_prefix/files/$file_dcs"
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k
  case $runtype in # 0=fresh clean install, 1=file install, 2=prefix reinstall
  # NOTE unclear if dcs installer does anything besides files on disk, like registry edits, so to be safe, we run this after the installer, as the installer refuses to run if the files are detected. Done out of caution, not knowledge
    0) ;;
    1) rm -rf "$dir_prefix/$subdir_dcs_corefiles"
    mkdir -p "$dir_prefix/$subdir_dcs_corefiles" "$dir_prefix/$subdir_dcs_savedgames"
    mv -f "$dir_install/dcs-files/DCS World" "$dir_prefix/$subdir_dcs_corefiles/.."
    mv -f "$dir_install/dcs-files/DCS" "$dir_prefix/$subdir_dcs_savedgames/.."
    rm -r "$dir_install/dcs-files" ;;
    ?) echo "ERROR: unexpected $runtype was given. Exiting."; exit ;;
  esac
  unset $runtype
  cd "$anchor_dir"
  echo 'DCS installed.'
  notify "DCS install is now complete.
To run DCS, execute 'launch-dcs.sh'.
If you would like to know more, use 'launch-dcs.sh -h'
to update DCS, run 'launch-dcs.sh -u'

If you have issues, check the troubleshooting wiki or ask in matrix
https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting
https://matrix.to/#/#dcs-on-linux:matrix.org"
}

install_srs(){
  preferred_url_wine=$url_wine_11_staging
  preferred_file_wine=$file_wine_11_staging
  preferred_dir_wine=$dir_wine_11_staging

  anchor_dir="$(pwd)"

  dir_srs_install="$(zenity --file-selection --directory --title="Select the directory to install SRS")"
  dir_srs_prefix="$dir_srs_install/srs"
  echo "install path: $dir_srs_install"
  echo "install prefix: $dir_srs_prefix"

  echo $dir_srs_prefix > "$dir_cfg/$cfg_dir_srs_prefix"

  if [ -d "$dir_srs_prefix" ]; then
    notify 'srs prefix already exits, terminating'
    exit
  else
    mkdir -p "$dir_srs_prefix/cache" "$dir_srs_prefix/runners" "$dir_srs_prefix/files/hook-srs/Scripts" "$dir_srs_prefix/files/hook-srs/Mods/Services" "$dir_srs_prefix/drive_c/srs"
    echo $preferred_dir_wine > "$dir_srs_prefix/runners/$cfg_preferred_dir_wine"

    cd "$dir_srs_prefix/drive_c/srs"
    wget "$url_srs_latest" #--force-progress
    unzip "$archive_srs_latest"

    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/DCS-SRS" "$dir_srs_prefix/files/hook-srs/Mods/Services"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Hooks" "$dir_srs_prefix/files/hook-srs/Scripts"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Export.lua" "$dir_srs_prefix/files/hook-srs/Scripts"

    if [ -d "$dir_prefix" ]; then
      temp_srs_warning="Would you like to auto-install the srs hooks to the game dir?

WARNING: Due to case folding and dcs jank, we STRONGLY recommend using a mod manager to avoid problems.
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )
We have already generated the hooks for you at '$dir_srs_prefix/files/hook-srs'"
      if [ $(confirm "$temp_srs_warning") == true ]; then
        cp "$dir_srs_prefix/files/hook-srs/Mods" "$dir_prefix/$subdir_dcs_savedgames"
        cp "$dir_srs_prefix/files/hook-srs/Scripts" "$dir_prefix/$subdir_dcs_savedgames"
        echo 'srs hook installed via raw copy... hope it doesnt break later.'
      fi
      unset $temp_srs_warning
    else
      notify "Please place the SRS hooks in your '$subdir_dcs_savedgames' directory using a mod manager
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )
We have generated the srs hooks for you at '$dir_srs_prefix/files/hook-srs'"
    fi

    if [ ! -d "$dir_srs_prefix/runners/$preferred_dir_wine" ]; then #wine runner
      cd "$dir_srs_prefix/runners"
      wget "$preferred_url_wine" #--force-progress
      tar -xvf "$preferred_file_wine"
      rm -rf "$preferred_file_wine"
    fi

    cd "$dir_srs_prefix"
    export WINEPREFIX="$dir_srs_prefix"
    export WINE="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q dotnetdesktop9 win10

#     export WINEPREFIX="$dir_srs_prefix"
#     export WINEDLLOVERRIDES='icu=n,icuin=n,icuuc=n' #d3d9=n
#     "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/drive_c/srs/Client/$file_srs_latest" # test run
    cd "$anchor_dir"
    echo 'SRS installed.'
  fi
}

install_srs_2.1.1.0(){ # FIXME something is preventing sound working properly..
  preferred_url_wine=$url_wine_11_staging
  preferred_file_wine=$file_wine_11_staging
  preferred_dir_wine=$dir_wine_11_staging

  anchor_dir="$(pwd)"

  dir_srs_install="$(zenity --file-selection --directory --title="Select the directory to install SRS")"
  dir_srs_prefix="$dir_srs_install/srs-2.1.1.0"
  echo "install path: $dir_srs_install"
  echo "install prefix: $dir_srs_prefix"

  echo $dir_srs_prefix > "$dir_cfg/$cfg_dir_srs_prefix"

  if [ -d "$dir_srs_prefix" ]; then
    notify 'srs-2.1.1.0 prefix already exits, terminating'
    exit
  else
    mkdir -p "$dir_srs_prefix/cache" "$dir_srs_prefix/runners" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Mods/Services" "$dir_srs_prefix/drive_c/srs"
    echo $preferred_dir_wine > "$dir_srs_prefix/runners/$cfg_preferred_dir_wine"

    cd "$dir_srs_prefix/drive_c/srs"
    wget "$url_srs" #--force-progress
    unzip "$archive_srs"

    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/DCS-SRS" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Mods/Services"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Hooks" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Export.lua" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts"

    if [ -d "$dir_prefix" ]; then
      temp_srs_warning="Would you like to auto-install the srs hooks to the game dir?

WARNING: Due to case folding and dcs jank, we STRONGLY recommend using a mod manager to avoid problems.
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )
We have already generated the hooks for you at '$dir_srs_prefix/files/hook-srs-v2.1.1.0'"
      if [ $(confirm "$temp_srs_warning") == true ]; then
        cp "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Mods" "$dir_prefix/$subdir_dcs_savedgames"
        cp "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts" "$dir_prefix/$subdir_dcs_savedgames"
        echo 'srs hook installed via raw copy... hope it doesnt break later.'
      fi
      unset $temp_srs_warning
    else
      notify "Please place the SRS hooks in your '$subdir_dcs_savedgames' directory using a mod manager
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )
We have generated the srs hooks for you at '$dir_srs_prefix/files/hook-srs-v2.1.1.0'"
    fi


    if [ ! -d "$dir_srs_prefix/runners/$preferred_dir_wine" ]; then #wine runner
      cd "$dir_srs_prefix/runners"
      wget "$preferred_url_wine" #--force-progress
      tar -xvf "$preferred_file_wine"
      rm -rf "$preferred_file_wine"
    fi

    cd "$dir_srs_prefix"
    export WINEARCH=win64
    export WINEPREFIX="$dir_srs_prefix"
    export WINE="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q dotnet48 vcrun2022 win10 # dxvk dotnetdesktop9 xact_x64

#     export WINEARCH=win64
#     export WINEPREFIX="$dir_srs_prefix"
#     export WINEDLLOVERRIDES='d3d9=n,icu=n,icuin=n,icuuc=n'
#     "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/drive_c/srs/SR-ClientRadio.exe" # test run
    cd "$anchor_dir"
    echo 'SRS installed.'
  fi
}

menu_main(){ #TODO rewrite once query() is complete
  while true; do
    unset menu
    menu=(
      [0]=" exit_script"
      [1]=" install_DCS"
      [2]=" Install_SRS_2.1.1.0_(incomplete-audio-issues)"
      [3]=" Install_SRS_latest"
      [4]=" change_target_DCS_prefix"
      [5]=" change_target_SRS_prefix"
      [6]=" manage_runners_(NOT_IMPLEMENTED!)"
      [7]=" manage_dxvk"
      [8]=" troubleshooting"
    )
    zen_options=( ${menu[@]/#/"FALSE"} )
    menu_type='radiolist'   # 'checklist'

    menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_dol}'>Github</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server"

    menu_text="active prefix: ${dir_prefix}
DoL Github: ${url_dol}
DoL Matrix chat/help server: ${url_matrix}"
    menu_height='575'
    cancel_label='exit'

    unset input
    if [ $use_zenity -eq 1 ]; then
      input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="DCS on Linux Community Helper" --hide-header --cancel-label "$cancel_label" --column="" --column="Option" "${zen_options[@]}")"
      #echo $input
      if [ "$input" = "$nil" ] ; then #handle cancel button
        input='0'
      else
        for key in "${!menu[@]}"; do
          #echo ${menu[$key]}
          if [ ${menu[$key]} = $input ]; then
            input=$key
            break
          fi
        done
      fi
    else
      read -p "$menu_text

enter a choice [0-8]:
  [0]=exit_script
  [1]=install_DCS
  [2]=Install_SRS_2.1.1.0_(incomplete-audio-issues)
  [3]=Install_SRS_latest
  [4]=change_target_DCS_prefix
  [5]=change_target_SRS_prefix
  [6]=manage_runners_(NOT_IMPLEMENTED!)
  [7]=manage_dxvk
  [8]=troubleshooting

" input
    fi
    case $input in
      0) exit 1 ;;
      1) install_dcs ;;
      2) install_srs_2.1.1.0 ;;
      3) install_srs ;;
      4) select_target_dcs_prefix ;;
      5) select_target_srs_prefix ;;
      6) menu_runners ;;
      7) menu_dxvk ;;
      8) menu_troubleshooting ;;
      ?) echo "error: option $input is not available, please try again" ;;
    esac
  done
}

menu_troubleshooting(){ #TODO rewrite once query() is complete
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

menu_runners(){ #TODO  rewrite once query() is complete, totally nonfunctional at this time
  menu_runners=(
    [0]=" exit_script"
    [1]=" return_to_main_menu"
    [2]=" remove_an_installed_runner"                   #
    [3]=" install_a_wine_kron4ek_runner"                #
    [4]=" change_active_runner_from_installed_runners"  #
    [5]=" install a proton GE runner (not functional)"  #
    [6]=" remove an installed runner2"                  #
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

menu_dxvk(){ #TODO rewrite once query() is complete
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

run_winetricks(){
  path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/"
  export WINEPREFIX="$dir_prefix"
  export WINE="$path_wine/wine"
  export WINESERVER="$path_wine/wineserver"
  winetricks
  unset $path_wine
}

run_wine_control_panel(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wine" control
}

run_wine_configuration(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/winecfg"
}

run_wine_regedit(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/regedit"
}

run_wine_wineboot_update(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineboot" -u
}

kill_wineserver(){
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/wineserver" '-k'
}

fixerscript_textures(){
  "$self_path/texturefixer.sh" "$dir_prefix"
}

fixerscript_vanilla_voip_crash(){
  if [ $(confirm "This will edit game files to disable the vanilla voip system in the event it prevents gameplay. This can be undone with 'launch-dcs.sh -r' to repair the files, though you should uninstall your mods before using repairing.

BEFORE proceeding, make sure you edit the PREFIX variable to match your DCS prefix by editing the $self_path/vanillavoipfixer.sh script.

To learn more, visit:

https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-game-launches-to-a-black-screen-entirely-or-multiplayer-crashes-on-connect-dcslog-cites-voice-chat-related-things" ) == true ]; then
    "$self_path/vanillavoipfixer.sh" "$dir_prefix"
  fi
}

fixerscript_delete_shaders(){
  if [ -d "$dir_prefix" ]; then
      if [ $(confirm "remove mesa/dxvk cache in:
'$dir_prefix'?") == true ]; then
      rm -rf "$dir_prefix/cache"
      mkdir "$dir_prefix/cache"
    fi
    if [ $(confirm "remove dcs shaders in:
'$dir_prefix'?") == true ]; then
      "$self_path/deleteshaders.sh" "$dir_prefix"
    fi
  else
    notify "ERROR: prefix was not found"
  fi
}

get_latest_git_release(){ # TODO - from SCLUG, GPLv3, by TheSane, unused at the moment.
  # Sanity check
  if [ "$#" -lt 1 ]; then
    debug_print exit "Script error: The get_latest_release function expects one argument. Aborting."
  fi

  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                            # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

remove_all_dxvk(){
  if [ -d "$dir_prefix" ]; then
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
    run_wine_wineboot_update
    unset $path_wine
  else
    notify "ERROR: prefix was not found"
  fi
}

install_dxvk_standard(){
  remove_all_dxvk
  path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin"
  export WINEPREFIX="$dir_prefix"
  export WINE="$path_wine/wine"
  export WINESERVER="$path_wine/wineserver"
  winetricks -f dxvk
  unset $path_wine
}

install_dxvk_nvapi(){
  if [ $(confirm 'I (chaos) am unsure if this can be fully uninstalled once installed. this has not been fully tested for removal. Proceed?') == true ]; then
    path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin"
    export WINEPREFIX="$dir_prefix"
    export WINE="$path_wine/wine"
    export WINESERVER="$path_wine/wineserver"
    winetricks -f dxvk_nvapi
    unset $path_wine
  fi
}

install_dxvk_git(){ #TODO this is totally non functional as it has no input for the url. this is pseudocode that will eventually work.
notify 'this is unfinished, sorry. exiting.'
exit 1
  unset url_working
  unset file_working
  url_working="$url_dxvk_gplasync"
  file_working="$file_dxvk_gpl_async"

  anchor_dir="$(pwd)"
  remove_all_dxvk
  export WINEPREFIX="$dir_prefix"
  path_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin/"

  cd "$dir_prefix/files"
  wget $url_working #https://github.com/doitsujin/dxvk/releases/download/vX.X.X/dxvk-X.X.X.tar.gz
  # if tar, then: tar -xzf dxvk-X.X.X.tar.gz
  #if zip, then:
  unzip $file_working
  #cd dxvk-X.X.X

  cp $dir_prefix/files/x64/*.dll "$dir_prefix/drive_c/windows/system32/"
  cp $dir_prefix/files/x32/*.dll "$dir_prefix/drive_c/windows/syswow64/"
  cd $anchor_dir

    # Register the DLLs, old method based on dxvk.org install instructions and install script form 2.0 and earlier
    #winecfg and manually add native DLL overrides for d3d8, d3d9, d3d10core, d3d11 and dxgi under the Libraries tab
#     "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /d native /f
#     "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /d native /f
  for value in "${array_files_dxvk[@]}"; do
    "$path_wine/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v $value /d native /f
  done
  unset url_working
  unset file_working
}

firstrun(){
  if [ $is_firstrun == true ]; then
    notify "Welcome to the DCS on Linux helper.
A config has been generated at:
/home/$USER/.config/dcs-on-linux

NOTE: when using gui mode, information about what the script wants you to do will be displayed as a window title (text at the top in dolphin)."

    is_firstrun=false
    echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
  fi
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
  is_firstrun=true
  echo $dir_prefix > "$dir_cfg/$cfg_dir_prefix"
  echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
  echo $dir_srs_prefix > "$dir_cfg/$cfg_dir_srs_prefix"
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
    is_firstrun=true
    echo $is_firstrun > "$dir_cfg/$cfg_firstrun"
    echo "config file $cfg_firstrun missing, regenerated"
  fi
  if [ -f "$dir_cfg/$cfg_dir_srs_prefix" ]; then #prefix
    dir_srs_prefix="$(cat "$dir_cfg/$cfg_dir_srs_prefix")"
  else
    echo $dir_srs_prefix > "$dir_cfg/$cfg_dir_srs_prefix"
    echo "config file $cfg_dir_srs_prefix missing, regenerated"
  fi
fi


###################################################################################################
#main script
###################################################################################################
check_dependency
#query
firstrun
menu_main
