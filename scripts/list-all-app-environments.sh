#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hp:]

Shows all app environments
  -h    display this help and exit
  -p    search processes
EOF
}

function echoerr {
  echo "$@" >&2;
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
processes=5

while getopts "hp:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      p)
        processes=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

APPS=$(cf curl "/v2/apps?results-per-page=1" | jq .total_results)
echoerr "Apps: $APPS"
echoerr "Processes: $processes"
echoerr ""

seq 1 $APPS | xargs -P 5 -n 1 list-app-environment.sh
