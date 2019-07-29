#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-ha:p:]

Shows all app environments
  -h    display this help and exit
  -a    start from app number
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
app_number=1

while getopts "ha:p:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      p)
        processes=$OPTARG
        ;;
      a)
        app_number=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

APPS=$(cf curl "/v2/apps?results-per-page=1" | jq .total_results)
echoerr "Apps: $APPS"
echoerr "Processes: $processes"
echoerr "App number: $app_number"
echoerr ""

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

seq $app_number $APPS | xargs -P $processes -n 1 "$SCRIPT_DIR/list-app-environment.sh"
