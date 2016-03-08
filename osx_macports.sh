#!/bin/bash
#
_usage() {
  cat<<EOF
  Macports OSX Installer Script v16.03.08
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ sudo $0 -ih
  OR
    $ sudo sh -c "$(curl -s -L https://git.io/v2pMc)"
  ARGUMENTS:
  -i  | --install : Install Macports
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest
  macports and all predefined ports and settings.
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

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo."
  exit 1
fi

# Check if XCode was installed
if [ ! -d "/Applications/Xcode.app" ]; then
  echo '* Please, install Xcode first.'; exit 0
fi

# download and install Macports
if hash port 2>/dev/null; then
  echo '- macports already exist.'
  # if macports was installed
  # preprare for ports to install or update.
  port selfupdate
  port upgrade outdated
else
  # get latest Macports download url
  url="https://www.macports.org/install.php"
  # shellcheck disable=SC1003
  # TODO: Add download due to OSX version.
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
fi

# Install ports

ports=$(cat <<EOF
openmpi-default
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
ImageMagick # Image processing tools
udunits     # Unit Conversion
udunits2
subversion  # Version Control System
zmq         # Messaging kernel
gnuplot     # A command-driven interactive function plotting program
gsl         # A numerical library for C and C++ programmers
texlive     # LaTeX
R           # Statistical Language
git         # A fast version control system

python27
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
py27-jupyter

opencv +python27
vim +python27           # Python Scripting with vim
EOF
)

while read p; do
  # shellcheck disable=SC2086
  var=$(port installed $p)
  if [[ $var =~ .*None.* ]]; then
    # shellcheck disable=SC2086
    port install $p
    echo
  fi
done <<< "$(echo "$ports" | sed -e 's/#.*$//' | sed -e '/^$/d')"

# Add export statement into bash_profile
for fl in ~/.bash_profile ~/.bash_login ~/.profile; do
  if [ -f "$fl" ]; then
    # Get right user name
    [[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
    # Add required path macports to work properly.
    exp="/opt/local/bin:/opt/local/sbin"
    if ! grep -q "$exp" "$fl"; then
      note="# Macports OSX Installer addition on $(date +'%Y-%m-%d %H:%M:%S')"
      printf "\n##\n%s\nexport PATH=\"%s:\$PATH\" # for macports\n" "$note" "$exp" >> "$fl"
    fi

    # Make GNU tools default.
    exp="/opt/local/libexec/gnubin"
    if ! grep -q "$exp" "$fl"; then
      printf "export PATH=\"%s:\$PATH\" # for GNU tools\n" "$exp" >> "$fl"
    fi
    source "$fl"
    break
  fi
done

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


# install linter for R
# R --slave -e "library(devtools); install_github('jimhester/lintr')"
