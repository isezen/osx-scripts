#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaWJa)"
#
APPNAME="XQuartz"
INSTALL=0
FORCE=0
DIR_APP="/Applications/Utilities/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
RUNSUDO="Run with sudo."
URL="http://www.xquartz.org"

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ifh
  OR
   $ sh -c "\$(curl -sL https://git.io/vaWJa)"
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME.

EOF
}

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL=$(curl -s "$URL"|
           grep -oP 'https\S*XQuartz-[0-9]\.[0-9]\.[0-9].dmg')
  fi
}

function _ver_check() {
  _get_FURL
  ver=$(echo "$FURL"|grep -oP '[0-9]\.[0-9]\.[0-9]')
  if [ -d "$DIR_APP" ]; then
    read_str="$DIR_APP/Contents/Info.plist CFBundleShortVersionString"
    # shellcheck disable=SC2086
    cur_ver=$(defaults read $read_str)
    if [[ "$ver" == "$cur_ver" ]]; then
      MSG="- $APPNAME: Latest version is installed"
      return 0
    else
      echo "* A new $APPNAME is available : (v$cur_ver -> v$ver)"
      MSG="* Updated : $APPNAME to version v$ver"
      return 2
    fi
  else
    MSG="* Installed : $APPNAME v$ver"
  fi
  return 1
}

# $1 : url
function _download() {
  url="$1"
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  # if dmg file does not exist
  if [ ! -f "$fname_tmp" ]; then
    curl -# -Lo "$fname_tmp" "$url"
  fi
  echo "$fname_tmp"
}

# $1 : file path to attach
function _setup() {
  fname=$(basename "${1}")
  hdiutil attach "$1" > /dev/null
  installer -pkg "/Volumes/${fname%.dmg}/$APPNAME.pkg" -target /
  hdiutil detach "/Volumes/${fname%.dmg}/" > /dev/null
}

function _install() {
  _get_FURL
  fname_tmp=$(_download "$FURL")
  _setup "$fname_tmp"
}

if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?if" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
      f) FORCE=1
      ;;
    esac
  done
  shift $((OPTIND-1))
else
  INSTALL=1
  FORCE=0
fi
if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi
if [[ $EUID -ne 0 ]]; then echo "$RUNSUDO"; exit; fi

if [[ $FORCE -eq 0 ]]; then
  _ver_check
  if [[ $? -ne 0 ]]; then _install; fi
else
  _install
fi
echo "$MSG"
