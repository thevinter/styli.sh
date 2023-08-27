#!/usr/bin/env bash

# Filters plugin defining functions for styli.sh
# Provides additional plugin(s) that override the function that sets the wallpaper by overriding the SETWALL variable

# for filters that need to be defined before starting the pipeline, we have to directly check the FILTERS array
# and override relevant variables to define the behaviour of the main script
# For this the convenience function init() is provided in _lib.sh

# setwall_hyprpaper
if init setwall_hyprpaper; then
	if ! SETWALL_EXE=$(command -v hyprctl 2>/dev/null); then
		echo "required hyprctl (from Hyprland) not found. setwall_hyprpaper plugin will not work" | $NOTIFY_ERR
		return 1
	fi

	if ! command -v hyprpaper &>/dev/null; then
		echo "required hyprpaper not found. setwall_hyprpaper plugin will not work" | $NOTIFY_ERR
		return 1
	fi

	export SETWALL=setwall_hyprpaper
fi

setwall_hyprpaper() {
	# shellcheck disable=SC2088
	($SETWALL_EXE hyprpaper unload "$WALLPAPER" && hyprctl hyprpaper preload "$WALLPAPER" ) 2>&1 | outdbg
	# for now brute-force on all known monitors, because monitor wildcard doesn't work right
	$SETWALL_EXE monitors | awk '$1~/^Monitor/{print $2}' | while read -r m; do
		$SETWALL_EXE hyprpaper wallpaper "$m,$WALLPAPER" 2>&1 | outdbg
	done
}
