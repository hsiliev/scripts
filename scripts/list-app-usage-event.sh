#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hfa] <page number>

Shows app usage events
  -h    display this help and exit
  -f    filter current organization
  -a    show all events
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0
filter_org=0
page=$1

while getopts "haf:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        show_all=1
        unset page
        ;;
      f)
        show_all=1
        unset page
        ORG_GUID=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', filter_org='$ORG_GUID', page='$page', Leftovers: $@"
echo ""

echo "Reading events metadata ..."
EVENTS=$(cf curl "/v2/app_usage_events?results-per-page=10000" | jq '.total_results')
PAGES=$((EVENTS / 10000 + 1))
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

echo "App usage events metadata:"
if [ $show_all = 1 ]; then
  for ((i=1;i<=PAGES;i++)); do
    echo "Listing events on page: $i ..."
    if [[ -z $ORG_GUID ]]; then
      cf curl "/v2/app_usage_events?results-per-page=10000&order-direction=desc&page=$i" | jq .
    else
      cf curl "/v2/app_usage_events?results-per-page=10000&order-direction=desc&page=$i" | jq ".resources[] | select(.entity.org_guid == \"$ORG_GUID\")"
    fi
  done
else
  cf curl "/v2/app_usage_events?results-per-page=1" | jq 'del(.resources)'
  if [ -z $page ]; then
    echo "No page specified !"
    exit 1
  fi

  echo "Get app usage event page #$page..."
  cf curl "/v2/app_usage_events?results-per-page=10000&page=$page"
fi
echo ""
