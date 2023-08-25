#!/usr/bin/env bash

# filters plugin defining functions for styli.sh
# provides filters that output styli.sh messages to a notification system
# should override $NOTIFY_OUT and optionally $NOTIFY_ERR with a function that takes a message on stdin

# for filters that need to be defined before starting the pipeline, we have to directly check the FILTERS array
# and override relevant variables to define the behaviour of the main script
# For this the convenience function init() is provided in _lib.sh

echo "notify.sh::FILTERS=${FILTERS[*]}" >&2

# notify_send
if init notify_send; then
	if ! NOTIFY_EXE=$(command -v notify-send 2>/dev/null); then
		echo "required notify-send (from libnotify) not found. notify_send plugin will not work" | $NOTIFY_ERR
		return 1
	fi
	# shellcheck disable=SC2034
	NOTIFY_OUT=_notify_send_out
	NOTIFY_ERR=_notify_send_err
fi

_notify_send_out() {
	$NOTIFY_EXE "styli.sh:" "$(cat -)"
}

_notify_send_err() {
	$NOTIFY_EXE "styli.sh [error]:" "$(cat -)"
}