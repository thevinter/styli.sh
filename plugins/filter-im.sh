#!/usr/bin/env bash

# filters plugin defining functions for styli.sh
# provides filters that can be applied to fetched wallpapers by executing an
# imagemagick (required dependency for this) hook

if ! IMCONV=$(command -v convert); then
	echo "WARNING: convert (part of imagemagick) not found, filters not functional" >&2
fi
if ! IMCOMP=$(command -v composite); then
	echo "WARNING: composite (part of imagemagick) not found, filters not functional" >&2
fi
if ! IMIDENT=$(command -v identify); then
	echo "WARNING: identify (part of imagemagick) not found, filters not functional" >&2
fi

# logo_overlay <logo file>
logo_overlay() {
	if [ ! $# -eq 1 ]; then
		echo "logo_overlay requires 1 arguments, $# given, doing nothing" >&2
		return
	fi
	if [ ! -f "$1" ]; then
		echo "logo_overlay: $1 does not exist, doing nothing" >&2
		return
	fi
	# set -x
	tmpdir=$(mktemp -d)

	logo="$1"
	origwp="$tmpdir/origwp.png"
	mask="$tmpdir/mask.png"
	cutmask="$tmpdir/cut.png"
	invert="$tmpdir/invert.png"

	$IMCONV "$WALLPAPER" "$origwp"  2>/dev/null # convert instead of copy to get the type right (png from jpg to do alpha stuff)
	wpgeom="$($IMIDENT "$origwp" | awk '{ print $3 }')"

	$IMCONV "$logo" -alpha extract -resize "$wpgeom" `#-define png:color-type=6` "$mask" 2>/dev/null
	$IMCOMP -compose CopyOpacity "$mask" "$origwp" "$cutmask" 2>/dev/null
	$IMCONV "$cutmask" -channel RGB -negate "$invert" 2>/dev/null
	$IMCONV "$origwp" "$invert" -gravity center -composite "$WALLPAPER" 2>/dev/null

	[ -d "$tmpdir" ] && rm -rf "$tmpdir"
	# set +x
}