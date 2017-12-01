#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-h] <grep pattern>

Get org usage
  -h,-? display this help and exit
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

cf orgs | grep $1 | xargs -P 100 -n 1 delete-org.sh
