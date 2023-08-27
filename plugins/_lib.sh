#!/usr/bin/env bash

# init returns true (0) if $1 (filter name) is contained in FILTERS and then removes this name from the filters array
# This is for filters that need to override global styli.sh variables directly after loading the plugins
init() {
	if [[ " ${FILTERS[*]} " = *" $1 "* ]]; then
		# echo "defining functions for $1" >&2
		# remove notify_send from FILTERS array, because it has now "done its job" and is not executed itself later
		FILTERS=("${FILTERS[@]/$1}")
		return 0
	fi
	return 1
}
