#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-h] organization_id

Shows all apps
  -h    display this help and exit
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', org='$ORG_GUID', Leftovers: $@"
echo ""

echo "Events metadata:"
EVENTS=$(cf curl "/v2/organizations?results-per-page=1" | jq '.total_results')
PAGES=$(cf curl "/v2/organizations?results-per-page=100" | jq '.total_pages')
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

if [[ -z $ORG_GUID ]]; then
  for ((i=1;i<=PAGES;i++)); do
    echo "Listing organizations page: $i $FILTER ..."
    cf curl "/v2/organizations?results-per-page=100&page=$i$FILTER" | jq ".resources[].entity"
  done
else
  echo "Get organization $ORG_GUID..."
  cf curl "/v2/organizations/$ORG_GUID" | jq .
fi
