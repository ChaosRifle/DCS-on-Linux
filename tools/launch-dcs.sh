#!/bin/bash
ver='0.0.1'


###################################################################################################
#block root use, keep this as the FIRST lines of code in the script
###################################################################################################
if [ "$(id -u)" -eq 0 ]; then
  echo 'You have run this as root, please dont run scripts off the internet as root.'
  exit 0
fi

dir_cfg="/home/$USER/.config/dcs-on-linux/"
cfg_dir_prefix="prefix.cfg"
cfg_preferred_dir_wine="preferred_wine.cfg"
dir_dcs="drive_c/Program Files/Eagle Dynamics/DCS World/bin"


load_dcs_wine_config() { #in function so it can be modified by switches
  if [ ! -d "$dir_cfg" ]; then # load configs
    echo "config not found, please run the helper script."
    exit 0
  else
    if [ -f "$dir_cfg/$cfg_dir_prefix" ]; then
      dir_prefix="$(cat "$dir_cfg/$cfg_dir_prefix")"
    else
      echo "config file $cfg_dir_prefix missing, exiting."
      exit 0
    fi
    if [ -f "$dir_prefix/runners/$cfg_preferred_dir_wine" ]; then
      dir_wine="$dir_prefix/runners/"$(cat "$dir_prefix/runners/$cfg_preferred_dir_wine")"/bin"
    else
      echo "config file $cfg_preferred_dir_wine missing, exiting."
      exit 0
    fi
  fi


  export WINEPREFIX="$dir_prefix"
  export WINEDLLOVERRIDES='wbemprox=n' #;dbghelp=n'

  export WINE_SIMULATE_WRITECOPY="1" # mandatory for F4 phantom hbui.exe, and probably F14 eventually when jesterV2 is released
  export MESA_SHADER_CACHE_DIR="$dir_prefix/cache/mesa"
  export MESA_SHADER_CACHE_MAX_SIZE="10G"
  export __GL_SHADER_DISK_CACHE="1"
  export __GL_SHADER_DISK_CACHE_PATH="$dir_prefix/cahce/gl"
  export DXVK_STATE_CACHE_PATH="$dir_prefix/cache/dxvk"
  export WINEDEBUG='-all' # clean up terminal spam

  # export DXVK_HUD=fps #,compiler
  # export MANGOHUD=1
}

echo "you are running v$ver of the launcher script."
if [ $# -eq 0 ]; then #default run
  $0 -n
  exit 1
else
  while getopts "hdilnpruvw" arg; do #arg run
    case $arg in
      h) printf "DCS on Linux Launch Script
execution: $0
[-h] help (this message)
[-d] set script default switches (arguments) used when run with no switches, must be used with another switch, ex: [-d -n] - NOT IMPLEMENTED!
[-i] run updater with arguments to install a module - NOT IMPLEMENTED!
[-l] run DCS with launcher enabled - WARNING: only works if you do not disable launcher in options.lua / ingame settings
[-n] run DCS with launcher disabled
[-p] run with custom prefix path not defined by config - NOT IMPLEMENTED!
[-r] repair DCS game files
[-u] update DCS game files
[-v] run SRS - NOT IMPLEMENTED!
[-w] run as wineWayland, must come BEFORE a 'run' argument to function! ex: [-wn] - WARNING: EXPERIMENTAL!
";;
      d) echo 'NOT YET IMPLEMENTED, please edit the if statement in the script that says "$0 -n" to have the flag you want as default, by replacing the "n" with another arg, like "l", so it says "$0 -l"'; exit 0 ;; #changing the default run type is WIP - FIXME
      i) echo $(dirname $(readlink -f $0)); echo "$arg is not implemented!" ;;
      l) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS.exe" ;;
      n) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS.exe" "--no-launcher" ;;
      p) echo "$arg is not implemented!" ;;
      r) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS_updater.exe" "--repair" ;;
      u) load_dcs_wine_config; "$dir_wine/wine" "$dir_prefix/$dir_dcs/DCS_updater.exe" "--update" ;;
      v) echo "$arg is not implemented!" ;;
      w) export DISPLAY= ;;
      ?) echo "error: option -$OPTARG is not implemented, use -h to see available swithes"; exit ;;
    esac
  done
fi

exit 1
