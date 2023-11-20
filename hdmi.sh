#!/bin/bash

GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'
COLOR_GE80=${COLOR_GE80:-#00FF00}
COLOR_GE60=${COLOR_GE60:-#FFF600}
COLOR_GE40=${COLOR_GE40:-#FFAE00}
COLOR_DOWN=${COLOR_DOWN:-#FF0000}

if [[ "$(xrandr | grep -o 'HDMI-[0-9]\+\sconnected\s[0-9]\+x[0-9]\+')" ]]; then
  matched_string="$(xrandr | grep -o 'HDMI-[0-9]\+\sconnected\s[0-9]\+x[0-9]\+' | grep -o '[0-9]\+x[0-9]\+')"
  echo -e "[$matched_string]"
  echo $COLOR_GE80
else
  echo "down"
  echo $COLOR_DOWN
fi
