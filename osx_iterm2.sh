#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaT0V)"
#
APPNAME="iTerm"
DIR_APP="/Applications/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
URL="https://www.iterm2.com/downloads.html"
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
   $ sh -c "\$(curl -sL https://git.io/vacoq)"
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
    FURL="$(curl -s "$URL"|
           grep -oP 'https\S*iTerm2-[0-9]_[0-9]_[0-9]\S*zip'|
           sort -t_ -rn -k1,1 -k2,2 -k3,3|
           head -1)"
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    _get_FURL
    VER=$(echo "$FURL"|
          grep -oP '[0-9]_[0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'|
          sed 's/_/\./g')
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

function _install() {
  _get_VER
  fname_tmp=$(_download "$FURL")
  unzip -qo "$fname_tmp" -d /Applications
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
}

if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?i" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
    esac
  done
  shift $((OPTIND-1))
else
  INSTALL=1
fi

if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

