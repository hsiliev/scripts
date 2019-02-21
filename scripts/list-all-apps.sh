#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hao:] <page number>

Shows all apps
  -h    display this help and exit
  -a    display all pages
  -o    filter organization
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
filter_org=0
all_pages=0
page=$1

while getopts "hao:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        all_pages=1
        ;;
      o)
        filter_org=1
        ORG_GUID=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', org='$ORG_GUID', page='$page', Leftovers: $@"
echo ""

echo "Events metadata:"
EVENTS=$(cf curl "/v2/apps?results-per-page=1" | jq '.total_results')
PAGES=$((EVENTS / 100 + 1))
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

if [ $all_pages = 1 ]; then
  FILTER=""

  if [[ $filter_org = 1 ]]; then
    if [[ -z $ORG_GUID ]]; then
      ORG=$(cf target | awk '{if (NR == 4) {print $2}}')
      echo "Get organization $ORG guid ..."
      set +e
      ORG_GUID=$(cf org $ORG --guid)
      if [ $? != 0 ]; then
        echo "Organization $ORG not found !"
        exit 1
      fi
      set -e
      echo "Done."
      echo ""
    else
      echo "Using organization guid '$ORG_GUID'"
      echo ""
    fi

    FILTER="&q=organization_guid:$ORG_GUID"
  fi

  for ((i=1;i<=PAGES;i++)); do
    echo "Listing events on page: $i ..."
    cf curl "/v2/apps?results-per-page=100&page=$i$FILTER" | jq ".resources[].entity"
  done
else
  if [ -z $page ]; then
    echo "No page specified !"
    exit 1
  fi

  echo "Get app usage event #$page..."
  cf curl "/v2/apps?results-per-page=1&page=$page"
fi
