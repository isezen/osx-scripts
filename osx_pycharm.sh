#!/bin/bash
# sh -c "$(curl -sL https://git.io/va2oQ)"
#
APPNAME="PyCharm"
DEFAULT_VER="5.0.4"
DIR_APP="/Applications/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
URL="https://www.jetbrains.com/pycharm/download"
DIRECT_LINK="https://download.jetbrains.com/python/pycharm-%s-%s-%s.dmg"
INSTALL=0
FORCE=0
PRO=0
JDK=0

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.16
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ifh
  OR
   $ sh -c "\$(curl -sL https://git.io/va2oQ)"
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -f | --force   : Force to reinstall
  -p | --pro     : Professional Ed.
  -j | --jdk     : JDK Bundled version
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME.

EOF
}


js="var system = require('system');var page = require('webpage').create();\
page.open('%s', function(){console.log(page.content);phantom.exit();});"

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    if hash phantomjs 2>/dev/null; then
      local url="$URL/download-thanks.html?platform=mac"
      local type="professional"
      if [ "$PRO" -eq 0 ]; then
        url="$url&code=PCC"
        type="community"
      fi
      # shellcheck disable=SC2059
      jstmp=$(printf "$js" "$url")
      FURL=$(bash -c "phantomjs <(echo \"$jstmp\")"|
              grep -oP "https\S*pycharm-$type-\S*dmg"|
              head -1)
    else
      [ $JDK -ne 0 ] && str_jdk="jdk-bundled" || str_jdk=""
      # shellcheck disable=SC2059
      FURL=$(printf "$DIRECT_LINK" "$type" "$DEFAULT_VER" "$str_jdk")
    fi
    if [ $JDK -eq 0 ]; then FURL=${FURL//"-jdk-bundled"/}; fi
    _get_VER
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    VER="$DEFAULT_VER"
    if [ -n "${FURL+x}" ]; then
      VER=$(echo "$FURL"|grep -oP '[0-9][0-9][0-9][0-9]\.[0-9]')
    else
      if hash phantomjs 2>/dev/null; then
        # shellcheck disable=SC2059
        jstmp=$(printf "$js" "$URL")
        # MAKE SURE PROCESS SUBSTITUTION RUN UNDER BASH
        # PROCESS SUBSTITUTION IS NOT SUPPORTED BY SH.
        VER=$(bash -c "phantomjs <(echo \"$jstmp\")"|
               grep -oP 'data-code="PCP">[0-9][0-9][0-9][0-9]\.[0-9]</span>'|
               grep -oP '[0-9][0-9][0-9][0-9]\.[0-9]')
      fi
    fi
  fi
}

function _ver_check() {
  _get_VER
  if [ -d "$DIR_APP" ]; then
    info_plist="$DIR_APP/Contents/Info.plist"
    cur_ver=$(defaults read "$info_plist" CFBundleShortVersionString)
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

# $1 : file path to attach
# $2 : Path to Volume
# $3 : Path to install dir
function _setup() {
  idir=$3
  if [ -z "${3+x}" ]; then idir="/Applications/"; fi
  DIR=$(dirname "${2}")
  hdiutil attach "$1" > /dev/null
  cp -r "/Volumes$2" $idir
  hdiutil detach "/Volumes$DIR/" > /dev/null
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

function _install() {
  _get_FURL
  fname_tmp=$(_download "$FURL")
  fname=${url##*/} # get filename
  local vol_path="/$APPNAME/$APPNAME.app"
  _setup "$fname_tmp" "$vol_path"
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
}

if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?ifpj" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
      f) FORCE=1
      ;;
      p) PRO=1
      ;;
      j) JDK=1
      ;;
    esac
  done
  shift $((OPTIND-1))
else
  INSTALL=1
fi

if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi

[ $PRO -eq 0 ] && CE=" CE" || CE=""
APPNAME="$APPNAME$CE"
DIR_APP="/Applications/$APPNAME.app"

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

# Config Locations for PyCharm
# Configuration:
# ~/Library/Preferences/<PRODUCT><VERSION>
# Caches:
# ~/Library/Caches/<PRODUCT><VERSION>
# Plugins:
# ~/Library/Application Support/<PRODUCT><VERSION>
# Logs:
# ~/Library/Logs/<PRODUCT><VERSION>

