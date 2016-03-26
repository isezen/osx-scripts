#!/bin/bash
# 2016-03-27
# sezenismail@gmail.com
# Shiny bash promt supoort and
# dircolors supoort
#


# USER PROMT SETTINGS
# Date: \D{%y-%m-%d}
# Time: \t
# User: \u
# Host: \h
# Path: \${NEW_PWD}
# PS1="[\D{%y-%m-%d} \t]\n\u@\h \${NEW_PWD} \\$ "
PS1="\h\xE2\x98\x98 \${NEW_PWD} [\$] "
export CLICOLOR=1

bash_prompt_command() {
  local pwdmaxlen=25
  local trunc_symbol=".."
  local dir=${PWD##*/}
  pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
  NEW_PWD=${PWD/#$HOME/\~}
  local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
  if [ ${pwdoffset} -gt "0" ];then
    NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
    NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
  fi
}

bash_prompt() {
  if test -t 1; then
    ncolors=$(tput colors)
    if test -n "$ncolors" && test "$ncolors" -ge 8; then
      local D="\\\[\\\033[0m\\\]"
      local dt="\\\D{%y-%m-%d}"
      local tm="\\\t"
      PS1=$(echo -e "$PS1" |
            sed "s/${dt}/\\\[\\\033[0;36m\\\]${dt}${D}/g"|
            sed "s/${tm}/\\\[\\\033[0;32m\\\]${tm}${D}/g"|
            sed -r "s/\\\u/\\\[\\\033[1;39m\\\]\\\u${D}/g"|
            sed -r "s/@/\\\[\\\033[1;33m\\\]@${D}/g"|
            sed -r "s/\\\h/\\\[\\\033[1;36m\\\]\\\h${D}/g"|
            sed -r "s/\\\$\{NEW_PWD\}/\\\[\\\033[1;32m\\\]\$\{NEW_PWD\}${D}/g"|
            sed -r "s/\[\\\$\]/\\\[\\\033[0;31m\\\]\\\\\$${D}/g")
    fi
  fi
}

PROMPT_COMMAND=bash_prompt_command
bash_prompt
unset bash_prompt

gnuls="$(ls --version 2>/dev/null)"
if [ -n "$gnuls" ];then
  # Set dircolors
  if [ ! -f ~/.dircolors ]; then
    curl -sLo ~/.dircolors https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS
  else
    eval "$(dircolors -b ~/.dircolors)"
  fi
fi

unset gnuls


