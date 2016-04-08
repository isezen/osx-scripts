#!/bin/bash
# curl -sL https://git.io/vauql | bash
#
APPNAME="Meld"
DIR_APP="/Applications/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
URL="https://github.com/yousseb/meld/releases/tag/osx-v1"
INSTALL=0
FORCE=0

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.16
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ifh
  OR
   $ curl -sL https://git.io/vauql | bash
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME.

EOF
}

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL="https://github.com/yousseb/meld/releases/download/osx-v1/meldmerge.dmg"
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    _get_FURL
    VER="NA"
  fi
}

function _ver_check() {
  _get_VER
  if [ -d "$DIR_APP" ]; then
    read_str="$DIR_APP/Contents/Info.plist CFBundleShortVersionString"
    # shellcheck disable=SC2086
    cur_ver=$(defaults read $read_str)
    if [ $VER == "NA" ]; then
      VER=$cur_ver
      echo "* Version can not be detected. Current v$cur_ver"
      MSG="* Updated : $APPNAME to version v$VER"
      INSTALL=2
    else
      if [[ "$VER" == "$cur_ver" ]]; then
        MSG="- $APPNAME: Latest version is installed"
        INSTALL=0
      else
        echo "* A new $APPNAME is available : (v$cur_ver -> v$VER)"
        MSG="* Updated : $APPNAME to version v$VER"
        INSTALL=2
      fi
    fi
  else
    MSG="* Installed : $APPNAME v$VER"
    INSTALL=1
  fi
}

# $1 : url
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

# $1 : file path to attach
# $2 : Path to Volume
# $3 : Path to install dir
function _setup() {
  idir=$3
  if [ -z "${3+x}" ]; then idir="/Applications/"; fi
  DIR=$(dirname "${2}")
  hdiutil attach "$1" > /dev/null
  cp -r "/Volumes$2" $idir
  hdiutil detach "/Volumes$DIR/" > /dev/null
}

function _install() {
  _get_VER
  fname_tmp=$(_download "$FURL")
  _setup "$fname_tmp" "/Meld Merge/$APPNAME.app"
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
}

# shellcheck disable=SC2120
function _create_symlink() {
  path_bin="/usr/local/bin"
  fmeld="$path_bin/meld"
  meld_script=$(cat <<EOF
#!/bin/sh
for arg in $@; do
    if [ -e \$arg ]; then
        arg="\$(cd "\$(dirname "\${arg}")" && pwd)/\$(basename "\${arg}")"
    fi
    new_args="\$new_args\$arg "
done
open -n /Applications/Meld.app --args \$new_args
EOF
)
  if [ ! -f "$fmeld" ]; then
    local cmd1="mkdir -p $path_bin"
    local cmd2="echo '$meld_script' > $fmeld"
    if [[ $EUID -ne 0 ]]; then
      sudo sh -c "$cmd1 && $cmd2 && chmod +x $fmeld"
    else
      sh -c "$cmd1 && $cmd2 && chmod +x $fmeld"
    fi
    echo "* Created Symlink [$fmeld]"
  else
    echo "- [$fmeld] exist."
  fi
}

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
  FORCE=0
fi
if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"
# shellcheck disable=SC2119
_create_symlink
