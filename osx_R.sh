#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaq3J)"
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
   $ sh -c "\$(curl -sL https://git.io/vaq3J)"
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
                grep -oP 'R-[0-9]\.[0-9]\.[0-9]\.pkg'|
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
    VER=$(echo "$var"|grep -oP '[0-9]\.[0-9]\.[0-9]')
  fi
}

function _ver_check() {
  _get_VER
  if hash R 2>/dev/null; then
    local r_loc
    local cur_ver
    r_loc="$(which R)"
    cur_ver=$($r_loc --version|grep -oP '[0-9]\.[0-9]\.[0-9]'|head -1)

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

dir_setting=$(Rscript --slave -e "cat(R.home())")
dir_setting="$dir_setting/etc"
mkdir -p "$dir_setting"
fname="Rprofile.site"
cat <<EOF > "$dir_setting/$fname"
motd <- "MESSAGE:
You can install your own packages. Nevertheless, contact admins
and ask to install for all users. Hence, everyone can benefit
and run your code without installing seperately."
mark <- "CareITU"

local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com/"
  options(repos=r)
}
)
utils::rc.settings(ipck=TRUE)
e <- baseenv()
unlockBinding("q", e)
q <- function (save="no", ...) { quit(save=save, ...) }
exit <- q
lockBinding("q", e)
cls <- function() {
  if(.Platform$GUI[1] == "Rgui"){
    if(!require(rcom, quietly = TRUE)) # Not shown any way!
      stop("Package rcom is required for 'cls()'")
    wsh <- comCreateObject("Wscript.Shell")
    if(is.null(wsh)){
      return(invisible(FALSE))
    }else{
      comInvoke(wsh, "SendKeys", "\014")
      return(invisible(TRUE))
    }
  }else{
    term <- Sys.getenv("TERM")
    if(term == "") {
      cat("\014")
      return(invisible(TRUE))
    }
    else if(term == "xterm-256color"){
      system("clear")
      return(invisible(TRUE))
    }else{
      return(invisible(FALSE))
    }
  }
}

user <- as.character(Sys.info()["user"])
host <- as.character(Sys.info()["nodename"])
host <- gsub(".local", "", host)
if (mark == "") mark <- user
rver <- paste(R.Version()\$major,R.Version()\$minor, sep=".")
prmt <- "R> "

if(Sys.getenv("TERM") == "xterm-256color"){
  suppressMessages(suppressWarnings(require("colorout")))
  prmt <- paste0("[1m",user, "[91m@[94m", host, "-","[1;31mR>[0m ")
  mark <- paste0(mark, "[91m@[0m", host)
  motd <- paste0("[35m", motd, "[0m")
}else{
  mark <- paste0(mark, "@", host)
}
options(prompt=prmt)
options(stringsAsFactors=FALSE)

.First <- function(){
  if(interactive()){
    library(utils)
    library(lintr)
    cls()
    cat(mark,"\n", sep="")
    timestamp(stamp=Sys.time(),
              prefix=paste("##------ [R ", rver,"]---[",getwd(),"] ",sep=""))
    if(motd != "") cat(motd, "\n")
  }
}

.Last <- function(){
  if(interactive()){
    hist_file <- Sys.getenv("R_HISTFILE")
    if (hist_file == "") hist_file <- "~/.RHistory"
    savehistory(hist_file)
  }
}

EOF
echo "* Created $dir_setting/$fname"
