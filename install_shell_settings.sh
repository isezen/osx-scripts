#!/bin/bash
# 2016-03-27
# sezenismail@gmail.com
# sh -c "$(curl -sL https://git.io/vVfT7)"
# Install my shell settings and aliases.
#

function die() {
  echo "${1}"
  exit 1
}

function save() {
  local fnamebase="$1"
  local fname="${HOME}/.$fnamebase.${SHELL}"
  local relfname="${HOME_PREFIX}/.$fnamebase.${SHELL}"
  local url="$2"
  echo "Downloading script from ${url} and saving it to ${fname}..."
  curl -sL "${url}" > "${fname}" || die "Couldn't download script from ${url}"
  chmod +x "${fname}"
  echo "Checking if ${SCRIPT} contains aliases..."
  grep "$fnamebase" "${SCRIPT}" > /dev/null 2>&1 || (echo "Appending source command to ${SCRIPT}..."; echo "" >> "${SCRIPT}"; echo "test -e ${QUOTE}${relfname}${QUOTE} ${SHELL_AND} source ${QUOTE}${relfname}${QUOTE}" >> "${SCRIPT}")
  echo "Done."
}

SHELL=$(echo "${SHELL}" | tr / "\n" | tail -1)
URL=""
HOME_PREFIX='${HOME}'
SHELL_AND='&&'
QUOTE=''
if [ "${SHELL}" == bash ]
then
  URL1="https://raw.githubusercontent.com/isezen/osx-scripts/master/alias.sh"
  URL2="https://raw.githubusercontent.com/isezen/osx-scripts/master/bash.sh"
  test -f "${HOME}/.bash_profile" && SCRIPT="${HOME}/.bash_profile" || SCRIPT="${HOME}/.profile"
  QUOTE='"'
else
  die "Your shell, ${SHELL}, is not supported yet. Only tcsh, zsh, bash, and fish are supported. Sorry!"
  exit 1
fi

save myaliases "$URL1"
save mybash "$URL2"

echo ""
echo "The next time you log in, shell settings will be enabled."
