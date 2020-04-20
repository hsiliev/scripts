#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-h]

Shows all apps
  -h    display this help and exit
EOF
}

function echoerr {
  echo "$@" >&2;
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "hao:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echoerr "Service keys metadata:"
KEYS=$(cf curl "/v2/service_keys?results-per-page=1" | jq '.total_results')
PAGES=$(cf curl "/v2/service_keys?results-per-page=100" | jq '.total_pages')
echoerr "   service keys: $KEYS"
echoerr "   pages : $PAGES"
echoerr ""

for ((i=1;i<=PAGES;i++)); do
  echoerr "Listing service keys on page: $i ..."
  cf curl "/v2/service_keys?results-per-page=100&page=$i" | jq ".resources[].entity"
done
