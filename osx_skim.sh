#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaJg2)"
#
_usage() {
  cat<<EOF
  Skim PDF OSX Installer Script v16.03.09
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "\$(curl -sL https://git.io/vaJg2)"
  ARGUMENTS:
  -i  | --install : Install Skim PDF
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest Skim.app
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

# install skim.app
dir_app="/Applications/Skim.app"
if [ -d  "$dir_app" ]; then
 echo '- Skim already exist.'
else
  # get latest Skim download url
  url_main="https://sourceforge.net"
  url1="/projects/skim-app/files/Skim/"
  url="$url_main/$url1"
  # shellcheck disable=SC1003
  url=$(curl -s "$url"|
        grep -e "$url1"|
        sed 's/\"\//\'$'\n\"\//g'|
        sed 's/\"/\"\'$'\n/2'|
        grep '\"\/projects'|head -1)

  url="${url//\"}" # remove " symbols, curl complains
  url="${url%?}"
  fname="${url##*/}" # get filename
  url="$url_main$url/$fname.dmg/download"
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  fname="$fname.dmg"
  fname_tmp="/tmp/$fname"
  if [ ! -f "$fname_tmp" ]; then # if dmg file does not exist
    echo "* Downloading: $fname"
    curl -oL "$fname_tmp" "$url"
  fi

  hdiutil attach "$fname_tmp" > /dev/null
  cp -r /Volumes/Skim/Skim.app /Applications/
  hdiutil detach /Volumes/Skim/ > /dev/null
  rm "$fname_tmp"
  echo "* Installed: Skim.app"
fi

