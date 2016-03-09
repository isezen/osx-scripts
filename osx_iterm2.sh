#!/bin/bash
#
_usage() {
  cat<<EOF
  iTerm2 OSX Installer Script v16.03.08
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "$(curl -sL )"
  ARGUMENTS:
  -i  | --install : Install iTerm2
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest (even Beta)
  iTerm2 and whole predefined settings.
EOF
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

# install iTerm2
dir_app="/Applications/iTerm.app"
if [ -d  "$dir_app" ]; then
  echo '- iTerm2 already exist.'
else
  # get latest iTerm2 download url (even beta)
  # shellcheck disable=SC1003
  url=$(curl -s 'https://www.iterm2.com/downloads.html'|
  grep -e 'iTerm2-[0-9]_[0-9]_[0-9]'|
  sed 's/\"https/\'$'\nhttps/g'|
  sed 's/zip\"></zip\'$'\n/g'|
  grep 'https'|
  sort -t_ -rn -k1,1 -k2,2 -k3,3|
  head -1)
  fname=${url##*/} # get filename
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname" ]; then # if zip file does not exist
  	echo "* Downloading: $fname"
    curl -s -o "$fname" "$url"
  fi
  unzip -qo "$fname" -d "/Applications/"
  rm "$fname"
  echo "* Installed: iTerm2"
fi

