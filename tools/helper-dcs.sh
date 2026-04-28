#!/bin/bash
ver='0.8.8'

###################################################################################################
#block root use, keep this as the FIRST lines of code in the script
###################################################################################################
if [ "$(id -u)" -eq 0 ]; then
  echo 'You have run this as root, please dont run scripts off the internet as root.'
  exit 1
fi


###################################################################################################
#variables and config
###################################################################################################
disable_zenity="0"
dir_cfg="/home/$USER/.config/dcs-on-linux"
cfg_dir_prefix="prefix.cfg"
cfg_firstrun="firstrun.cfg"
cfg_dir_srs_prefix="srs_prefix.cfg"
cfg_preferred_dir_wine="preferred_wine.cfg"
subdir_dcs_corefiles="drive_c/Program Files/Eagle Dynamics/DCS World"
subdir_dcs_savedgames="drive_c/users/$USER/Saved Games/DCS"
dynamic_install_list_size='10'
dir_self="$(dirname $(readlink -f $0))"
dir_logs_helper="/home/$USER/.local/state/dcs-on-linux" # "$dir_self/../dcs-on-linux-logs"
full_log="${dir_logs_helper}/dcs_helper_full.log"
cmd_log="${dir_logs_helper}/dcs_helper_cmd.log"
err_log="${dir_logs_helper}/dcs_helper_err.log"


###################################################################################################
#urls
###################################################################################################
url_dcs='https://www.digitalcombatsimulator.com/upload/iblock/959/d33ul8g3arxnzc1ejgdaa8uev8gvmew2/DCS_World_web.exe'
file_dcs='DCS_World_web.exe'

url_dol='https://github.com/ChaosRifle/DCS-on-Linux'
url_troubleshooting='https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting'
url_matrix='https://matrix.to/#/#dcs-on-linux:matrix.org'

url_wine_sclug="https://api.github.com/repos/starcitizen-lug/lug-wine/releases?per_page=$dynamic_install_list_size"
url_wine_Kron4ek="https://api.github.com/repos/Kron4ek/Wine-Builds/releases?per_page=$dynamic_install_list_size"



url_dxvk_gplasync='https://gitlab.com/Ph42oN/dxvk-gplasync/-/jobs/11383149837/artifacts/download?file_type=archive' # Ph42oN%2Fdxvk-gplasync  FIXME
file_dxvk_gpl_async='download?file_type=archive' #FIXME



url_wine_11_staging='https://github.com/Kron4ek/Wine-Builds/releases/download/11.1/wine-11.1-staging-amd64.tar.xz' #known good for dcs, used in srs these days to avoid unnessisary prompts

url_srs_2_1_1_0='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.1.1.0/DCS-SimpleRadioStandalone-2.1.1.0.zip'
archive_srs_2_1_1_0='DCS-SimpleRadioStandalone-2.1.1.0.zip'

url_srs_2_3_4_0='https://github.com/ciribob/DCS-SimpleRadioStandalone/releases/download/2.3.4.0/DCS-SimpleRadioStandalone-2.3.4.0.zip'
archive_srs_2_3_4_0='DCS-SimpleRadioStandalone-2.3.4.0.zip'

url_dotnet10='https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.3/windowsdesktop-runtime-10.0.3-win-x64.exe' # used for srs latest, unfortunately winetricks lacks dotnetdesktop10
file_dotnet10='windowsdesktop-runtime-10.0.3-win-x64.exe'


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

array_files_DoL=(
  "deleteshaders.sh"
  "helper-dcs.sh"
  "launch-dcs.sh"
  "texturefixer.sh"
  "vanillavoipfixer.sh"
)


###################################################################################################
#function defines
###################################################################################################
check_dependency(){
  log 'c' 'check_dependency()' "$@"
  selftest='pass'
  if [ ! -x "$(command -v wine)" ]; then selftest='fail'; log 's' 'ERROR: wine missing'; fi
  if [ ! -x "$(command -v winetricks)" ]; then selftest='fail'; log 's' 'ERROR: winetricks missing'; fi
  if [ ! -x "$(command -v git)" ]; then selftest='fail'; log 's' 'ERROR: git missing'; fi
  if [ ! -x "$(command -v wget)" ]; then selftest='fail'; log 's' 'ERROR: wget missing'; fi
  if [ ! -x "$(command -v curl)" ]; then selftest='fail'; log 's' 'ERROR: curl missing'; fi
  if [ ! -x "$(command -v cabextract)" ]; then selftest='fail'; log 's' 'ERROR: cabextract missing'; fi
  if [ ! -x "$(command -v tar)" ]; then selftest='fail'; log 's' 'ERROR: tar missing'; fi
  if [ ! -x "$(command -v unzip)" ]; then selftest='fail'; log 's' 'ERROR: unzip missing'; fi
  if [ ! -x "$(command -v touch)" ]; then selftest='fail'; log 's' 'ERROR: touch missing'; fi
  if [ ! -x "$(command -v mkdir)" ]; then selftest='fail'; log 's' 'ERROR: mkdir missing'; fi
  if [ ! -x "$(command -v chmod)" ]; then selftest='fail'; log 's' 'ERROR: chmod missing'; fi
  if ! grep -q "avx" /proc/cpuinfo; then selftest='fail'; log 's' 'ERROR: your cpu doesnt support avx'; fi
  if [ ! -x "$(command -v tty)" ]; then selftest='fail'; log 's' 'ERROR: tty missing'; fi
  if [ ! -x "$(command -v wc)" ]; then selftest='fail'; log 's' 'ERROR: wc missing'; fi
  if [ ! -x "$(command -v pkexec)" ]; then selftest='fail'; log 's' 'ERROR: pkexec missing'; fi
  if [ ! -x "$(command -v sh)" ]; then selftest='fail'; log 's' 'ERROR: sh missing'; fi
  #if [ ! -x "$(command -v mapfile)" ]; then selftest='fail'; log 's' 'ERROR: mapfile missing'; fi # find solution to search for mapfile, should be in bash v4 or higher TODO FIXME
#   find a solution to check for globbing, ex: x=(*/) TODO FIXME

  if [ ! "$selftest" = 'pass' ]; then log 's' 'dependency check failed, exiting..' ; exit 1; fi

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

terminate(){ # for subshell "exit" functionality in the event of errors
  log 'c' 'terminate()' "$@"
  kill 0 "$PPID"
}

query(){ #    $1_terminal_exit_prompts
  log 'c' 'query()' "$@"
  unset input
  if [ "$use_zenity" -eq 1 ]; then
    menu_text_zenity_line_count="$(($(echo "$menu_text_zenity" | wc -l)-1))"
    menu_type='radiolist'   # 'checklist'  #'radiolist'
    for value in "${menu[@]}"; do
      array_zenity_menu+=("FALSE")
      array_zenity_menu+=("$value")
    done
    decimal_offset=2
    menu_text_height="$((273+$decimal_offset+18+(18*$menu_text_zenity_line_count)))" #minimum: 325, nominal base(title, zero/one line): 273 ---#
    menu_height="$((30 * (${#menu[@]}-3) + $menu_text_height))"
    input="$(zenity --list --"$menu_type" --width="510" --height="$menu_height" --text="$menu_text_zenity" --title="$menu_title" --hide-header --cancel-label "$menu_cancel_label" --column="t" --column="o" "${array_zenity_menu[@]}")"
    log 'i' 'query()' "$input"
    if [ "$input" = "$nil" ] ; then #handle cancel button
      input="$menu_cancel_action"
    else
      for key in "${!menu[@]}"; do
        if [ "${menu[$key]}" = "$input" ]; then
          input="$key"
          break
        fi
      done
    fi
  else
    case "$1" in
      mainmenu) menu_exit_prompt=" or [q]:

  [q] = quit
";;
      submenu) menu_exit_prompt=" or [q/m]:

  [q] = quit
  [m] = main menu
";;
      *?) menu_exit_prompt=":
";;
      "$nil") menu_exit_prompt=":
";;
    esac
    menu_text="      ${menu_title}

${menu_text}

enter a choice [0-$((${#menu[@]}-1))]${menu_exit_prompt}"
    for key in "${!menu[@]}"; do
      menu_text="${menu_text}
  [$key] = ${menu[$key]}"
    done
    log 's' '
'
    menu_text="${menu_text}

"
    read -p "$menu_text" input 2>${active_tty}
  fi
  unset menu_exit_prompt
  unset menu_type
  unset menu_text_zenity_line_count
  unset zen_options
  unset decimal_offset
  unset menu_text_height
  unset menu_height
  unset array_zenity_menu
  unset menu_text
  unset menu_text_zenity
  unset menu_title
  unset menu_cancel_label
  unset menu_cancel_action
  unset menu
}

query_filepath(){ #    $1_prompt_text
  log 'c' 'query_filepath()' "$@"
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
" filepath_input 2>${active_tty}
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
  log 'c' 'notify()' "$@"
  if [ "$use_zenity" = 1 ]; then
    zenity --width="510" --info  --title="" --text="$1"
  else
    read -p "
$1
press [enter] to continue
" dummy 2>${active_tty}
#     echo "
# $1
# "
  fi
}

confirm(){ #    $1_question_text # WARNING only use this function where it is safe to terminate the entire proccess, as unknown or nil entry (terminal use) will exit the code. Perhaps put in a while true loop and remove the terminates for $nil) and ?)
  log 'c' 'confirm()' "$@"
  unset confirm_input
  if [ "$use_zenity" = 1 ]; then
    zenity --question --title="Confirmation" --text="$1"
    case "$?" in
      0) echo true ;;
      1) echo false ;;
      *?) log 's' "ERROR: zenity confirmation returned value $?, terminating"; terminate ;;
    esac
  else
    read -p "
$1
[y/n]?
" confirm_input 2>${active_tty}
    case "$confirm_input" in
      y) echo true ;;
      Y) echo true ;;
      yes) echo true ;;
      n) echo false ;;
      N) echo false ;;
      no) echo false ;;
      *?) log 's' "ERROR: confirmation option $confirm_input is not available, terminating"; terminate;;
      "$nil") log 's' "ERROR: confirmation option nil is not available, terminating"; terminate;;
    esac
  fi
}

select_target_dcs_prefix(){
  log 'c' 'select_target_dcs_prefix()'
  while true; do
    dir_prefix="$(query_filepath "enter the full path to your DCS prefix ('path/to/games/dcs-world')")"
    if [ ! -d "$dir_prefix" ]; then
      if [ "$(confirm 'the path you specified could not be found. would you like to try again?')" == false ]; then
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
  log 'c' 'select_target_srs_prefix()'
  while true; do
    dir_srs_prefix="$(query_filepath "enter the full path to your SRS prefix ('path/to/games/srs(-2.1.1.0)')")"
    if [ ! -d "$dir_srs_prefix" ]; then
      if [ "$(confirm 'the path you specified could not be found. would you like to try again?')" == false ]; then
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
  log 'c' 'install_dcs()' "$@"
  anchor_dir="$(pwd)"

  dir_install="$(query_filepath 'Select the directory to install DCS into')"
  if [ ! -d "$dir_install" ]; then
    notify 'invalid path, directory doesnt exist!. exiting'
    return
  fi
  dir_prefix="$dir_install/dcs-world"
  log 's' "install path: $dir_install"
  log 's' "install prefix: $dir_prefix"

  #automatic runtype detection # 0=fresh clean install, 1=file install, 2=prefix reinstall
  unset runtype
  if [ -d "$dir_prefix" ]; then
    if [ -d "$dir_prefix/$subdir_dcs_corefiles" ] && [ -d "$dir_prefix/$subdir_dcs_savedgames" ]; then
      if [ "$(confirm "'dcs-world' prefix detected, continue with consume-existing-prefix install? (will use existing files to reinstall the game)

WARNING: consume-type installers will move, not copy, the game files into the new prefix")" == true ]; then
        runtype=2
        dir_sacrificial_prefix="$dir_prefix"
      else
        notify "It will not be possible to install a prefix here without sacrifice of the existing prefix. Please choose a different install path or remove/rename the existing prefix '$dir_prefix'. exiting"
        return
      fi
    else
      notify "an exiting prefix (dcs-world) was detected, without savedgames AND core files. It is not be possible to install a prefix here without sacrifice of the existing prefix, and we are unable to sacrifice this prefix without detecting the game files. Please choose a different install path or remove/rename the existing prefix '$dir_prefix'. If you think this is wrong, ensure the existing prefix is on stable branch (we do not detect ob/cb installs) and has a savedgames folder, as well as being installed to the default path of 'C/program files/Eagle Dynamics/DCS World'. exiting"
      return
    fi
  fi
  echo "$dir_prefix" > "$dir_cfg/$cfg_dir_prefix"
  if [ -d "$dir_install/dcs-files" ]; then
    if [ "$runtype" = 2 ]; then
      notify "you already have a 'dcs-files' folder at your install path, consume-existing-prefix install will be unable to contine as it generates one during the sacrifice of the existing prefix. Your existing prefix prevents normal install.  Please rename/remove 'dcs-world'/'dcs-files', or select a different install path. exiting"
      unset runtype
      unset dir_sacrificial_prefix
      return
    fi
    if [ -d "$dir_install/dcs-files/DCS World" ] && [ -d "$dir_install/dcs-files/DCS" ]; then
      if [ "$(confirm "dcs-files detected, continue with consume-existing-files install? (will use '$dir_install/dcs-files' folder to repopulate new prefix).
Selecting no will revert to normal-install.

WARNING: consume-type installers will move, not copy, the game files into the new prefix")" == true ]; then
        runtype=1
      else
        runtype=0
      fi
    else
      notify "'$dir_install/dcs-files' was detected but sub-directorys were not found ('DCS World' and 'DCS'). This will prevent any consume-type installers from working, proceeding with normal-install."
      runtype=0
    fi
  fi

  #manual runtype selection fallback # 0=fresh clean install, 1=file install, 2=prefix reinstall
  if [ "$runtype" = "$nil" ]; then
    menu=(
      [0]="normal install"
      [1]="consume existing files (dcs-files folder)"
      [2]="consume existing prefix"
    )
    menu_text_zenity="WARNING: consume-type installers will move, not copy, the game files into the new prefix"
    menu_text="WARNING: consume-type installers will move, not copy, the game files into the new prefix"
    menu_cancel_label='cancel'
    menu_cancel_action='m'
    menu_title="Select an install method"
    query
    case "$input" in
      0) runtype=0;;
      1) runtype=1;;
      2) runtype=2;;
      m) return;;
      *?) log 's' "ERROR: option $input is not available, please try again"; return;;
      "$nil") log 's' "ERROR: option nil is not available, please try again"; return;;
    esac
    unset input
  fi

  #primary script execution beyond here
  case "$runtype" in # 0=fresh clean install, 1=file install, 2=prefix reinstall
    0) ;;

    1) notify "this should be safe, but please ensure anything important (keybinds/scripts/missions) is backed up before continuing.

Core-Files should be structured as:
$dir_install/dcs-files/DCS World

SavedGames-Files should be structured as:
$dir_install/dcs-files/DCS

WARNING: If the files are not as above, this will revert to a normal installer that asks you to download the game";;

    2) notify 'this should be safe, but please ensure anything important (keybinds/scripts/missions) is backed up before continuing.

WARNING: this will only work for a stable-release install of dcs - openbeta and closedbeta will not work without renaming the directories.'
      if [ "$dir_sacrificial_prefix" = "$nil" ] && [ ! -d "$dir_prefix" ]; then
        dir_sacrificial_prefix="$(query_filepath 'Select the SACRIFICIAL prefix (parent folder to drive_c) you wish to DESTROY to gather files for installing without download')"
      fi

      if [ ! -d "$dir_sacrificial_prefix/$subdir_dcs_corefiles" ]; then
        notify "ERROR: core files folder not found at: '$dir_sacrificial_prefix/$subdir_dcs_corefiles', exiting"
        return
      fi
      if [ ! -d "$dir_sacrificial_prefix/$subdir_dcs_savedgames" ]; then
        notify "ERROR: saved games folder not found at: '$dir_sacrificial_prefix/$subdir_dcs_savedgames', exiting"
        return
      fi
      mkdir -p "$dir_install/dcs-files"
      mv "$dir_sacrificial_prefix/$subdir_dcs_corefiles" "$dir_install/dcs-files"
      mv "$dir_sacrificial_prefix/$subdir_dcs_savedgames" "$dir_install/dcs-files"
      rm -r "$dir_sacrificial_prefix"
      unset $dir_sacrificial_prefix
      runtype=1
    ;; #from here on it is a file-based install path
  esac
  mkdir -p "$dir_prefix/cache" "$dir_prefix/runners" "$dir_prefix/files"
  if [ ! -f "/files/$file_dcs" ]; then #dcs installer
    cd "$dir_prefix/files"
    wget "$url_dcs" #--force-progress
  fi

  install_prefix_runner 'dcs' #    $1_dcs_or_srs   $2_url_forced_selection_runner
  preferred_dir_wine="$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"
  PATH_WINE_DCS="$dir_prefix/runners/$preferred_dir_wine/bin/"

  fixerscript_apache_font_crash
  install_vr_registry_edits

  cd "$dir_prefix"
  export WINEPREFIX="$dir_prefix"
  export WINEDLLOVERRIDES='wbemprox=n'
  export WINE="$dir_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
  export WINESERVER="$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
  winetricks -q corefonts xact_x64 d3dcompiler_47 vcrun2022 win10 dxvk

#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k #ensure that wine isnt running https://linux.die.net/man/1/wineserver

  case "$runtype" in # 0=fresh clean install, 1=file install, 2=prefix reinstall, reroutes to 1 here as it needs the same actions
    0) temp_string_notify="you must NOT change the default install path!

you may opt to disable the desktop icon
you may opt to download the game later by unticking the 'Start Download' box before clicking finish, then use the 'launch-dcs.sh -u' to initiate the download later"
;;
    1) temp_string_notify="you must NOT change the default install path!
you MUST untick the 'Start Download' box before you click 'finish'!

you may opt to disable the desktop icon";;
  esac
  notify "$temp_string_notify"
  unset $temp_string_notify
  export WINEPREFIX="$dir_prefix"
  export WINEDLLOVERRIDES='wbemprox=n'
  "$dir_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_prefix/files/$file_dcs"
#"$dir_prefix/runners/$preferred_dir_wine/bin/wineserver" -k
  case "$runtype" in # 0=fresh clean install, 1=file install, 2=prefix reinstall
  # NOTE unclear if dcs installer does anything besides files on disk, like registry edits, so to be safe, we run this after the installer, as the installer refuses to run if the files are detected. Done out of caution, not knowledge
    0) ;;
    1) if [ -d "$dir_install/dcs-files/DCS" ] && [ -d "$dir_install/dcs-files/DCS World" ]; then
        rm -rf "$dir_prefix/$subdir_dcs_corefiles"
        mkdir -p "$dir_prefix/$subdir_dcs_corefiles" "$dir_prefix/$subdir_dcs_savedgames"
        mv -f "$dir_install/dcs-files/DCS World" "$dir_prefix/$subdir_dcs_corefiles/.."
        mv -f "$dir_install/dcs-files/DCS" "$dir_prefix/$subdir_dcs_savedgames/.."
        rm -r "$dir_install/dcs-files"
      else
        notify "ERROR: dcs-files were not found to skip download. Installation will continue as a normal install of dcs. you should run 'launch-dcs -u' to install game files, or move them in manually after this installer completes.."
      fi
    ;;
  esac
  unset $runtype
  cd "$anchor_dir"

  notify "DCS install is now complete.

To launch DCS, execute 'launch-dcs.sh'.
To update DCS, execute 'launch-dcs.sh -u'
If you would like to know more, use 'launch-dcs.sh -h'

If you have issues, check the troubleshooting wiki or ask in matrix
https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting
https://matrix.to/#/#dcs-on-linux:matrix.org"
}

install_srs_latest(){
  log 'c' 'install_srs_latest()' "$@"
  anchor_dir="$(pwd)"
  url_srs_latest="$(get_latest_git_release 'gh' 'ciribob/DCS-SimpleRadioStandalone' '.zip')" #     $1_github_or_gitlab    $2_repoOwner/repoName    $3_file_grep_filter
  archive_srs_latest="$(echo "$url_srs_latest" | cut -d '/' -f9)"

  dir_srs_install="$(query_filepath 'Select the directory to install SRS')"
  if [ ! -d "$dir_srs_install" ]; then
    notify 'invalid path, directory doesnt exist!. exiting'
    return
  fi
  dir_srs_prefix="$dir_srs_install/srs-latest"
  log 's' "install path: $dir_srs_install"
  log 's' "install prefix: $dir_srs_prefix"

  echo "$dir_srs_prefix" > "$dir_cfg/$cfg_dir_srs_prefix"

  if [ -d "$dir_srs_prefix" ]; then
    notify 'srs prefix already exits, terminating'
    exit
  else
    mkdir -p "$dir_srs_prefix/cache" "$dir_srs_prefix/runners" "$dir_srs_prefix/files/hook-srs/Scripts" "$dir_srs_prefix/files/hook-srs/Mods/Services" "$dir_srs_prefix/drive_c/srs"

    cd "$dir_srs_prefix/drive_c/srs"
    wget "$url_srs_latest" #--force-progress
    unzip "$archive_srs_latest"

    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/DCS-SRS" "$dir_srs_prefix/files/hook-srs/Mods/Services"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Hooks" "$dir_srs_prefix/files/hook-srs/Scripts"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Export.lua" "$dir_srs_prefix/files/hook-srs/Scripts"
    if [ -d "$dir_prefix" ]; then
      temp_srs_warning="Will you install the srs hooks yourself?
We have generated the hooks for you at '$dir_srs_prefix/files/hook-srs'

WARNING: Due to case folding and dcs jank, we STRONGLY recommend using a mod manager to avoid problems.
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )"
      if [ "$(confirm "$temp_srs_warning")" == false ]; then
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

    install_prefix_runner 'srs' "$url_wine_11_staging" #    $1_dcs_or_srs   $2_url_forced_selection_runner
    preferred_dir_wine="$(cat "$dir_srs_prefix/runners/$cfg_preferred_dir_wine")"

    cd "$dir_srs_prefix"
    export WINEPREFIX="$dir_srs_prefix"
    export WINE="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q win10

    # Temporary manual install of .NET Desktop 10 until winetricks has equivalent built-in command
    mkdir -p "$dir_srs_prefix/files/dotnet10"
    cd "$dir_srs_prefix/files/dotnet10"
    wget "$url_dotnet10"
    "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/files/dotnet10/$file_dotnet10"

#     export WINEPREFIX="$dir_srs_prefix"
#     export WINEDLLOVERRIDES='icu=n,icuin=n,icuuc=n' #d3d9=n # d3d9=n fixes rendering of dropdowns to not be black, icu/icuin/icuuc fixes srs installer problems
#     "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/drive_c/srs/Client/SR-ClientRadio.exe" # test run
    cd "$anchor_dir"
    log 's' "SRS installed"
  fi
}

install_srs_2.3.4.0(){
  log 'c' 'install_srs_2.3.4.0()' "$@"
  anchor_dir="$(pwd)"

  dir_srs_install="$(query_filepath 'Select the directory to install SRS')"
  if [ ! -d "$dir_srs_install" ]; then
    notify 'invalid path, directory doesnt exist!. exiting'
    return
  fi
  dir_srs_prefix="$dir_srs_install/srs-2.3.4.0"
  log 's' "install path: $dir_srs_install"
  log 's' "install prefix: $dir_srs_prefix"

  echo "$dir_srs_prefix" > "$dir_cfg/$cfg_dir_srs_prefix"

  if [ -d "$dir_srs_prefix" ]; then
    notify 'srs prefix already exits, terminating'
    exit
  else
    mkdir -p "$dir_srs_prefix/cache" "$dir_srs_prefix/runners" "$dir_srs_prefix/files/hook-srs/Scripts" "$dir_srs_prefix/files/hook-srs/Mods/Services" "$dir_srs_prefix/drive_c/srs"

    cd "$dir_srs_prefix/drive_c/srs"
    wget "$url_srs_2_3_4_0" #--force-progress
    unzip "$archive_srs_2_3_4_0"

    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/DCS-SRS" "$dir_srs_prefix/files/hook-srs/Mods/Services"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Hooks" "$dir_srs_prefix/files/hook-srs/Scripts"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Export.lua" "$dir_srs_prefix/files/hook-srs/Scripts"

    if [ -d "$dir_prefix" ]; then
      temp_srs_warning="Will you install the srs hooks yourself?
We have generated the hooks for you at '$dir_srs_prefix/files/hook-srs'

WARNING: Due to case folding and dcs jank, we STRONGLY recommend using a mod manager to avoid problems.
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )"
      if [ "$(confirm "$temp_srs_warning")" == false ]; then
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

    install_prefix_runner 'srs' "$url_wine_11_staging" #    $1_dcs_or_srs   $2_url_forced_selection_runner
    preferred_dir_wine="$(cat "$dir_srs_prefix/runners/$cfg_preferred_dir_wine")"

    cd "$dir_srs_prefix"
    export WINEDEBUG='-all,+warn' # clean up terminal spam
    export WINEPREFIX="$dir_srs_prefix"
    export WINE="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q dotnetdesktop9 win10

#     export WINEPREFIX="$dir_srs_prefix"
#     export WINEDLLOVERRIDES='icu=n,icuin=n,icuuc=n' #d3d9=n # d3d9=n fixes rendering of dropdowns to not be black, icu/icuin/icuuc fixes srs installer problems
#     "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/drive_c/srs/Client/SR-ClientRadio.exe" # test run
    cd "$anchor_dir"
    log 's' 'SRS 2.3.4.0 installed'
  fi
}

install_srs_2.1.1.0(){ # TODO FIXME something is preventing sound working properly..
  log 'c' 'install_srs_2.1.1.0()' "$@"
  anchor_dir="$(pwd)"

  dir_srs_install="$(query_filepath 'Select the directory to install SRS')"
  if [ ! -d "$dir_srs_install" ]; then
    notify 'invalid path, directory doesnt exist!. exiting'
    return
  fi
  dir_srs_prefix="$dir_srs_install/srs-2.1.1.0"
  log 's' "install path: $dir_srs_install"
  log 's' "install prefix: $dir_srs_prefix"

  echo "$dir_srs_prefix" > "$dir_cfg/$cfg_dir_srs_prefix"

  if [ -d "$dir_srs_prefix" ]; then
    notify 'srs-2.1.1.0 prefix already exits, terminating'
    exit
  else
    mkdir -p "$dir_srs_prefix/cache" "$dir_srs_prefix/runners" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Mods/Services" "$dir_srs_prefix/drive_c/srs"

    cd "$dir_srs_prefix/drive_c/srs"
    wget "$url_srs_2_1_1_0" #--force-progress
    unzip "$archive_srs_2_1_1_0"

    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/DCS-SRS" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Mods/Services"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Hooks" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts"
    cp -r "$dir_srs_prefix/drive_c/srs/Scripts/Export.lua" "$dir_srs_prefix/files/hook-srs-v2.1.1.0/Scripts"

    if [ -d "$dir_prefix" ]; then
      temp_srs_warning="Will you install the srs hooks yourself?
We have generated the hooks for you at '$dir_srs_prefix/files/hook-srs'

WARNING: Due to case folding and dcs jank, we STRONGLY recommend using a mod manager to avoid problems.
( https://github.com/ChaosRifle/DCS-on-Linux/wiki/Installation#mod-manager )"
      if [ "$(confirm "$temp_srs_warning")" == false ]; then
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


    install_prefix_runner 'srs' "$url_wine_11_staging" #    $1_dcs_or_srs   $2_url_forced_selection_runner
    preferred_dir_wine="$(cat "$dir_srs_prefix/runners/$cfg_preferred_dir_wine")"


    cd "$dir_srs_prefix"
    export WINEARCH=win64
    export WINEPREFIX="$dir_srs_prefix"
    export WINE="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" #for winetricks
    export WINESERVER="$dir_srs_prefix/runners/$preferred_dir_wine/bin/wineserver" #for winetricks
    winetricks -q dotnet48 vcrun2022 win10 # dxvk dotnetdesktop9 xact_x64

#     export WINEARCH=win64
#     export WINEPREFIX="$dir_srs_prefix"
#     export WINEDLLOVERRIDES='d3d9=n,icu=n,icuin=n,icuuc=n' # d3d9=n fixes rendering of dropdowns to not be black, icu/icuin/icuuc fixes srs installer problems
#     "$dir_srs_prefix/runners/$preferred_dir_wine/bin/wine" "$dir_srs_prefix/drive_c/srs/SR-ClientRadio.exe" # test run
    cd "$anchor_dir"
    log 's' 'SRS 2.1.1.0 installed'
  fi
}

menu_main(){
  log 'c' 'menu_main()' "$@"
  while true; do
    menu=(
      [0]="install DCS"
      [1]="change target DCS prefix"
      [2]="manage runners"
      [3]="manage dxvk"
      [4]="troubleshooting"
      [5]="Simple Radio Standalone"
      [6]="update DoL scripts"
    )

    menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_dol}'>Github</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server
DoL logs: <a href='file://${dir_logs_helper}'>${dir_logs_helper}</a>  PLACEHOLDER!
dcs logs: <a href='file://${dir_prefix}/drive_c/users/$USER/Saved Games/DCS/Logs/'>prefix/drive_c/users/$USER/Saved Games/DCS/Logs</a>"

    menu_text="active prefix: ${dir_prefix}
DoL Github: ${url_dol}
DoL Matrix chat/help server: ${url_matrix}
DoL logs: ${dir_logs_helper}  PLACEHOLDER!
dcs logs: ${dir_prefix}/drive_c/users/$USER/Saved Games/DCS/Logs"

    menu_cancel_label='exit'
    menu_cancel_action='q'
    menu_title="DCS on Linux Community Helper"
    query 'mainmenu'
    case "$input" in
      0) install_dcs;;
      1) select_target_dcs_prefix;;
      2) menu_runners; break;;
      3) menu_dxvk; break;;
      4) menu_troubleshooting; break;;
      5) menu_srs; break;;
      6) self_update;;
      q) exit 0;;
      exit) exit 0;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input
  done
}

menu_troubleshooting(){
  log 'c' 'menu_troubleshooting()' "$@"
  while true; do
    menu=(
      [0]="winetricks"
      [1]="wine control panel"
      [2]="wine configuration"
      [3]="wine regedit"
      [4]="wineboot -u (update_prefix)"
      [5]="fix textures"
      [6]="fix vanilla voip crash"
      [7]="fix apache font crash"
      [8]="delete shaders"
      [9]="kill wineserver"
      [10]="install udev rules"
      [11]="install vr registry entries"
    )

    menu_text_zenity="<a href='${url_troubleshooting}'>Troubleshooting resources</a>
active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server
DoL logs: <a href='file://${dir_logs_helper}'>${dir_logs_helper}</a>  PLACEHOLDER!
dcs logs: <a href='file://${dir_prefix}/drive_c/users/$USER/Saved Games/DCS/Logs/'>prefix/drive_c/users/$USER/Saved Games/DCS/Logs</a>"

    menu_text="Troubleshooting resources: ${url_troubleshooting}
active prefix: ${dir_prefix}
DoL Matrix chat/help server: ${url_matrix}
DoL logs: ${dir_logs_helper}  PLACEHOLDER!
dcs logs: ${dir_prefix}/drive_c/users/$USER/Saved Games/DCS/Logs"

    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="DoL - Troubleshooting menu"
    query 'submenu'
    case "$input" in
      0) run_winetricks;;
      1) run_wine_control_panel;;
      2) run_wine_configuration;;
      3) run_wine_regedit;;
      4) run_wine_wineboot_update;;
      5) fixerscript_textures;;
      6) fixerscript_vanilla_voip_crash;;
      7) fixerscript_apache_font_crash;;
      8) fixerscript_delete_shaders;;
      9) kill_wineserver;;
      10) install_udev_rules;;
      11) install_vr_registry_edits;;
      q) exit 0;;
      exit) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input
  done
}

menu_runners(){
  log 'c' 'menu_runners()' "$@"
  while true; do
    menu=(
      [0]="install a runner"
      [1]="change active runner from installed runners"
      [2]="remove an installed runner"
      [3]="install a proton GE runner (not yet implemented!)"
    )

    menu_text_zenity="active DCS prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>"
    menu_text="active DCS prefix: ${dir_prefix}"
    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="DoL - Runner menu"
    query 'submenu'
    case "$input" in
      0) install_prefix_runner 'dcs' ;;
      1) modify_prefix_runner 'select' 'dcs';;
      2) modify_prefix_runner 'rm' 'dcs';;
      q) exit 0;;
      exit) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input
  done
}

menu_dxvk(){
  log 'c' 'menu_dxvk()' "$@"
  while true; do
    menu=(
      [0]="remove all dxvk"
      [1]="install dxvk standard"
      [2]="install dxvk nvapi"
      [3]="install dxvk git (not yet implemented!)"
    )

    menu_text_zenity="active prefix: <a href='file://${dir_prefix}'>${dir_prefix}</a>"

    menu_text="active prefix: ${dir_prefix}"

    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="DoL - DXVK menu"
    query 'submenu'
    case "$input" in
      0) remove_all_dxvk;; # ; menu_dxvk ;;
      1) install_dxvk_standard;;
      2) install_dxvk_nvapi;;
      3) install_dxvk_git;;
      q) exit 0;;
      exit) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input
  done
}

menu_srs(){
  log 'c' 'menu_srs()' "$@"
  while true; do
    menu=(
      [0]="Install SRS latest"
      [1]="change target SRS prefix"
      [2]="Install SRS 2.3.4.0"
      [3]="Install SRS 2.1.1.0"
    )

    menu_text_zenity="<a href='${url_troubleshooting}'>Troubleshooting resources</a>
active SRS prefix: <a href='file://${dir_srs_prefix}'>${dir_srs_prefix}</a>
DoL <a href='${url_matrix}'>Matrix</a> chat/help server"

    menu_text="Troubleshooting resources: ${url_troubleshooting}
active SRS prefix: ${dir_srs_prefix}
DoL Matrix chat/help server: ${url_matrix}"

    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="DoL - SRS menu"
    query 'submenu'
    case "$input" in
      0) install_srs_latest;;
      1) select_target_srs_prefix;;
      2) install_srs_2.3.4.0;;
      3) install_srs_2.1.1.0;;
      q) exit 0;;
      exit) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input
  done
}

run_winetricks(){
  log 'c' 'run_winetricks()' "$@"
  path_wine="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/"
  export WINEPREFIX="$dir_prefix"
  export WINE="$path_wine/wine"
  export WINESERVER="$path_wine/wineserver"
  winetricks
  unset $path_wine
}

run_wine_control_panel(){
  log 'c' 'run_wine_control_panel()' "$@"
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/wine" control
}

run_wine_configuration(){
  log 'c' 'run_wine_configuration()' "$@"
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/winecfg"
}

run_wine_regedit(){
  log 'c' 'run_wine_regedit()' "$@"
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/regedit"
}

run_wine_wineboot_update(){
  log 'c' 'run_wine_wineboot_update()' "$@"
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/wineboot" -u
}

kill_wineserver(){
  log 'c' 'kill_wineserver()' "$@"
  export WINEPREFIX="$dir_prefix"
  "$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/wineserver" '-k'
}

fixerscript_textures(){
  log 'c' 'fixerscript_textures()' "$@"
  if [ "$(confirm "This will edit game files to fix non-rendering textures (AH64, F18, Mi24, Ka50). This will break textures IC if you slot those aircraft. This can be undone with 'launch-dcs.sh -r' to repair the files, though you should uninstall your mods before repairing

https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-missing-textures" )" == true ]; then
    "$dir_self/texturefixer.sh" "$dir_prefix"
  fi
}

fixerscript_vanilla_voip_crash(){
  log 'c' 'fixerscript_vanilla_voip_crash()' "$@"
  if [ "$(confirm "This will edit game files to disable the vanilla voip system in the event it prevents gameplay. This can be undone with 'launch-dcs.sh -r' to repair the files, though you should uninstall your mods before repairing

https://github.com/ChaosRifle/DCS-on-Linux/wiki/Troubleshooting#date-unknown-game-launches-to-a-black-screen-entirely-or-multiplayer-crashes-on-connect-dcslog-cites-voice-chat-related-things" )" == true ]; then
    "$dir_self/vanillavoipfixer.sh" "$dir_prefix"
  fi
}

fixerscript_delete_shaders(){
  log 'c' 'fixerscript_delete_shaders()' "$@"
  if [ -d "$dir_prefix" ]; then
      if [ "$(confirm "remove mesa/dxvk cache in:
'$dir_prefix'?")" == true ]; then
      rm -rf "$dir_prefix/cache"
      mkdir "$dir_prefix/cache"
    fi
    if [ $(confirm "remove dcs shaders in:
'$dir_prefix'?") == true ]; then
      "$dir_self/deleteshaders.sh" "$dir_prefix"
    fi
  else
    notify "ERROR: prefix was not found"
  fi
}

get_latest_git_version(){ #     $1_github_or_gitlab    $2_repoOwner/repoName NOTE unused!
  log 'c' 'get_latest_git_version()'  "$@"
  case "$1" in
    gh) git_url="https://api.github.com/repos/$2/releases/latest";;
#     gl) git_url="https://gitlab.com/api/v4/projects/$2/releases/permalink/latest";; #the latest permalink seems to just be a redirect. per_page=1 works fine, so using that instead
    gl) git_url="https://gitlab.com/api/v4/projects/$2/releases?per_page=1";;
    *?) break;;
    "$nil") break;;
  esac
  echo "$(curl -s "$git_url" | grep 'tag_name' | cut -d '"' -f4)" # version
}

get_latest_git_release(){ #     $1_github_or_gitlab    $2_repoOwner/repoName    $3_file_grep_filter   TODO FIXME WARNING GITLAB FUNCTIONALITY NOT IMPLEMENTED!!!!!!
  log 'c' 'get_latest_git_release()'  "$@"
  case "$1" in
    gh)
      git_url="https://api.github.com/repos/$2/releases/latest"
      echo "$(curl -s "$git_url" | grep 'browser_download_url' | grep "$3" | cut -d '"' -f4)" # release
    ;;
    gl)
#       git_url="https://gitlab.com/api/v4/projects/$2/releases?per_page=1"
      git_url="https://gitlab.com/api/v4/projects/$2/releases/permalink/latest"
      echo "$(curl -s "$git_url" | grep 'browser_download_url' | grep "$3" | cut -d '"' -f4)" # release
    ;;
    *?) break;;
    "$nil") break;;
  esac
}

remove_all_dxvk(){
  log 'c' 'remove_all_dxvk()' "$@"
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
  log 'c' 'install_dxvk_standard()' "$@"
  remove_all_dxvk
  path_wine="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin"
  export WINEPREFIX="$dir_prefix"
  export WINE="$path_wine/wine"
  export WINESERVER="$path_wine/wineserver"
  winetricks -f dxvk
  unset $path_wine
}

install_dxvk_nvapi(){
  log 'c' 'install_dxvk_nvapi()' "$@"
  if [ "$(confirm 'I (chaos) am unsure if this can be fully uninstalled once installed. this has not been fully tested for removal. Removal may require a full prefix rebuild (which can be done without redownloading dcs). Proceed?')" == true ]; then
    path_wine="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin"
    export WINEPREFIX="$dir_prefix"
    export WINE="$path_wine/wine"
    export WINESERVER="$path_wine/wineserver"
    winetricks -f dxvk_nvapi
    unset $path_wine
  fi
}

install_dxvk_git(){ #TODO this is totally non functional as it has no input for the url. this is pseudocode that will eventually work.
  log 'c' 'install_dxvk_git()' "$@"
notify 'this is unfinished, sorry. exiting.'
exit 1
  unset url_working
  unset file_working
  url_working="$url_dxvk_gplasync"
  file_working="$file_dxvk_gpl_async" #FIXME should be archive_ not file_

  anchor_dir="$(pwd)"
  remove_all_dxvk
  export WINEPREFIX="$dir_prefix"
  path_wine="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/"

  cd "$dir_prefix/files"
  wget "$url_working" #https://github.com/doitsujin/dxvk/releases/download/vX.X.X/dxvk-X.X.X.tar.gz
  # if tar, then: tar -xzf dxvk-X.X.X.tar.gz
  #if zip, then:
  unzip "$file_working"
  #cd dxvk-X.X.X

  cp $dir_prefix/files/x64/*.dll "$dir_prefix/drive_c/windows/system32/"  #  TODO lacks quotes on command, should be corrected however needs the * wildcard to work
  cp $dir_prefix/files/x32/*.dll "$dir_prefix/drive_c/windows/syswow64/"  #  TODO lacks quotes on command, should be corrected however needs the * wildcard to work
  cd "$anchor_dir"

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

self_update(){
  log 'c' 'self_update()' "$@"
  if [ "$(confirm 'this will delete and regenerate DoL scripts from git, if you have made modifications, please back them up. Would you like to continue?')" == true ]; then
    anchor_dir="$(pwd)"
    if [ "$(git rev-parse --is-inside-work-tree)" == true ]; then
      if [ "$(confirm 'git tree detected, are you sure you want to continue? (this could remove all your changes to DoL if you are a dev!)')" == true ]; then
        git fetch --all
        git reset --hard origin/main
        git pull origin
      else
        return
      fi
    else
      mkdir -p "$dir_self/tmp"
      cd "$dir_self/tmp"
      git clone "$url_dol.git"
      for value in "${array_files_DoL[@]}"; do
        rm "$dir_self/$value"
      done
      mv $dir_self/tmp/DCS-on-Linux/tools/* "$dir_self"   #  TODO lacks quotes on command, should be corrected however needs the * wildcard to work
      cd "$anchor_dir"
      rm -rf "$dir_self/tmp" #/DCS-on-Linux"
    fi
    cd "$anchor_dir"
    "$dir_self/helper-dcs.sh"
    exit 0
  fi
}

fixerscript_apache_font_crash(){ # TODO select opensource font and download it in the else statement below.
  log 'c' 'fixerscript_apache_font_crash()' "$@"
  if [ -f "$dir_prefix/drive_c/windows/Fonts/seguisym.ttf" ]; then
    if [ "$(confirm 'detected seguisym.ttf in your prefix. remove it and continue replacing it?')" == true ]; then
      rm "$dir_prefix/drive_c/windows/Fonts/seguisym.ttf"
    else
      return
    fi
  fi
  if [ "$(confirm 'do you have a real copy of seguisym.ttf you would like to use to fix apache chashes?')" == true ]; then
    file_seguisym="seguisym.ttf"
    while true; do
      dir_seguisym="$(query_filepath 'please provide the filepath to the containing folder of your copy of seguisym.ttf')"
      if [ -f "$dir_seguisym/$file_seguisym" ]; then
        break
      else
        if [ "$(confirm "ERROR: file not found at '$dir_seguisym/$file_seguisym'. Would you like to try again?")" != true ]; then
          return
        fi
      fi
    done
  else # download file and then rename it
    notify 'You can re-run the apache font fix from the troubleshooting menu. Automatic font download is not yet supported, while we find a suitable, legal, replacement for seguisym.ttf (issue #1 on the github repo). You can get a real copy from the internet, or a windows iso/vm. You can also rename a suitable font to seguisym.ttf and use this script again. Normal execution will continue.' # FIXME
    return #TODO this is not ready for use, we need a legally viable font to use
#     wget some_seguism_website
#     dir_seguisym=""
#     file_seguisym=""
  fi
  cp "$dir_seguisym/$file_seguisym" "$dir_prefix/drive_c/windows/Fonts/seguisym.ttf"
  unset dir_seguisym
  unset file_seguisym
}

install_udev_rules(){
  log 'c' 'install_udev_rules()' "$@"
  anchor_dir="$(pwd)"
  error_udev=false
  mkdir -p "$dir_self/tmp"
  cd "$dir_self/tmp"
  echo "$dir_self/../udev/40-virpil.rules"
  if [ -f "$dir_self/../udev/40-virpil.rules" ]; then #if repo skip redundant download
    mkdir -p "$dir_self/tmp/DCS-on-Linux/udev"
    cp $dir_self/../udev/* "$dir_self/tmp/DCS-on-Linux/udev"    #  TODO lacks quotes on command, should be corrected however needs the * wildcard to work
  else
    git clone "$url_dol.git"
  fi

  # while we can run all commands with one auth via ';', it truncates the popup text making it unreadable. This way requires two auths, but allows users to read the popup code.
  pkexec sh -c "sudo mv -f $dir_self/tmp/DCS-on-Linux/udev/* /etc/udev/rules.d"
  exit_code="$?"
  if [ "$exit_code" -eq 126 ] || [ "$exit_code" -eq 127 ]; then
    error_udev=true
    log 's' 'ERROR: pkexec returned an error attempting to move udev rules'
  fi
  pkexec sh -c "sudo udevadm control --reload && sudo udevadm trigger"
  exit_code="$?"
  if [ "$exit_code" -eq 126 ] || [ "$exit_code" -eq 127 ]; then
    error_udev=true
    log 's' 'ERROR: pkexec returned an error attempting to reload udev rules'
  fi

  cd "$anchor_dir"
  rm -rf "$dir_self/tmp"
  if [ "$error_udev" == false ]; then
    notify 'udev install complete, please unplug and re-plug your devices before trying to use them.

NOTE: This automated udev script currently only supports virpil, vkb, thrustmaster, turtlebeach and winwing devices at this time. If you have hardware unsupported by these rules, or an issue caused by these rules, please notify a maintainer with your PID and VID (lsusb).'
  else
    notify 'udev rule install encountered an error and probably did not work, normal operations will continue.
If you would like to re-try, the troubleshooting menu can do so.'
  fi
}

#Log command used internally, no output to screen
log(){
  case "$1" in
    c)
      shift
      echo "$(${time_stamp}) : CONTROL FLOW: $@" | tee -a ${cmd_log} >> ${full_log}
    ;;
    i)
      shift
      echo "$(${time_stamp}) : USER INPUT: $@" | tee -a ${cmd_log} >> ${full_log}
    ;;
    e)
      shift
      echo "$(${time_stamp}) : ERROR FLOW: $@" >> ${err_log}
    ;;
    s)
      shift
      echo "$(${time_stamp}) : $@" | tee -a ${cmd_log} ${full_log} >${active_tty}
    ;;
    *?)
      echo "$(${time_stamp}) : ERROR Unknown Flag ($1): $@" | tee -a ${cmd_log} >> ${full_log}
      echo "$(${time_stamp}) : ERROR Unknown Flag ($1): $@" >> ${err_log}
    ;;
    "$nil")
      echo "$(${time_stamp}) : ERROR nil value supplied: $@" | tee -a ${cmd_log} >> ${full_log}
      echo "$(${time_stamp}) : ERROR nil value supplied: $@" >> ${err_log}
    ;;
  esac
}

#Log command used to output to terminal/screen, as well as to internal log files
#screen_log(){
#  if [[ -p /dev/stdin ]]; then
#    line="$(cat)"
#    echo "$(${time_stamp}) : ${line}" | tee -a ${cmd_log} ${full_log} >${active_tty}
#  else
#    # Handle argument input
#    echo "$(${time_stamp}) : $@" | tee -a ${cmd_log} ${full_log} >${active_tty}
#  fi
#}

install_prefix_runner(){ #    $1_dcs_or_srs   $2_url_forced_selection_runner
  log 'c' 'install_prefix_runner()' "$@"
  temp_anchor_dir="$(pwd)"
  case "$1" in
    srs)
      dir_working_prefix="$dir_srs_prefix"
      tag_active_prefix='SRS'
    ;;
    dcs)
      dir_working_prefix="$dir_prefix"
      tag_active_prefix='DCS'
    ;;
    *?) break;;
    "$nil")
      dir_working_prefix="$dir_prefix"
      tag_active_prefix='DCS'
    ;;
  esac

  if [ "$2" = "$nil" ]; then
    menu=(
#       [0]="Stable  - scLuG runner (openXR support for VR)"
      [0]="Staging - scLuG runner (openXR support for VR)"
#       [2]="Stable  - Kron4ek runner"
      [1]="Staging - Kron4ek runner"
    )

    menu_text_zenity="active $tag_active_prefix prefix: <a href='file://${dir_working_prefix}'>${dir_working_prefix}</a>
WARNING: Wine 11.5+ IS BROKEN ON ALL BRANCHES
Wine 10.3 to 11.4 requires Staging branch
If not listed, either will work"
    menu_text="active $tag_active_prefix prefix: ${dir_working_prefix}
WARNING: Wine 11.5+ IS BROKEN ON ALL BRANCHES
Wine 10.3 to 11.4 requires Staging branch
If not listed, either will work"
    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="Select a runner type"
    query 'submenu'
    case "$input" in
#       0) #stable scLug
#         url_selected_runner="$url_wine_sclug"
#         version_to_download='wine-tkg-'
#         mapfile -t array_url_wine_download <<< "$(curl -s "$url_selected_runner" | grep "browser_download_url" | grep "$version_to_download" | grep -v 'staging' | cut -d '"' -f4)"
#       ;;
      0) #staging scLug
        url_selected_runner="$url_wine_sclug"
        version_to_download='staging'
        mapfile -t array_url_wine_download <<< "$(curl -s "$url_selected_runner" | grep "browser_download_url" | grep "$version_to_download" | cut -d '"' -f4)"
      ;;
#       2) #stable kron4ek
#         url_selected_runner="$url_wine_Kron4ek"
#         version_to_download='amd64.tar'
#         mapfile -t array_url_wine_download <<< "$(curl -s "$url_selected_runner" | grep "browser_download_url" | grep "$version_to_download" | grep -v 'proton' | grep -v 'staging' | cut -d '"' -f4)"
#       ;;
      1) #staging kron4ek
        url_selected_runner="$url_wine_Kron4ek"
        version_to_download='staging-amd64.tar'
        mapfile -t array_url_wine_download <<< "$(curl -s "$url_selected_runner" | grep "browser_download_url" | grep "$version_to_download" | grep -v 'proton' | cut -d '"' -f4)"
      ;;
      e) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input

    for value in "${array_url_wine_download[@]}"; do
      menu+=("$(echo "$value" | cut -d '/' -f9)")
    done
    temp_url_pretty="$(echo "${url_selected_runner}" | cut -d '?' -f1)"
    menu_text_zenity="active $tag_active_prefix prefix: <a href='file://${dir_working_prefix}'>${dir_working_prefix}</a>
downloading from: <a href='${temp_url_pretty}'>${temp_url_pretty}</a>
WARNING: Wine 11.5+ IS BROKEN ON ALL BRANCHES
Wine 10.3 to 11.4 requires Staging branch
If not listed, either will work"
    menu_text="active $tag_active_prefix prefix: ${dir_working_prefix}
downloading from: ${temp_url_pretty}
WARNING: Wine 11.5+ IS BROKEN ON ALL BRANCHES
Wine 10.3 to 11.4 requires Staging branch
If not listed, either will work"
    menu_cancel_label='main menu'
    menu_cancel_action='m'
    menu_title="Select a version"
    query 'submenu'
    case "$input" in
      0) url_wine_download="${array_url_wine_download[$input]}";;
      1) url_wine_download="${array_url_wine_download[$input]}";;
      2) url_wine_download="${array_url_wine_download[$input]}";;
      3) url_wine_download="${array_url_wine_download[$input]}";;
      4) url_wine_download="${array_url_wine_download[$input]}";;
      5) url_wine_download="${array_url_wine_download[$input]}";;
      6) url_wine_download="${array_url_wine_download[$input]}";;
      7) url_wine_download="${array_url_wine_download[$input]}";;
      8) url_wine_download="${array_url_wine_download[$input]}";;
      9) url_wine_download="${array_url_wine_download[$input]}";;
      10) url_wine_download="${array_url_wine_download[$input]}";;
      11) url_wine_download="${array_url_wine_download[$input]}";;
      12) url_wine_download="${array_url_wine_download[$input]}";;
      13) url_wine_download="${array_url_wine_download[$input]}";;
      14) url_wine_download="${array_url_wine_download[$input]}";;
      15) url_wine_download="${array_url_wine_download[$input]}";;
      16) url_wine_download="${array_url_wine_download[$input]}";;
      17) url_wine_download="${array_url_wine_download[$input]}";;
      18) url_wine_download="${array_url_wine_download[$input]}";;
      19) url_wine_download="${array_url_wine_download[$input]}";;
      e) exit 0;;
      m) menu_main; break;;
      *?) log 's' "ERROR: option $input is not available, please try again";;
      "$nil") log 's' 'ERROR: please enter a value that is not nil';;
    esac
    unset input

    unset url_selected_runner
    unset version_to_download
    unset array_url_wine_download
    unset temp_url_pretty
  else #invoked with forced url, useful for srs to not need manual selection when it doesnt matter
    url_wine_download="$2"
  fi
  archive_wine_download="$(echo "${url_wine_download}" | cut -d '/' -f9)"
  dir_wine_download="$(echo "${url_wine_download}" | cut -d '/' -f9 | sed -E 's/\.tar\.gz//' | sed -E 's/\.tar\.xz//')"
# echo $archive_wine_download

  if [ ! -d "$dir_working_prefix/runners/$dir_wine_download" ]; then
    cd "$dir_working_prefix/runners"
    wget "$url_wine_download" #--force-progress
    tar -xvf "$archive_wine_download"
    rm -rf "$archive_wine_download"
    if [ ! -f "$dir_working_prefix/runners/$cfg_preferred_dir_wine" ]; then
      echo "$dir_wine_download" > "$dir_working_prefix/runners/$cfg_preferred_dir_wine"
    fi
  fi
#     echo $preferred_dir_wine > "$dir_prefix/runners/$cfg_preferred_dir_wine"
  cd "$temp_anchor_dir"
}

modify_prefix_runner(){ #    $1_operation_type    $2_prefix_to_operate_on
  log 'c' 'modify_prefix_runner()' "$@"
  anchor_dir="$(pwd)"

  case "$1" in
    rm)
      tag_run_type='Remove'
    ;;
    select)
      tag_run_type='Select active'
    ;;
    *?) break;;
    "$nil") break;;
  esac
  case "$2" in
    srs)
      dir_working_prefix="$dir_srs_prefix"
      tag_active_prefix='SRS'
    ;;
    dcs)
      dir_working_prefix="$dir_prefix"
      tag_active_prefix='DCS'
    ;;
    *?) break;;
    "$nil")
      dir_working_prefix="$dir_prefix"
      tag_active_prefix='DCS'
    ;;
  esac

  cd "$dir_working_prefix/runners"
  array_dirs_installed_runners=(*/)
#array_dirs_installed_runners=$(sed 's,/*$,,' <<< $array_dirs_installed_runners)
  for key in "${!array_dirs_installed_runners[@]}"; do
    array_dirs_installed_runners[$key]="$(echo "${array_dirs_installed_runners[$key]}" | sed 's,/*$,,')"
  done
  active_runner="$(cat "${dir_working_prefix}/runners/$cfg_preferred_dir_wine")"
  menu=("${array_dirs_installed_runners[@]}")
  menu_text_zenity="active ${tag_active_prefix} prefix: <a href='file://${dir_working_prefix}'>${dir_working_prefix}</a>
active runner: $active_runner"
  menu_text="active ${tag_active_prefix} prefix: ${dir_working_prefix}
active runner: $active_runner"
  menu_cancel_label='main menu'
  menu_cancel_action='m'
  menu_title="$tag_run_type $tag_active_prefix runner"
  query 'submenu'
  case "$input" in
    e) exit 0;;
    m) menu_main; break;;
    *?)
      if [[ "$input" =~ ^[0-9]+$ ]]; then #is number
        if [ "${array_dirs_installed_runners[$input]}" = "$nil" ]; then
          notify "ERROR: $input is not a valid selection, no action was performed"
        else
          case "$1" in
            rm)
              if [ "${array_dirs_installed_runners[$input]}" = "$active_runner" ]; then
                notify "ERROR: you can not remove ${array_dirs_installed_runners[$input]} because it is the active runner in this prefix! No action was performed"
              else
                if [ -d "$dir_working_prefix/runners/${array_dirs_installed_runners[$input]}" ]; then
                  #notify "TEST: we fake removed that file for you: $dir_working_prefix/runners/${array_dirs_installed_runners[$input]}"
                  rm -rf "$dir_working_prefix/runners/${array_dirs_installed_runners[$input]}"
                else
                  notify "ERROR: we could not find the directory of $dir_working_prefix/runners/${array_dirs_installed_runners[$input]}, no action was performed"
                fi
              fi
            ;;
            select)
              echo "${array_dirs_installed_runners[$input]}" > "$dir_working_prefix/runners/$cfg_preferred_dir_wine"
            ;;
          esac
        fi
      else
        notify "ERROR: $input is not a number, no action was performed"
      fi
    ;;
    "$nil") log 's' 'ERROR: please enter a value that is not nil, no action was performed';;
  esac
  unset active_runner
  unset tag_run_type
  unset input
  unset array_dirs_installed_runners
  unset dir_working_prefix
  unset tag_active_prefix

  cd "$anchor_dir"
}

install_vr_registry_edits(){ #    run in subshell to avoid collisions with variable names
  log 'c' 'install_vr_registry_edits()' "$@"
  export WINEPREFIX="$dir_prefix"

  GPU_PCI_IDS="$(udevadm info -q property -p "/sys/bus/pci/devices/0000:$(lspci | grep 'VGA'| head -n 1 | cut -f1 -d' ')" | grep PCI_ID | sed -re 's|PCI_ID=(\w+):(\w+)$|\1\n\2|g')"  # ATTRIBUTION - line from LVRA @ https://wiki.vronlinux.org/docs/games/dcs-world/#vr-setup
  GPU_VID="$(echo "${GPU_PCI_IDS}" | head -n 1)"                                                                                                                                      # ATTRIBUTION - line from LVRA @ https://wiki.vronlinux.org/docs/games/dcs-world/#vr-setup
  GPU_PID="$(echo "${GPU_PCI_IDS}" | tail -n 1)"                                                                                                                                      # ATTRIBUTION - line from LVRA @ https://wiki.vronlinux.org/docs/games/dcs-world/#vr-setup

# echo "$dir_prefix"
# echo "$PATH_WINE_DCS"

  "$PATH_WINE_DCS/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_device_vid /f  #purge old VID incase user changed gpu
  "$PATH_WINE_DCS/wine" reg delete 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_device_pid /f  #purge old PID incase user changed gpu

  "$PATH_WINE_DCS/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_device_vid /t REG_DWORD /d "${GPU_VID}" /f
  "$PATH_WINE_DCS/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_device_pid /t REG_DWORD /d "${GPU_PID}" /f
  "$PATH_WINE_DCS/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\VR' /v state /t REG_DWORD /d 00000001 /f
  "$PATH_WINE_DCS/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_device_extensions /d "VK_KHR_external_fence VK_KHR_external_memory VK_KHR_external_semaphore VK_KHR_dedicated_allocation VK_KHR_get_memory_requirements2 VK_KHR_external_memory_fd VK_KHR_external_semaphore_fd VK_KHR_external_fence_fd VK_KHR_image_format_list VK_KHR_timeline_semaphore" /f # "hello_xr -v -g Vulkan2", extensions following the xrGetVulkanGraphicsDeviceKHR log lines
  "$PATH_WINE_DCS/wine" reg add 'HKEY_CURRENT_USER\Software\Wine\VR' /v openxr_vulkan_instance_extensions /d "VK_KHR_external_memory_capabilities VK_KHR_get_physical_device_properties2 VK_KHR_external_semaphore_capabilities VK_KHR_external_fence_capabilities" /f # "hello_xr -v -g Vulkan2", extensions following the xrCreateVulkanInstanceKHR log lines

  unset GPU_PCI_IDS
  unset GPU_VID
  unset GPU_PID
}

firstrun(){
  log 'c' 'firstrun()' "$@"
  if [ "$is_firstrun" == true ]; then
    notify "Welcome to the DCS on Linux helper.
A config has been generated at:
/home/$USER/.config/dcs-on-linux

NOTE: when using gui mode, information about what the script wants you to do will be displayed as a window title (text at the top in dolphin).

WARNING: VR support is expirimental right now. Testers and help is needed. If you are expecting to run in VR and do not want to troubleshoot, use steam or umu proton installs."

    is_firstrun=false
    echo "$is_firstrun" > "$dir_cfg/$cfg_firstrun"

    if [ "$(confirm 'would you like automated generic (virpil,vkb,tm,turtle,winwing) UDEV rule install? UDEV rules tell your pc how to handle your joysticks.')" == true ]; then
      install_udev_rules
    fi
  fi
}


###################################################################################################
#startup
###################################################################################################
#Setup full script logging into full_log file
exec > >(stdbuf -oL awk '{ print strftime("%F-%T :"), $0; fflush(); }' >> ${full_log}) 2>&1
trap 'echo "Error on line $LINENO"' ERR
time_stamp="date +%F-%T"
active_tty="$(tty)"

log 'c' "======= NEW RUN ======"
if [ ! -d "$dir_logs_helper" ]; then # create log path if not existing
  mkdir -p "$dir_logs_helper"
  echo "logging directory $dir_logs_helper missing, regenerated"
fi
log 'c' "you are running v$ver of the helper script."
log 's' "you are running v$ver of the helper script."

#argument parsing
if [ "$#" -eq 0 ]; then #default run
  #   $0 -n
  #   exit 1
  log 's' 'default run detected'
else
  while getopts "ht" arg; do #arg run
    case "$arg" in
      h) log 's' "DCS on Linux Helper Script

execution: $0
[-h] help (this message)
[-t] terminal mode (disable zenity even if present)
"; exit 0 ;;
      t) disable_zenity=1 ; log 's' 'zenity overridden' ;;
      *?) log 's' "error: option -${OPTARG} is not implemented, use -h to see available swithes"; exit 1;;
    esac
  done
fi


if [ ! -d "$dir_cfg" ]; then # load or create configs
  log 's' "config not found, generating one at $dir_cfg"
  mkdir -p "$dir_cfg"
  is_firstrun=true
  echo "$dir_prefix" > "$dir_cfg/$cfg_dir_prefix"
  echo "$is_firstrun" > "$dir_cfg/$cfg_firstrun"
  echo "$dir_srs_prefix" > "$dir_cfg/$cfg_dir_srs_prefix"
else
  if [ -f "$dir_cfg/$cfg_dir_prefix" ]; then #prefix
    dir_prefix="$(cat "$dir_cfg/$cfg_dir_prefix")"
    PATH_WINE_DCS="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin/"
  else
    echo "$dir_prefix" > "$dir_cfg/$cfg_dir_prefix"
    log 's' "config file $cfg_dir_prefix missing, regenerated"
  fi
  if [ -f "$dir_cfg/$cfg_firstrun" ]; then #first run
    is_firstrun="$(cat "$dir_cfg/$cfg_firstrun")"
  else
    is_firstrun=true
    echo "$is_firstrun" > "$dir_cfg/$cfg_firstrun"
    log 's' "config file $cfg_firstrun missing, regenerated"
  fi
  if [ -f "$dir_cfg/$cfg_dir_srs_prefix" ]; then #prefix
    dir_srs_prefix="$(cat "$dir_cfg/$cfg_dir_srs_prefix")"
  else
    echo "$dir_srs_prefix" > "$dir_cfg/$cfg_dir_srs_prefix"
    log 's' "config file $cfg_dir_srs_prefix missing, regenerated"
  fi
fi


###################################################################################################
#main script
###################################################################################################
check_dependency
firstrun
log 'c' "STARTUP COMPLETE"
menu_main
