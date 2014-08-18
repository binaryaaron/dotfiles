#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ $SOURCE == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET"
  fi
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

theme_command="dircolors $DIR/themes"
gnome_command="$DIR/gnome"

if [ "$1" != "" ]; then
  case $1 in
    light )
      theme_command="$theme_command/light"
      gnome_command="$gnome_command/set_light.sh"
      eval `$theme_command`
      $gnome_command
      ;;
    dark )
      theme_command="$theme_command/dark"
      gnome_command="$gnome_command/set_dark.sh"
      eval `$theme_command`
      $gnome_command
      ;;
    * )
      echo "Usage: solarize (dark|light)" ;;
  esac
else
  echo "Usage: solarize (dark|light)"
  exit 1
fi
