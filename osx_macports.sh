#!/bin/bash
#
# 2016-03-06
# Ismaıl SEZEN sezenismail@gmail.com
# WARNING: ONLY FOR OSX
# Usage: sudo ./osx_macports.sh -i
# This script will download and install macports and all required ports.
# see ports.txt and ports_settings.txt files what will be installed.

_usage() {
  cat<<EOF
  Macports OSX Installer Script 2016 Ismail SEZEN
    Installs latest Macports for Mac OSX and
    predefined ports.
  Usage: sudo $0 -ih
  -i  | --install : Install Macports
  -h  | --help    : Shows this message.
EOF
}

INSTALL=0
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

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo."
  exit 1
fi

# Check if XCode was installed
if [ ! -d "/Applications/Xcode.app" ]; then
  echo '* Please, install Xcode first.'
  exit 0
fi

# download and install Macports
if hash port 2>/dev/null; then
 echo '- macports already exist.'
else
  # get latest Macports download url
  url="https://www.macports.org/install.php"
  url=$(grep -e 'ElCapitan.pkg' <(curl -s "$url")|
        sed 's/\"https/\'$'\n\"https/g'|
        sed 's/\"/\"\'$'\n/2'|
        grep 'https'|
        uniq)
  url="${url//\"}" # remove " symbols, curl complains
  fname=${url##*/} # get filename
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname" ]; then # if pkg file does not exist
    echo "* Downloading: $fname"
    curl -s -o "$fname" "$url"
  fi
  installer -pkg "$fname" -target /
  exp_cmd="export PATH=\"/opt/local/bin:/opt/local/sbin:$PATH\""
  sudo -u "$SUDO_USER" echo "$exp_cmd"  >> ~/.profile
  source ~/.profile
fi

# Install ports

ports=$(sed -e '/^$/d' -e 's/#.*$//'<<EOF
m4
tmux
re2
geos
xz
coreutils
shellcheck
wget
zlib
hdf4
hdf5 # library and file format for storing scientific data
curl
netcdf
wgrib2
aspell
hunspell
cairo
curl
ffmpeg
gawk
gdal
grep
gsed
ImageMagick
udunits
udunits2
subversion
zmq
VLC
vim
gnuplot # A command-driven interactive function plotting program
gsl     # A numerical library for C and C++ programmers
texlive
R
git     # A fast version control system

python27
py27-re2                # Python wrapper of Google's RE2 library
py27-pyx                # PyX is a TeX/LaTeX interface for Python
py27-Pillow
py27-polygon            # Python bindings for General Polygon Clipping Library
py27-pil                # Python Imaging Library
py27-metar              # python interface to the weather reports of the NOAA
py27-beautifulsoup
py27-posixtimezone      # tzinfo implementation for python
py27-tz                 # World Timezone Definitions for Python
py27-setuptools
py27-rpy2               # A simple and efficient access to R from Python
py27-pyshp              # Python Shapefile Library
py27-opengl             # Python binding to OpenGL
py27-nose               # A Python unittest extension.
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
py27-par                # Parallel Python
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
py27-ipython +notebook
py27-pyside
py27-fiona
py27-fipy
py27-pptx               # Create and update PowerPoint files.
py27-jupyter

opencv +python27
EOF
)

while read p; do
  var=$(port installed "$p")
  if [[ $var =~ .*None.* ]]; then
    port install "$p"
    echo
  else
    echo "INSTALLED ALREADY: $p"
  fi
done  < <(echo "$ports")

# Other settings
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


# install linter for R
# R --slave -e "library(devtools); install_github('jimhester/lintr')"

