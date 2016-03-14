#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaWJa)"
#
_usage() {
  cat<<EOF
  XQuartz OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "\$(curl -sL https://git.io/vaWJa)"
  ARGUMENTS:
  -i  | --install : Install XQuartz
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest
  XQuartz.
EOF
}

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

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

  if [[ $INSTALL -eq 0 ]]; then
    _usage
    exit 0
  fi
else
  INSTALL=1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo."
  exit 1
fi

# download and install XQuartz
if [ -d "/Applications/Utilities/XQuartz.app" ]; then
  echo '- XQuartz already exist.'
else
  # get latest XQuartz download url
  # shellcheck disable=SC1003
  url=$(curl -s "http://www.xquartz.org"|
        grep -e 'XQuartz-[0-9]\.[0-9]\.[0-9].\+\.dmg'|
        sed 's/\"https/\'$'\nhttps/g'|
        sed 's/\">/\'$'\n/g'|
        grep 'https')
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname_tmp" ]; then # if dmg file does not exist
    echo "* Downloading: $fname"
    curl -Lo "$fname_tmp" "$url"
  fi
  hdiutil attach "$fname_tmp" > /dev/null
  installer -pkg /Volumes/"${fname%.dmg}"/XQuartz.pkg -target /
  hdiutil detach /Volumes/"${fname%.dmg}"/ > /dev/null
  echo "* Installed: XQuartz"
fi
