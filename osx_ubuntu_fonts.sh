#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaJoi)"
# Note: NO need Version Control
#
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
APPNAME="Ubuntu Fonts"
DIR_APP="/Users/$USR/Library/Fonts"
ONLYMAC="This script is ONLY for MAC OSX."
URL="http://font.ubuntu.com"
INSTALL=0
FORCE=0

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
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install
  latest $APPNAME.

EOF
}

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL=$(curl -s "$URL"|
           grep -oP '\.\S*ubuntu-font-family-[0-9]\.[0-9][0-9].zip'|
           sed -e 's/\.\./http:\/\/font.ubuntu.com/g'|
           sed 's/ /%20/g')
  fi
}

# $1 : url
function _download() {
  url="$1"
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  # if dmg file does not exist
  if [ ! -f "$fname_tmp" ] || [ $FORCE -ne 0 ]; then
    curl -# -o "$fname_tmp" "$url"
  fi
  echo "$fname_tmp"
}

# Install Ubuntu Fonts
function _install() {
  _get_FURL
  fname_tmp=$(_download "$FURL")
  # shellcheck disable=SC2035
  unzip -qoj "$fname_tmp" *.ttf -d "$DIR_APP/"
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME"; fi
}

INSTALL=0
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
fi
if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi

if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

