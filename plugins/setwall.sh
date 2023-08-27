#!/usr/bin/env bash

# filters plugin defining functions for styli.sh
# provides filters that output styli.sh messages to a notification system
# should override $NOTIFY_OUT and optionally $NOTIFY_ERR with a function that takes a message on stdin

# for filters that need to be defined before starting the pipeline, we have to directly check the FILTERS array
# and override relevant variables to define the behaviour of the main script
# For this the convenience function init() is provided in _lib.sh

# echo "setwall.sh::FILTERS=${FILTERS[*]}" >&2

if init setwall_hyprpaper; then
	if ! SETWALL_EXE=$(command -v hyprctl 2>/dev/null); then
		echo "required hyprctl (from Hyprland) not found. setwall_hyprpaper plugin will not work" | $NOTIFY_ERR
		return 1
	fi

	if ! command -v hyprpaper 2>/dev/null; then
		echo "required hyprpaper not found. setwall_hyprpaper plugin will not work" | $NOTIFY_ERR
		return 1
	fi

	export SETWALL=setwall_hyprpaper
fi

setwall_hyprpaper() {
	# shellcheck disable=SC2088
	$SETWALL_EXE hyprpaper unload "~/.cache/styli.sh/wallpaper.jpg" && hyprctl hyprpaper preload "~/.cache/styli.sh/wallpaper.jpg"
	# for now brute-force on all known monitors, because monitor wildcard doesn't work right
	$SETWALL_EXE monitors | awk '$1~/^Monitor/{print $2}' | while read -r m; do
		$SETWALL_EXE hyprpaper wallpaper "$m,$WALLPAPER"
	done
}
