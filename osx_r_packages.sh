#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaLDq)"
#
_usage() {
  cat<<EOF
  R packages OSX Installer Script v16.03.09
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ sudo $0 -ih
  OR
    $ sudo sh -c "\$(curl -sL https://git.io/vaLDq)"
  ARGUMENTS:
  -i  | --install : Install R Packages
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will install predefined R packages.
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
r_exist=0
for fl in /usr/bin/R /opt/local/bin/R; do
  if hash $fl 2>/dev/null; then
    r_exist=1
    break
  fi
done
if [[ $r_exist -eq 0 ]]; then
  echo "Please, install R."
fi

# Install R packages
rpkgs=$(cat <<EOF
abind           # Combine multidimensional arrays into a single array
acepack         # ACE and AVAS methods for choosing regression
actuar          # Various actuarial science functionalities
ade4
adehabitatLT
adehabitatMA
akima           # Several cubic spline interpolation methods of H. Akima
animation       # Provides functions for animations in statistics
ape
apsrtable       # Formats latex tables from one or more model objects
argparse
arm
assertthat
automap         # This package performs an automatic interpolation by the variogram and then calling gstat
bdsmatrix
BH              # Boost provides free peer-reviewed portable C++ source
bibtex
bigmemory
bigmemory.sri
bit
bitops          # Functions for bitwise operations on integer vectors
brew            # brew implements a templating framework for mixing text
Cairo           # Cairo graphics device for high-quality vector and bitmap output
car
catdata
caTools         # Contains several basic utility functions
chemometrics
chron           # Chronological objects which can handle dates and times
CircStats
circular        # Circular Statistics
cluster
coda            # Provides functions for summarizing and plotting
colorRamps      # Builds gradient color maps
colorspace      # Carries out mapping between assorted color spaces
combinat        # routines for combinatorics
corpcor
crayon          # Colored terminal output on terminals that support 'ANSI'
cshapes
curl            # The curl() and curl_download() functions
cvTools
DAAG
data.table
DBI
deldir
DEoptimR        # An implementation of the jDE variant of the Differential Evolution
devtools        # Collection of package development tools
DiagrammeR
dichromat       # Collapse red-green or green-blue distinctions to simulate
digest          # Implementation of a function 'digest()' for the creation
diptest         # Compute Hartigan's dip test statistic
diveMove
doMC
doParallel      # Provides a parallel backend for the %dopar% function using
dplyr
e1071           # Functions for latent class analysis
ellipse
ergm            # An integrated set of tools to analyze networks based on exponential-family
evaluate        # Parsing and evaluation tools that make it easy to recreate the
evd
fastICA
fastmatch
ff
ffbase
fields          # For curve, surface and function
filehash
findpython
fit.models
fitdistrplus    # Parametric distribution to non-censored or censored data
flexmix         # FlexMix implements a general framework for finite
FNN             # Cover-tree and kd-tree fast k-nearest neighbor search algorithms and related applications
foreach         # Support for the foreach looping construct
foreign
formatR         # Provides a function tidy_source() to format R source code
Formula         # Infrastructure for extended formulas with multiple parts
fpc             # Various methods for clustering and cluster validation
fts
gamlss.dist     # The different distributions used for the response variables in GAMLSS
gclus
gdata           # Various R programming tools for data manipulation
gdtools
geometry        # Makes the qhull library
geosphere       # Spherical trigonometry for geographic applications
getopt
GGally          # GGally is designed to be a helper to ggplot2
ggmap           # A collection of functions to visualize spatial data
ggplot2         # An implementation of the grammar of graphics in R
ggplot2movies
git2r           # Interface to the 'libgit2' library
glmnet
goftest
googleVis
GPArotation
gpclib          # General polygon clipping routines for R
gplots          # Various R programming tools for plotting data
gridBase        # Integration of base and grid graphics
gridExtra       # Provides a number of user-level functions to work with "grid" graphics
gsl
gstat           # Variogram; kriging and plotting utility functions.
gtable          # Tools to make it easier to work with "tables" of 'grobs'
gtools          # Assist in developing, updating, and maintaining R and R packages
hexbin          # Binning and plotting functions for hexagonal bins
highlight
highr           # Provides syntax highlighting for R source code
Hmisc           # Contains many functions useful for data
htmltools
htmlwidgets
httpuv
httr            # Useful tools for working with HTTP organised by HTTP verbs
hwriter
hydroGOF        # S3 functions for application of hydrological models
hydroTSM        # Analysis, interpolation and plotting of time series used in hydrology
igraph          # Routines for simple graphs and network analysis
igraphdata
inline
intergraph
intervals       # Tools for working with and comparing sets of points and intervals
irlba           # PCA of large sparse or dense matrices
ISOcodes
iterators       # Support for iterators
itertools
its
JBTools         # Collection of several tools
jpeg            # Easy and simple way to read, write and display bitmap
jsonlite        # A fast JSON parser and generator optimized for statistical data
kernlab         # Kernel-based machine learning methods for classification
knitr           # Provides a general-purpose tool for dynamic report generation in R
labeling        # Provides a range of axis labeling algorithms
lars
latentnet
latticeExtra    # Extra graphical utilities based on lattice
lavaan
lazyeval        # A disciplined approach to non-standard evaluation
LearnBayes
lintr           # Checks adherence to a given style, syntax errors
lme4
lmtest
loa
logspline
lpSolve         # Solve linear, integer and mixed integer programs
lubridate       # Functions to work with date-times and timespans
magic           # a collection of efficient, vectorized algorithms
magrittr        # Provides a mechanism for chaining commands
mail
manipulate      # Interactive plotting functions for use within RStudio
mapdata
mapproj         # Converts latitude/longitude into projected coordinates
maps            # Display of maps
maptools        # Set of tools for manipulating and reading geographic data
markdown        # Provides R bindings to the 'Sundown' 'Markdown' rendering library
matrixcalc
MatrixModels
maxLik
MBESS           # Methods for behavioral, educational and social sciences
mc2d            # A complete framework to build and study Two-Dimensional Monte-Carlo simulations
mclust          # Model-Based Clustering, Classification, Density Estimation, Bayesian regularization
memoise         # Cache the results of a function so that when you call it
mi
mice
microbenchmark  # Provides infrastructure to accurately measure and compare
mime            # Guesses the MIME type from a filename extension using the data
minqa
misc3d          # A collection of miscellaneous 3d plots
miscTools
mix
mlbench
mlogit
mnormt          # Functions for the density and  distribution of multivariate normal and random variables
modeltools      # A collection of tools to deal with statistical models
mondate
Morpho
MPV
multcomp
munsell         # Provides easy access to the Munsell
mvoutlier       # Various methods for multivariate outlier detection
mvtnorm         # Computes multivariate normal and t probabilities
ncdf4           # Provides a high-level R interface to NetCDF
ncdf4.helpers   # Extra helper functions for ncdf4 package
network         # Tools to create and modify network objects
nlme
nloptr
NMF             # Provides a framework to perform Non-negative Matrix
numDeriv        # Numerical first and second order derivatives
OpenMx
openssl         # Bindings to OpenSSL libssl and libcrypto, plus custom SSH
outliers        # A collection of some tests
pbivnorm
pbkrtest
PBSmapping      # Two-dimensional plotting, find polygons and conversion lon-lat and UTM coordinates
pcaPP           # Robust PCA by Projection Pursuit
PCICt           # This package implements a work-alike to R's POSIXct class
permute         # A set of restricted permutation designs
pkgKitten
pkgmaker        # This package provides some low-level utilities to use for package
plot3D          # Functions for viewing 2-D and 3-D data
plotrix         # Lots of plots, various labeling, axis and color scaling functions
pls             # Multivariate regression methods
plyr            # A set of tools that solves a common set of problems
png             # Easy and simple way to read, write and display bitmap
polspline
polyclip
prabclus        # Distance-based parametric bootstrap tests for clustering
pracma          # numerical analysis, linear algebra, numerical optimization, differential equations
praise          # Build friendly R packages
proj4
proto           # An object oriented system using object-based
pryr
psych           # A toolbox for personality, psychometrics and experimental psychology
ptinpoly        # Function 'pip3d' tests whether a point in 3D space
quantreg
R.cache
R.matlab        # Methods readMat() and writeMat() for reading and writing MATLAB files
R.methodsS3     # Methods that simplify the setup of S3 generic functions and S3 methods
R.oo            # Methods and classes for object-oriented programming in R with or without references
R.rsp
R.utils         # Utility functions useful when programming and developing R packages
R6              # The R6 package allows the creation of classes with reference
randomForest
raster          # Reading, writing, manipulating, analyzing and modeling of gridded spatial data
rasterVis       # Methods for enhanced visualization and interaction with raster data
rbenchmark
RColorBrewer    # Provides color schemes for maps (and other graphics)
Rcpp            # The 'Rcpp' package provides R functions as well as C++ classes
RcppArmadillo
RcppEigen       # R and 'Eigen' integration using 'Rcpp'
Rcsdp
RCurl           # A wrapper for 'libcurl'
readr
regions         # Interface to Geometry Engine - Open Source (GEOS) using the C API for topology
registry        # Provides a generic infrastructure for creating and using registries
reporttools     # Helpful when writing reports of data analysis using Sweave
reshape         # Restructure and aggregate data using melt and cast
reshape2        # Restructure and aggregate data using melt and cast
rex             # A friendly interface for the construction of regular expressions
rgdal           # Provides bindings to Frank Warmerdam's GDAL
rgenoud         # A genetic algorithm plus derivative optimizer
rgeos
rgl             # Provides medium to high level functions for 3D interactive graphics
Rglpk           # R interface to the GNU Linear Programming Kit
rglwidget
RgoogleMaps     # Query the Google server for static maps
rjson           # Converts R object into JSON objects and vice-versa
RJSONIO         # Conversion to and from JSON format
rmarkdown
Rmisc           # The Rmisc library contains many functions useful for data analysis
rms
rngtools        # Random Number Generators
robCompositions # Methods for analysis of compositional data
robust
robustbase      # "Essential" Robust Statistics
roxygen2        # A 'Doxygen'-like in-source documentation system
rpf
rrcov           # Robust Location and Scatter Estimation
rstudio         # Interactive Plots for RStudio
rstudioapi      # Access the RStudio API (if available) and provide informative error
RUnit           # R functions implementing a standard Unit Testing
Rvcg            # Operations on triangular meshes based on 'VCGLIB'
rversions       # Query the main 'R' 'SVN' repository
sandwich
scales          # Graphical scales map data to aesthetics
scatterplot3d   # Plots a three dimensional (3D) point cloud
sem
semTools
sfsmisc
sgeostat        # An Object-oriented Framework for Geostatistical Modeling
shiny
slam            # Data structures and algorithms for sparse arrays and matrices
sna             # A range of tools for social network analysis, including node and graph-level indices
som
sp              # Classes and methods for spatial
spacetime       # Classes and methods for spatio-temporal data
spam            # Set of functions for sparse matrix algebra
SparseM
SpatioTemporal  # Utilities that estimate, predict and cross-validate the spatio-temporal model
spatstat
spdep
sphereplot      # Various functions for creating spherical coordinate system plots via extensions to rgl
sROC            # Estimation of receiver operating characteristic curves for continuous data
StanHeaders
statmod
statnet.common  # Non-statistical utilities used by the software developed by the Statnet Project
stringdist      # Implements an approximate string matching version of R's native
stringi         # Character string/text processing
stringr         # Extends 'stringi'
strucchange
svglite
synchronicity
tables
TeachingDemos   # This package is a set of demonstration functions
tensor
testit
testthat        # A unit testing system
TH.data
tikzDevice
timeDate
timeSeries
tis
tnet
trimcluster     # Trimmed k-means clustering
tripack
truncdist
trust           # local optimization using two derivatives and trust regions. Guaranteed to converge to local minimum of objective function
tseries
vcd
vegan
VIM
visNetwork
whisker         # logicless templating, reuse templates in many programming
withr
xml2            # Work with XML
xtable          # Coerce data to LaTeX and HTML tables
xts             # Extended Time Series
yaImpute
yaml            # This package implements the libyaml YAML 1.1 parser and emitter
zoo             # An S3 class with methods for totally ordered indexed
EOF
)

echo "* Installing R packages"
# remove comment lines
# shellcheck disable=SC2001
pkgs=$(echo "$rpkgs" | sed -e 's/#.*$//')
pkgs=$(echo "$pkgs" | uniq) # remove duplicate entries and sort
lnum=$(echo "$pkgs" | wc -l) # Number of lines
echo "* $lnum packages will be installed."
pkgs="$(echo "$pkgs"|
        sed -e '/^$/d'|
        sed 's/[ \t]*$//'|
        tr '\n' " "|
        sed "s/[^ ][^ ]*/\"&\",/g")"
pkgs="${pkgs%??}" # remove last two chars
echo "$fl"

$fl --slave -e "\
ip <- function(p){\
  np <- p[!(p %in% installed.packages()[, \"Package\"])];\
  print(np);\
  if (length(np)) install.packages(np, Ncpus=2,\
                                   dependencies = TRUE,\
                                   repos=\"https://cran.rstudio.com/\")}; \
test <- function(p){\
  x <- require(p);\
  detach(paste0(\"package:\",p, unload=TRUE));\
  invisible(x)};\
pkgs <- c($pkgs);\
ip(pkgs);\
sapply(pkgs, test, character.only = TRUE);"


