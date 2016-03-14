#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaq3J)"
#
_usage() {
  cat<<EOF
  R OSX Installer Script v16.03.11
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ sudo $0 -imh
  OR
    $ sudo sh -c "\$(curl -sL https://git.io/vaq3J)"
  ARGUMENTS:
  -i  | --install  : Install R
  -m  | --macports : Install by macports
  -h  | --help     : Shows this message.
  DESCRIPTION:
  This script will download and install latest R.
  If you set -m parameter, R is installed using
  macports; otherwise, is installed from CRAN
  official web site. If newer R release exist,
  it is upgraded.
EOF
}

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

INSTALL=0
MP=0
if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?im" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
      m) MP=1
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
  # if auto-install, check macports.
  # if exist, install macports version.
  if hash port 2>/dev/null; then
    MP=1
  fi
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo."
  exit 1
fi

if [[ $MP -eq 0 ]]; then
  # Check installed R version if exist
  ver=
  # shellcheck disable=SC1003
  if [ -f /usr/bin/R ]; then
    ver=$(/usr/bin/R --version |
          grep -e '[0-9]\.[0-9]\.[0-9]'|
          sed 's/version /\'$'\n1a2wc=/g'|
          sed 's/ (/\'$'\n/g'|
          grep '1a2wc='|
          sed 's/1a2wc=//g')
  fi
  # get latest R download url
  urlp="https://cran.r-project.org/bin/macosx/"
  # shellcheck disable=SC1003
  fname=$(curl -s "$urlp"|
          grep -e 'R-[0-9]\.[0-9]\.[0-9]\.pkg'|
          sed 's/href=\"/\'$'\nhref/g'|
          sed 's/\">/\'$'\n/g'|
          grep 'href'|
          sed 's/href//g')
  url="$urlp$fname"
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  ver2=${fname#*-}; ver2=${ver2%.*}

  # Compare installed and remote version numbers
  if [ -n "$ver" ]; then
    if [ "$ver" == "$ver2" ]; then
      echo "- R already exist and up-to-date! Version: $ver"
      INSTALL=0
    else
      echo "- A new R Version ($ver > $ver2) exist."
    fi
  else
    echo "* Installing R Version ($ver2)"
  fi

  if [[ $INSTALL -eq 1 ]]; then
    fname_tmp="/tmp/$fname"
    if [ ! -f "$fname_tmp" ]; then # if pkg file does not exist
      echo "* Downloading: $fname"
      curl -o "$fname_tmp" "$url"
    fi
    installer -pkg "$fname_tmp" -target /
    rm "$fname_tmp"
    echo "* Installed: R ($ver2)"
  fi
else
  var=$(port installed R)
  if [[ $var =~ .*None.* ]]; then
    port install R
    echo
  else
    echo "- R already installed."
    echo "- If you want to upgrade; run:"
    echo "$ sudo port selfupdate && sudo port upgrade outdated"
  fi
fi
