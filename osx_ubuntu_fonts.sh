#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaJoi)"
#
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
APPNAME="Ubuntu Fonts"
INSTALL=0
DIR_APP="/Users/$USR/Library/Fonts"

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ih
  OR
   $ sh -c "\$(curl -sL https://git.io/vaJoi)"
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -h | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install
  latest $APPNAME.

EOF
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

# Install Ubuntu Fonts
function _install() {
  url="http://font.ubuntu.com"
  url=$(curl -s "$url"|
        grep -oP '\.\S*ubuntu-font-family-[0-9]\.[0-9][0-9].zip'|
        sed -e 's/\.\./http:\/\/font.ubuntu.com/g'|
        sed 's/ /%20/g')
  fname_tmp=$(_download "$url")
  # shellcheck disable=SC2035
  unzip -qoj "$fname_tmp" *.ttf -d "$DIR_APP/"
  MSG="* Installed: $APPNAME"
}

INSTALL=0
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
    MSG="This script is ONLY for MAC OSX."
  else
    if [ -f  "$DIR_APP/Ubuntu-M.ttf" ]; then
      MSG="- $APPNAME already exist."
    else
      _install
    fi
  fi
  echo "$MSG"
fi

