#!/bin/bash
ver='0.2.0'


###################################################################################################
#block root use, keep this as the FIRST lines of code in the script
###################################################################################################
if [ "$(id -u)" -eq 0 ]; then
  echo 'You have run this as root, please dont run scripts off the internet as root.'
  exit 1
fi


###################################################################################################
#config
###################################################################################################
dir_cfg="/home/$USER/.config/dcs-on-linux/"
cfg_dir_prefix="prefix.cfg"
cfg_dir_srs_prefix="srs_prefix.cfg"
cfg_preferred_dir_wine="preferred_wine.cfg"
dir_dcs="drive_c/Program Files/Eagle Dynamics/DCS World/bin"
dir_logs="/home/$USER/.local/state/dcs-on-linux"
file_log_dcs="${dir_logs}/dcs_launcher.log"
default_arguments="-san"


###################################################################################################
#functions
###################################################################################################
load_dcs_wine_config() { #in function so it can be modified by switches
  if [ ! -d "$dir_cfg" ]; then # load configs
    echo "config not found, please run the helper script." | tee -a ${active_tty}
    exit 1
  else
    if [ -f "$dir_cfg/$cfg_dir_prefix" ]; then
      dir_prefix="$(cat "$dir_cfg/$cfg_dir_prefix")"
    else
      echo "config file $cfg_dir_prefix missing, exiting." | tee -a ${active_tty}
      exit 1
    fi
    if [ -f "$dir_prefix/runners/$cfg_preferred_dir_wine" ]; then
      dir_wine="$dir_prefix/runners/$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")/bin"
    else
      echo "config file $cfg_preferred_dir_wine missing, exiting." | tee -a ${active_tty}
      exit 1
    fi
  fi
  echo "dcs prefix: $dir_prefix" | tee -a ${active_tty}
  echo "dcs runner: $(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")" | tee -a ${active_tty}

  export WINEPREFIX="$dir_prefix"
  export WINEDLLOVERRIDES='wbemprox=n' #;dbghelp=n'

  export WINE_SIMULATE_WRITECOPY="1" # mandatory for F4 phantom hbui.exe, and probably F14 eventually when jesterV2 is released
  export MESA_SHADER_CACHE_DIR="$dir_prefix/cache/mesa"
  export MESA_SHADER_CACHE_MAX_SIZE="10G"
  export __GL_SHADER_DISK_CACHE="1"
  export __GL_SHADER_DISK_CACHE_PATH="$dir_prefix/cahce/gl"
  export DXVK_SHADER_CACHE_PATH="$dir_prefix/cache/dxvk"
  export DXVK_STATE_CACHE="1"
  export DXVK_STATE_CACHE_PATH="$dir_prefix/cache/dxvk"
  export WINEDEBUG='-all,+err,+openxr' # clean up terminal spam  - err, warn, all, openxr (on sclug wine only!),

  if [ "$use_hud" = '1' ]; then
    export DXVK_HUD='version,api,compiler,opacity=0.3' #full, #fps #,compiler
    #export MANGOHUD=1
  fi
}

launch_srs(){
  anchor_dir="$(pwd)"
  exec > >(stdbuf -oL awk '{ print strftime("%F-%T :"), $0; fflush(); }' >> ${file_log_dcs}) 2>&1 #Setup subshell logging, required as long as this function is called as "$(launch_srs) &"

  if [ ! -d "$dir_cfg" ]; then # load configs
    echo "config not found, please run the helper script." | tee -a ${active_tty}
    exit 1
  else
    if [ -f "$dir_cfg/$cfg_dir_srs_prefix" ]; then
      dir_srs_prefix="$(cat "$dir_cfg/$cfg_dir_srs_prefix")"
    else
      echo "config file $cfg_dir_srs_prefix missing, exiting." | tee -a ${active_tty}
      exit 1
    fi
    if [ -f "$dir_srs_prefix/runners/$cfg_preferred_dir_wine" ]; then
      active_runner_srs=$(cat "$dir_srs_prefix/runners/$cfg_preferred_dir_wine")
      dir_srs_wine="$dir_srs_prefix/runners/$active_runner_srs/bin"
    else
      echo "config file $cfg_preferred_dir_wine missing, exiting." | tee -a ${active_tty}
      exit 1
    fi
  fi

  echo "srs prefix: $dir_srs_prefix" | tee -a ${active_tty}
  echo "srs runner: $active_runner_srs" | tee -a ${active_tty}

  cd "$dir_srs_prefix/drive_c/srs"

  export WINEPREFIX="$dir_srs_prefix"
  export WINEDEBUG='-all,+err' # clean up terminal spam  - err, warn, all, openxr (on sclug wine only!),
  if [ "$(echo "$dir_srs_prefix" | grep "srs-2.1.1.0")" == "$nil" ]; then #check which version is being launched due to file restructures that happened. "if lacking -2.1.1.0 then do"
    export WINEDLLOVERRIDES='d3d9=n,icu=n,icuin=n,icuuc=n' # d3d9=n fixes rendering of dropdowns to not be black, icu/icuin/icuuc fixes srs installer problems
    "$dir_srs_wine/wine" "$dir_srs_prefix/drive_c/srs/Client/SR-ClientRadio.exe"
  else
    export WINEDLLOVERRIDES='d3d9=n' # d3d9=n fixes rendering of dropdowns to not be black
    "$dir_srs_wine/wine" "$dir_srs_prefix/drive_c/srs/SR-ClientRadio.exe"
  fi
  cd "$anchor_dir"
  unset anchor_dir
  unset active_runner_srs
}


###################################################################################################
#startup
###################################################################################################
if [ ! -d "$dir_logs" ]; then # create log path if not existing
  mkdir -p "$dir_logs"
  echo "logging directory $dir_logs missing, regenerated"
fi
if [ ! -f "$file_log_dcs" ]; then
  touch "$file_log_dcs"
  echo "$file_log_dcs missing, regenerated"
fi
echo "============================================= NEW RUN =============================================" > ${file_log_dcs} #using > instead of >> to remove previous log, as it gets big quick
exec > >(stdbuf -oL awk '{ print strftime("%F-%T :"), $0; fflush(); }' >> ${file_log_dcs}) 2>&1 #Setup full script logging into file_log_dcs
trap 'echo "Error on line $LINENO"' ERR
active_tty="$(tty)"
if ! [ "$#" -eq 0 ]; then #only run on execution with args, as default run will re-run the script with args
  echo "version: $ver" | tee -a ${active_tty}
  echo "execution: $0 $@" | tee -a ${active_tty}
fi


###################################################################################################
#main script
###################################################################################################
# echo "you are running v$ver of the launcher script." >> ${active_tty}
if [ "$#" -eq 0 ]; then #default run
  "$0" "${default_arguments}"
  exit 0
else
  while getopts "hadilnoprsuvw" arg; do #arg run, WARNING: when adding new argument char, update case d) to match the allowed arg letters
    case "$arg" in
      h) printf "
DCS on Linux Launch Script
Other Commands:
  [-h] help (this message)
  [-d] reconfigure the default run switches           - must be used with another switch, ex: [-d -san]

Modifier-Type switches (must be placed before Run-type, may be 'consumed' on use):
  [-a] enable async                                   - only works if installed dxvk supports it
  [-o] enable hud overlays like dxvk/manguhud         - config changed by editing this scripts 'DXVK_HUD' & 'MANGOHUD'
  [-p] manually provide prefix not defined by config  - NOT IMPLEMENTED!
  [-w] run as wineWayland                             - EXPERIMENTAL!

Run-Type switches (mutually exclusive, only the first will function unless otherwise noted):
  [-s] launch SRS                                     - can be used with other Run-Types, if first. ex: [-saown]
  [-l] run DCS with launcher enabled                  - only works if not disabled in options.lua / ingame settings
  [-n] run DCS with launcher disabled
  [-v] run DCS with VR parameters

  [-r] repair DCS game files
  [-u] update DCS game files
  [-i] CLI install specified module                   - must provide the string (ED's system), ex: './launch-dcs.sh -i SYRIA_terrain'


" >> ${active_tty};;
      d) sanitized_user_input_default_arguments=$(sed 's|[^-hadilnoprsuvw]||g' <<< "$2")
         sed -i "s|default_arguments=\".*\"|default_arguments=\"$sanitized_user_input_default_arguments\"|" "$0"
         if [ "$2" != "$sanitized_user_input_default_arguments" ]; then
           echo "ERROR: User input contained invalid characters that were stripped out" | tee -a ${active_tty}
         fi
         echo "Set default run arguments to $sanitized_user_input_default_arguments" | tee -a ${active_tty}
         unset sanitized_user_input_default_arguments
         exit 0 ;;

      a) export DXVK_ASYNC='1' ;;
      o) use_hud='1' ;;
      p) echo "error: arg '$arg' is not implemented!" | tee -a ${active_tty};;
      w) export DISPLAY= ; ;;

      s) $(launch_srs) & ;; #run in subshell and continue execution
      l) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS.exe" ;;
      n) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS.exe" "--no-launcher" ;;
      v) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS.exe" "--force_enable_VR --force_OpenXR --no-launcher";;

      r) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS_updater.exe" "repair" ;;
      u) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS_updater.exe" "update" ;;
      i) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS_updater.exe" 'install' "$2" ;;

      *?) echo "error: option -$OPTARG is not implemented, use -h to see available swithes" | tee -a ${active_tty}; exit 1 ;;
    esac
  done
fi

exit 0
