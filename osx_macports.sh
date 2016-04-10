#!/bin/bash
# curl -sL https://git.io/v2pMc | sudo bash
#
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
APPNAME="Macports"
ONLYMAC="This script is ONLY for MAC OSX."
RUNSUDO="Run with sudo."
URL="https://www.macports.org/install.php"
INSTALL=0
FORCE=0

function _usage() {
  cat<<EOF
  $APPNAME OSX Installer Script v16.03.14
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
   $ $0 -ifh
  OR
   $ curl -sL https://git.io/v2pMc | sudo bash
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install
  latest $APPNAME and app predefined ports
  and settings.

EOF
}

# Ports to install
ports=$(cat <<EOF
links             # WWW browser with text and graphics modes.
htop
openssh +ssh_copy_id
libGLU
glpk              # required for R package: Rglpk
libiconv          # Required for R package: git2r
openmpi
mpich
m4
tmux
re2
geos
xz
coreutils   # fileutils, shellutils, and textutils
findutils   # GNU find, xargs, and locate
diffutils   # GNU diff, diff3, sdiff, and cmp
renameutils # qmv, qcp, imv, icp and deurlname
moreutils   # chronic, combine, errno, pee, ...
parallel    # Build and execute shell command lines in parallel
shellcheck  # Shell linter
wget
zlib
hdf5        # library and file format for storing scientific data
curl
netcdf
wgrib2
aspell
hunspell
cairo
ffmpeg
gawk
gdal
grep
gsed
getopt
gnutar
grc         # Generic Colouriser for colourising logfiles and output
ImageMagick # Image processing tools
udunits     # Unit Conversion
udunits2
subversion  # Version Control System
zmq         # Messaging kernel
gnuplot     # A command-driven interactive function plotting program
gsl         # A numerical library for C and C++ programmers
texlive     # LaTeX
git         # A fast version control
filezilla   # FTP, FTPS and SFTP Client
trash       # OSX command line trash support
macports-notifier
ncdu
p7zip
fish       # command line shell

python27
py-pygments
py-bpython
bpython_select
py27-readline
py27-gnureadline
py-readline
py-gnureadline
py-pylzma
py27-virtualenv         # virtualenv is a tool to create isolated Python
py27-numeric            # Fast and multidimensional array language facility
py27-re2                # Python wrapper of Google's RE2 library
py27-pyx                # PyX is a TeX/LaTeX interface for Python
py27-Pillow             # Python Imaging Library
py27-polygon            # Python bindings for General Polygon Clipping Library
py27-metar              # python interface to the weather reports of the NOAA
py27-beautifulsoup
py27-posixtimezone      # tzinfo implementation for python
py27-tz                 # World Timezone Definitions for Python
py27-setuptools
py27-rpy2               # A simple and efficient access to R from Python
py27-pyshp              # Python Shapefile Library
py27-opengl             # Python binding to OpenGL
py27-nose               # A Python unittest extension.
py27-nose-testconfig    # nose-testconfig is a plugin to the nose framework
py27-liblzma
py27-jedi
py27-pip
py27-future
py27-tzlocal            # tzinfo object for the local timezone
py27-pep8               # Python style guide checker
py27-flake8-pep8-naming
py27-flake8
py27-pylint             # Error (and style) checking for python
py27-dateutil
py27-nose
py27-cython
py27-mpi4py +openmpi    # MPI for Python - Python bindings for MPI
py27-mpi4py             # MPI for Python - Python bindings for MPI
py27-numpydoc           # Sphinx extension to support docstrings in Numpy
py27-numpy              # The core utilities for the scientific library scipy
py27-scientific         # Scientific Python
py27-tables
py27-pycluster          # Python module for clustering
py27-netcdf4            # Python/numpy interface to netCDF
py27-instant
py27-gnuplot
py27-cairo
py27-cairosvg
py27-parsing
py27-matplotlib
py27-matplotlib-basemap # toolkit for plotting data on map projections
py27-memprof            # Memprof is a memory profiler for Python.
py27-scipy
py27-sclapp             # framework for writing command-line applications
py27-scitools           # Scientific computing tools for Python
py27-scimath            # The Enthought scimath package
py27-scikits-bvp_solver # Solve two-point boundary-value problems
py27-scikits-bootstrap  # Confidence interval estimation routines for SciPy
py27-scikit-learn       # Machine learning in Python
py27-scikits-module     # provides the files common to all scikits
py27-scikit-image       # Image processing algorithms for SciPy.
py27-pandas
py27-tstables           # Handles large time series using PyTables and Pandas
py27-patsy
py27-statsmodels
py27-seaborn            # Statistical data visualization library
py27-pysparse           # a fast sparse matrix library for Python
py27-sfepy              # Simple finite elements in python
py27-backports-lzma
py27-notebook
py27-ipython +notebook
py27-pyside
py27-fiona
py27-fipy
py27-pptx               # Create and update PowerPoint files.
py27-jupyter +qtconsole
py-jupyter
opencv +python27
vim +python27           # Python Scripting with vim
MacVim +python27
EOF
)

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL="$(curl -s "$URL"|
                grep -oe 'https\S*MacPorts-[0-9]\.[0-9]\.[0-9]\S*pkg'|
                head -1)"
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    _get_FURL
    VER=$(echo "$FURL"|
          grep -oe '[0-9]\.[0-9]\.[0-9]')
  fi
}

function _ver_check() {
  _get_VER
  if hash port 2>/dev/null; then
    cur_ver=$(port version)
    cur_ver=$(echo "$cur_ver"|grep -oP '[0-9]\.[0-9]\.[0-9]')
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

function _install() {
  _get_VER
  fname_tmp=$(_download "$FURL")
  installer -pkg "$fname_tmp" -target /
  if [ -z "${MSG+x}" ]; then MSG="* Installed : $APPNAME v$VER"; fi
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
if [ ! -d "/Applications/Xcode.app" ]; then
  echo '* Please, install Xcode first.'; exit
fi
if [[ $EUID -ne 0 ]]; then echo "$RUNSUDO"; exit; fi

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

# Add export statement into bash_profile
exports=$(cat <<EOF
export PATH="/opt/local/bin:/opt/local/sbin:\$PATH" # for ports
export PATH="/opt/local/libexec/gnubin:\$PATH" # for GNU tools
export PYTHONPATH=/opt/local/lib/python2.7/site-packages/:\$PYTHONPATH # for Meld
EOF
)
for fl in ~/.bash_profile ~/.bash_login ~/.profile; do
  if [ -f "$fl" ]; then
    fmt="\n#\n%s\n"
    note="# Macports OSX Installer addition on "
    # shellcheck disable=SC2059
    grep -q "$note" "$fl" ||
    printf "$fmt" "$note$(date +'%Y-%m-%d %H:%M:%S')" >> "$fl"
    while read e; do
      grep -q "$e" "$fl" || echo "$e" >> "$fl"
    done <<< "$exports"
    break
  fi
done

source "$fl"

while read p; do
  # shellcheck disable=SC2086
  var=$(port installed $p)
  if [[ $var =~ .*None.* ]]; then
    # shellcheck disable=SC2086
    port install $p
    echo
  fi
done <<< "$(echo "$ports" | sed -e 's/#.*$//' | sed -e '/^$/d')"



# Other settings
echo
port select --set python python27
port select --set python2 python27
port select --set cython cython27
port select --set ipython py27-ipython
port select --set ipython2 py27-ipython
port select --set sphinx py27-sphinx
port select --set py-cairosvg py27-cairosvg
port select --set pep8 pep8-27
port select --set pyflakes py27-pyflakes
port select --set flake8 flake8-27
port select --set pip pip27
port select --set memprof py27-memprof
port select --set mpi mpich-mp-fortran
port select --set pylint pylint27
port select --set py-sympy py27-sympy
port select --set mpi openmpi-mp-fortran
port select --set virtualenv virtualenv27
port select --set nosetests nosetests27

