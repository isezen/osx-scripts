#!/bin/bash
# sh -c "$(curl -sL https://git.io/vacoq)"
#
_usage() {
  cat<<EOF
  Telegram OSX Installer Script v16.03.09
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ih
  OR
   $ sh -c "\$(curl -sL https://git.io/vacoq)"
  ARGUMENTS:
  -i  | --install : Install Telegram
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest Telegram.

EOF
}

function getUriFilename() {
  crl=/usr/bin/curl
  echo $($crl -sI "$1"|
           tr -d '\r'|
           grep -o -E 'Location:.*$'|
           sed 's/Location: //g')
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

if [[ $INSTALL -eq 0 ]]; then
  _usage
  exit 0
fi

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

dir_app="/Applications/Telegram.app"
ver=$(curl -s "https://desktop.telegram.org"|
      grep -e 'og:description'|
      sed 's/content=\"v /\'$'\n/g'|
      sed 's/ /\'$'\n/g'|
      grep -e '[0-9]\.[0-9]\.[0-9][0-9]')
if [ -d "$dir_app" ]; then
  cur_ver="$(defaults read $dir_app/Contents/Info.plist CFBundleShortVersionString)"
  if [[ "$ver" == "$cur_ver" ]]; then
    echo "- Telegram already exist and up-to-date. (ver: $ver)"
    exit 0
  fi
fi

# Install Telegram
crl=/usr/bin/curl
url="https://tdesktop.com/mac"
url=$(getUriFilename "$(getUriFilename $url)")
url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
fname=${url##*/} # get filename
fname_tmp="/tmp/$fname"
if [ ! -f "$fname_tmp" ]; then # if dmg file does not exist
  echo "* Downloading: $fname"
  curl -s -o "$fname_tmp" "$url"
fi
hdiutil attach "$fname_tmp" > /dev/null
cp -r /Volumes/Telegram\ Desktop/Telegram.app /Applications/
hdiutil detach /Volumes/Telegram\ Desktop/ > /dev/null
echo "* Installed: Telegram"


