#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaTdJ)"
#
_usage() {
  cat<<EOF
  RStudio OSX Installer Script v16.03.09
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "\$(curl -sL https://git.io/vaTdJ)"
  ARGUMENTS:
  -i  | --install : Install RStudio
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest
  RStudio and all predefined settings.
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

# Check if R was installed
if ! hash R 2>/dev/null; then
  echo '* Please, install R first.'; exit 0
fi

# download and install RStudio
if [ ! -d "/Applications/RStudio.app" ]; then
  echo '- RStudio already exist.'
else
  # get latest RStudio download url
  # shellcheck disable=SC1003
  url=$(curl -s "https://www.rstudio.com/products/rstudio/download/"|
  grep -e 'RStudio-[0-9]\.[0-9][0-9]\.[0-9].\+\.dmg'|
  sed 's/\"https/\'$'\nhttps/g'|
  sed 's/\">/\'$'\n/g'|
  grep 'https')
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname_tmp" ]; then # if dmg file does not exist
    echo "* Downloading: $fname"
    curl -o "$fname_tmp" "$url"
  fi
  hdiutil attach "$fname_tmp" > /dev/null
  cp -r /Volumes/"${fname%.dmg}"/RStudio.app /Applications/
  hdiutil detach /Volumes/"${fname%.dmg}"/ > /dev/null
  echo "* Installed: RStudio"
fi


# install linter for R
# R --slave -e "library(devtools); install_github('jimhester/lintr')"
