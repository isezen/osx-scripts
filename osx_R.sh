#!/bin/bash
# curl -sL https://git.io/vaq3J | bash
#
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
APPNAME="R"
ONLYMAC="This script is ONLY for MAC OSX."
RUNSUDO="Run with sudo."
URL="https://cran.r-project.org/bin/macosx/"
INSTALL=0
FORCE=0
MP=0

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -imfh
  OR
   $ curl -sL https://git.io/vaq3J | bash
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -m  | --macports : Install by macports
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME. If you set -m parameter,
  R is installed using macports; otherwise,
  is installed from CRAN official web site.
  If newer R release exist, it is upgraded.

EOF
}

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL="$URL$(curl -s "$URL"|
                grep -oe 'R-[0-9]\.[0-9]\.[0-9]\.pkg'|
                head -1)"
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    local var=
    if [[ $MP -eq 0 ]]; then
      _get_FURL
      var="$FURL"
    else
      var=$(port info R)
    fi
    VER=$(echo "$var"|grep -oe '[0-9]\.[0-9]\.[0-9]')
  fi
}

function _ver_check() {
  _get_VER
  if hash R 2>/dev/null; then
    local r_loc
    local cur_ver
    r_loc="$(which R)"
    cur_ver=$($r_loc --version|grep -oe '[0-9]\.[0-9]\.[0-9]'|head -1)

    if [[ "$VER" == "$cur_ver" ]]; then
      MSG="- $APPNAME: Latest version is installed"
      INSTALL=0
    else
      echo "* A new $APPNAME is available : (v$cur_ver -> v$VER)"
      MSG="* Updated : $APPNAME to version v$VER"
      INSTALL=2
    fi
  else
    MSG="* Installed : $APPNAME v$VER"
    INSTALL=1
  fi
}

function _download() {
  url="$1"
  fname=${url##*/} # get filename
  fname_tmp="/tmp/$fname"
  # if dmg file does not exist
  if [ ! -f "$fname_tmp" ] || [ $FORCE -ne 0 ]; then
    curl -# -Lo "$fname_tmp" "$url"
  fi
  echo "$fname_tmp"
}

function _install() {
  _get_VER
  if [[ $MP -eq 0 ]]; then
    fname_tmp=$(_download "$FURL")
    installer -pkg "$fname_tmp" -target /
  else
    var=$(port installed R)
    if [[ $var =~ .*None.* ]]; then
      port install R +builtin_lapack +cairo +gcc5 +recommended +tcltk +x11
    else
      echo "- R already installed."
      echo "- If you want to upgrade; run:"
      echo "$ sudo port selfupdate && sudo port upgrade outdated"
    fi
  fi
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
}

if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?imf" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
      m) MP=1
      ;;
      f) FORCE=1
      ;;
    esac
  done
  shift $((OPTIND-1))
else
  INSTALL=1
  if hash port 2>/dev/null; then MP=1; fi
fi
if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi
if [[ $EUID -ne 0 ]]; then echo "$RUNSUDO"; exit; fi
if [[ $MP -ne 0 ]]; then
  if ! hash port 2>/dev/null; then
    echo "* Macports is not installed"; exit
  fi
fi

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

# Predefined Settings

dir_setting=$(Rscript --slave -e "cat(R.home())")/etc
fname="Rprofile.site"
mkdir -p "$dir_setting"
sudo curl -# -o "$dir_setting/$fname" "https://raw.githubusercontent.com/isezen/osx-scripts/master/settings/Rprofile.site"
if [ $? -eq 0 ]; then
  echo "* Created $dir_setting/$fname"
fi
