#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaJoi)"
#
_usage() {
  cat<<EOF
  Ubuntu Fonts OSX Installer Script v16.03.09
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "\$(curl -sL https://git.io/vaJoi)"
  ARGUMENTS:
  -i  | --install : Install Ubuntu Fonts
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest
  Ubuntu Fonts Family.
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
  if [[ $INSTALL -eq 0 ]]; then
    _usage
    exit 0
  fi
else
  INSTALL=1
fi

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

# Handle right user name
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER

# install sublime text
dir_fonts="/Users/$USR/Library/Fonts"
if [ -f  "$dir_fonts/Ubuntu-M.ttf" ]; then
  echo '- Ubuntu Fonts already exist.'
else
  # get latest Ubuntu Fonts download url
  # shellcheck disable=SC1003
  url=$(curl -s "http://font.ubuntu.com"|
        grep -e 'zip'|
        sed 's/\"\.\./\'$'\n\"\.\./g'|
        sed 's/\"/\"\'$'\n/2'|grep "\"../")
  url="${url//\"}" # remove " symbols, curl complains
  url=$(echo "$url" | sed -e 's/\.\./http:\/\/font.ubuntu.com/g')
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname_tmp" ]; then # if zip file does not exist
  	echo "* Downloading: $fname"
    curl -s -o "$fname_tmp" "$url"
  fi
  # shellcheck disable=SC2035
  unzip -qoj "$fname_tmp" *.ttf -d "$dir_fonts/"
  echo "* Installed: Ubuntu Fonts"
fi
