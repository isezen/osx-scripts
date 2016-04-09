#!/bin/bash
# curl -sL https://git.io/vaWJa | sudo bash
#
APPNAME="XQuartz"
DIR_APP="/Applications/Utilities/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
RUNSUDO="Run with sudo."
URL="http://www.xquartz.org"
INSTALL=0
FORCE=0

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ifh
  OR
   $ curl -sL https://git.io/vaWJa | sudo bash
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
           grep -oe 'https\S*XQuartz-[0-9]\.[0-9]\.[0-9].dmg')
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    _get_FURL
    VER=$(echo "$FURL"|grep -oe '[0-9]\.[0-9]\.[0-9]')
  fi
}

function _ver_check() {
  _get_VER
  if [ -d "$DIR_APP" ]; then
    read_str="$DIR_APP/Contents/Info.plist CFBundleShortVersionString"
    # shellcheck disable=SC2086
    cur_ver=$(defaults read $read_str)
    if [[ "$VER" == "$cur_ver" ]]; then
      MSG="- $APPNAME: Latest version is installed"
      INSTALL=0
    else
      echo "* A new $APPNAME is available : (v$cur_ver -> v$VER)"
      MSG="* Updated : $APPNAME to version v$VER"
      INSTALL=2
    fi
  else
    MSG="* Installed : $APPNAME v$VER"
    INSTALL=1
  fi
}

# $1 : url
function _download() {
  url="$1"
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  # if dmg file does not exist
  if [ ! -f "$fname_tmp" ] || [ $FORCE -ne 0 ]; then
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
  _get_VER
  fname_tmp=$(_download "$FURL")
  _setup "$fname_tmp"
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
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

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"
