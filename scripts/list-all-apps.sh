#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-ha:o:]

Shows all apps
  -h    display this help and exit
  -a    display all pages
  -o    filter organization
  -p    page number
EOF
}

function echoerr {
  echo "$@" >&2;
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
FILTER_ORG=0
ALL_PAGES=0

while getopts "hao:p:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        ALL_PAGES=1
        ;;
      o)
        FILTER_ORG=1
        ORG_GUID=$OPTARG
        ;;
      p)
        PAGE=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echoerr "Arguments: show_all='$show_all', org='$ORG_GUID', page='$PAGE', Leftovers: $*"
echoerr ""

echoerr "Apps metadata:"
APPS=$(cf curl "/v2/apps?results-per-page=1" | jq '.total_results')
PAGES=$(cf curl "/v2/apps?results-per-page=100" | jq '.total_pages')
echoerr "   apps: $APPS"
echoerr "   pages : $PAGES"
echoerr "   pages : $PAGES"
echoerr ""

if [ $ALL_PAGES = 1 ]; then
  FILTER=""

  if [[ $FILTER_ORG = 1 ]]; then
    if [[ -z $ORG_GUID ]]; then
      ORG=$(cf target | awk '{if (NR == 4) {print $2}}')
      echoerr "Get organization $ORG guid ..."
      set +e
      ORG_GUID=$(cf org "$ORG" --guid)
      if [ $? != 0 ]; then
        echoerr "Organization $ORG not found !"
        exit 1
      fi
      set -e
      echoerr "Done."
      echoerr ""
    else
      echoerr "Using organization guid '$ORG_GUID'"
      echoerr ""
    fi

    FILTER="&q=organization_guid:$ORG_GUID"
  fi

  START_PAGE=1
  if [ -n "$PAGE" ]; then
    START_PAGE=$PAGE
  fi

  for ((i=START_PAGE;i<=PAGES;i++)); do
    echoerr "Listing apps on page: $i ..."
    cf curl "/v2/apps?results-per-page=100&page=$i$FILTER" | jq ".resources[].entity"
  done
else
  if [ -z "$PAGE" ]; then
    echoerr "No page specified !"
    exit 1
  fi

  echoerr "Get apps from page #$PAGE..."
  cf curl "/v2/apps?results-per-page=1&page=$PAGE"
fi
