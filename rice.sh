#!/usr/bin/bash

set -e 

#config files
POLYBAR_FILE="$HOME/.config/polybar/colors.ini"
WAL_FILE="$HOME/.cache/wal/colors.sh"
WAL_KITTY="$HOME/.cache/wal/colors-kitty.conf"
WAL_ROFI="$HOME/.cache/wal/colors-rofi-light.rasi"
KITTY_CONF_FL="$HOME/.config/kitty"
ROFI_CONF_FL="$HOME/.config/rofi/"
ROFI_CONF="$HOME/.config/rofi/config.rasi"

pywal_get(){
  #get theme based on wallpaper
  echo "setting pywal color scheme based on color..."
  wal -i "$1" -q -t
}

change_polybar_colors(){
  #backup config before changing
  echo "backing up config first"
  cp $POLYBAR_FILE $HOME/.config/polybar/colors.ini.bak
 
  #change lines in config using sed to match color scheme
  echo "changing polybar conf..."
  sed -i "s/^background = #.*/background = $BG/g" $POLYBAR_FILE
  sed -i "s/^foreground = #.*/foreground = $FG/g" $POLYBAR_FILE
  sed -i "s/^primary = #.*/primary = $PC/g" $POLYBAR_FILE
  sed -i "s/^secondary = #.*/secondary = $SC/g" $POLYBAR_FILE
  sed -i "s/^alert = #.*/alert = $AC/g" $POLYBAR_FILE
  sed -i "s/^disabled = #.*/disabled = $DC/g" $POLYBAR_FILE
}

change_rofi_colors(){
  #backup config before changing 
  echo "backing up rofi config..."
  cp $ROFI_CONF "$HOME/.config/rofi/config.rasi.bak"
  #copy config from wal directory to rofi directory
  cp $WAL_ROFI $ROFI_CONF_FL

  #create new config file 
  echo "changing rofi conf..."
  cat > $ROFI_CONF << EOF
configuration {
  show-icons:      true;
  display-drun:    "";
  disable-history: false;
}

* {
  font: "JetBrainsMono-Regular 12";
}

@theme "~/.config/rofi/colors-rofi-light.rasi"
EOF
}

change_kitty_colors(){
  #backup config before changing
  echo "backing up kitty config..." 
  cp $KITTY_CONF_FL/kitty.conf $KITTY_CONF_FL/kitty.conf.bak 
  #copy wal config to kitty config directory
  cp $WAL_KITTY $KITTY_CONF_FL
  #change include line to include wal config
  echo "changing kitty.conf"
  sed -i "s/include .*/include colors-kitty.conf/g" $KITTY_CONF_FL/kitty.conf
}

#check if wal is installed
if [[ -x "`which wal`" ]]; then
  #check if wallpaper supplied as argument
  if [[ "$1" ]]; then
    #generate colorscheme based on wal
    pywal_get "$1"

    #check if wal file created 
    if [[ -e "$WAL_FILE" ]]; then
      . "$WAL_FILE"
    else
      echo "Color file does not exist, exiting..."
      exit 1
    fi
      #assign variables from wal file to variables in script
      BG=`printf "%s\n" "$background"`
      FG=`printf "%s\n" "$foreground"`
      PC=`printf "%s\n" "$color0"`
      SC=`printf "%s\n" "$color1"`
      AC=`printf "%s\n" "$color2"`
      DC=`printf "%s\n" "$color3"`
      
      #run functions to change color scheme
      change_rofi_colors
      change_kitty_colors
      change_polybar_colors
  else
    echo -e "Please enter a path to a wallpaper.\n"
    echo "Usage: ./rice.sh path/to/image"
  fi

else
    echo "pywal is not installed!"
    echo "Installing it now."
    sudo pacman -S python-pywal  
fi
