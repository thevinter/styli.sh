#!/usr/bin/env bash

# filters plugin defining functions for styli.sh
# provides filters that can be applied to fetched wallpapers by executing an
# imagemagick (required dependency for this) hook

if ! IM=$(command -v magick); then
	echo "WARNING: magick (imagemagick) not found, filters not functional" >&2
fi

