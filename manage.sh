#!/bin/bash

# Manage arguments
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

usage()
{
    cat <<EOF

    usage: $0 [-m <message-string>] -s
           $0 -l

    This script manages updates of atom configuration

    OPTIONS:
    -m --message <STR>    Commit message (used by --save)
    -s --save             Save current configuration
    -l --load             Load configuration from remote
    -h --help             Show this help menu
EOF
}

SAVE=false
LOAD=false
MESSAGE=

# getopt
GOTEMP="$(getopt -o "m:slh" -l "message:,save,load,help"  -n '' -- "$@")"

if [[ -z "$(echo -n $GOTEMP |sed -e"s/\-\-\(\s\+.*\|\s*\)$//")" ]]; then
    usage; exit;
fi

eval set -- "$GOTEMP"

while true ;
do
    case "$1" in
      -m | --message)
          MESSAGE=$2
          shift 2;;
      -s | --save)
          SAVE=true
          shift;
          break;;
      -l | --load)
          LOAD=true
          shift;
          break;;
      -h | --help)
          echo "on help"
          usage; exit;
          shift;
          break;;
      --) shift ;
          break ;;
    esac
done

echo $MESSAGE

# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
if [[ $LOAD == true ]]; then
  echo "Loading from remote ..."
  git pull
  apm list --installed --bare > ~/.atom/curr_package.list
  diff -u ~/.atom/curr_package.list ~/.atom/package.list | grep "^+[^+]" | \
    sed -e"s/^+//" > ~/.atom/new_package.list
  apm install --packages-file ~/.atom/new_package.list
fi
if [[ $SAVE == true ]]; then
  echo "Saving to remote ..."
  if [[ -z $MESSAGE ]]; then
    MESSAGE="update config"
  fi
  apm list --installed --bare > ~/.atom/package.list
  git commit -am "${MESSAGE}"
  git push
fi
