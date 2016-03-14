#!/bin/bash
# sh -c "$(curl -sL https://git.io/vacoq)"
#
APPNAME="Telegram"
INSTALL=0
DIR_APP="/Applications/$APPNAME.app"

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ih
  OR
   $ sh -c "\$(curl -sL https://git.io/vacoq)"
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -h | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME.

EOF
}

function _getUriFilename() {
  curl -sI "$1"|
    tr -d '\r'|
    grep -o -E 'Location:.*$'|
    sed 's/Location: //g'
}

function _ver_check() {
  ver=$(curl -s "https://desktop.telegram.org"|
        grep -e 'og:description'|
        grep -oP '[0-9]\.[0-9]\.[0-9][0-9]')
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
    curl -# -o "$fname_tmp" "$url"
  fi
  echo "$fname_tmp"
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

# Install Telegram
function _install() {
  url="https://tdesktop.com/mac"
  url=$(_getUriFilename "$(_getUriFilename $url)")
  # in case of download link was not updated,
  # replace version number by new one.
  url=${url//[0-9]\.[0-9]\.[0-9][0-9]/$ver}
  # replace space by %20
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g')
  fname_tmp=$(_download "$url")
  _setup "$fname_tmp" "/Telegram Desktop/Telegram.app"
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

if [[ $INSTALL -eq 0 ]]; then _usage; else
  if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is ONLY for MAC OSX."
  else
    _ver_check
    if [[ $? -ne 0 ]]; then _install; fi
    echo "$MSG"
  fi
fi
