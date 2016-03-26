#!/bin/bash
# 2016-03-27
# sezenismail@gmail.com
# Contains shell aliases and functions
#

# Show free memory amount
mem () {
  FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
  INACTIVE_BLOCKS=$(vm_stat | grep inactive | awk '{ print $3 }' | sed 's/\.//')
  SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')
  TOTALRAM=$(system_profiler SPHardwareDataType | grep Memory | awk '{ print $2 $3}')

  FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS)*4096/(1024*1024)))
  INACTIVE=$(($INACTIVE_BLOCKS*4096/(1024*1024)))
  TOTAL=$((($FREE+$INACTIVE)))
  TOTAL=$(echo "scale=2; $TOTAL/1024" | bc)
  echo "Free Memory: $TOTAL""GB of $TOTALRAM"
}

cd_aliases () {
  # More easy directory changing
  alias cdh="cd ~/" # Go to Home

  # Expamples:
  # ".." or ".1" -> Up 1 level
  # "..." or ".2" -> Up 2 levels
  # "...." or ".3" -> Up 3 levels
  local dotSlash=""
  local dot=".."
  for i in 1 2 3 4 5; do
    local dotSlash=${dotSlash}'../'
    local baseName=".${i}"
    # shellcheck disable=SC2139
    alias "$baseName=cd ${dotSlash}"
    # shellcheck disable=SC2139
    alias "$dot=cd $dotSlash"
    dot=${dot}'.'
  done
}

ls_aliases () {
  local gnu_ls_suffix="--color --group-directories-first"

  # Listing aliases
  local _ls="ls"
  local _ll="$_ls -l"
  if hash ls 2>/dev/null;then
    local gnuls="$(ls --version 2>/dev/null)"
    if [ -n gnuls ];then
      _ls="$_ls $gnu_ls_suffix"
      _ll='ls -lhF --color'
    fi
  fi

  alias dir="$_ls -C -b"
  if hash dir 2>/dev/null;then
    if [ -n "$(dir --version 2>/dev/null)" ];then
      alias dir="dir $gnu_ls_suffix"
    fi
  fi

  alias vdir="$_ls -l -b"
  if hash vdir 2>/dev/null;then
    if [ -n "$(vdir --version 2>/dev/null)" ];then
      alias vdir="vdir $gnu_ls_suffix"
    fi
  fi

  if hash ll 2>/dev/null; then
    _ll='ll -hGg --group-directories-first'
    alias vdir="$_ll"
  fi

  # -C=list entries by columns
  alias l="$_ls -CF"
  alias ls="$_ls"
  # Typo correction
  alias sl="ls"
  # List regular + hidden
  alias la="$_ls -AF"
  # list Hidden items
  alias lh="$_ls -dF .[^.]*"
  # list regular directories
  alias ld="$_ls -d -- */"
  # list hidden directories
  alias lhd="$_ls -d .[^.]*/"

  # # List Files
  # Find Files in current directory
  local _fnd="find . -maxdepth 1 -type"
  local _freg="$_fnd f -a ! -iname \".*\" -print0 | sed -e \"s:./::g\" "
  local _fall="$_fnd f -print0 | sed -e \"s:./::g\""
  local _fhid="$_fnd f -a -iname \".*\" -print0 | sed -e \"s:./::g\""
  local _fadir="$_fnd d \( -not -iname \".\" \) -print0 | sed -e \"s:./::g\""
  local _suf="| xargs -0r $_ls"
  alias lf="$_freg $_suf"  # list regular
  alias laf="$_fall $_suf" # list regular+hidden
  alias lhf="$_fhid $_suf" # list hidden
  # list all directories (regular + hidden)
  alias lad="$_fadir | xargs -0r $_ls -dF"

  alias ll="$_ll"
  alias llad="$_fadir | xargs -0r $_ll -d" # All
  alias llf="$_freg | xargs -0r $_ll -d"    # List regular files
  alias llaf="$_fall | xargs -0r $_ll -d"      # List all files + hidden
  alias llhf="$_fhid | xargs -0r $_ll -d"    # Only hidden files
  alias lla="$_ll -A" # All
  alias llh="$_ll -d .[^.]*" # Hidden

  alias lld="$_ll -dhGg */" # regular directories
  alias llhd="$_ll -dhGg .[^.]*/" # Hidden directories

}

# mkdir a directory and move into that directory
mcd () { mkdir -p "$1";cd "$1"; }

FindFiles () {
  local _searchfile='$1'
  local _search_command='find . -type f \( -name "*'$_searchfile'*" \)'
  eval "$_search_command"
}

dushf () {
  echo "Calculating disk usage of all hidden files in $PWD"
  local _filelist=$(find . -type f -a -iname "*.pdf" -print0 | xargs -r0 \du -ach | sort -h);
  echo "Number of files:"$(expr $(echo "$_filelist"| wc -l) - 1);
  tail -n 1 <<< "$_filelist"
}

dufiles () {
  local file="$1"
  local _search_command='find . -type f \( -name "*.'$1'" \) -print0 | xargs -r0 \du -ch | sort -h'
  local _filelist=$(eval $_search_command)
  echo "$_filelist"
  echo "Number of $1 files:"$(expr $(echo "$_filelist"| wc -l) - 1);
  tail -n 1 <<< "$_filelist"
}

# Only Directories
dusd () {
  let x=-1
  _filelist=$(eval $_findAllDirectories' | xargs -r0 \du -hcd 0 | sed -r "s:./::" | sort -h');
  print_files "$_filelist"
  echo "Number of Dirs:"$(expr $(echo "$_filelist"| wc -l) - 1);
}

print_files () {
  while IFS=$'\t' read -r size line;
    do printf "%s\t%s" $size "$line"
    [[ -d $line ]] && printf "/"
    echo
    x=$(( $x + 1 ))
  done <<< "$1"
}

# ---------------------
ls_aliases; unset ls_aliases
cd_aliases; unset cd_aliases

alias c="clear" # clear terminal
alias sourceme='source ~/.profile'
# Permanently delete command
alias 'rm!=/bin/rm -Rf'
# Find in current directory
alias fhere="find . -name "

alias topme='top -U $USER' # Valid for both linux and darwin
# Use htop instead of top if exist
if hash htop 2>/dev/null; then
  alias top='htop -s PERCENT_CPU'
  alias topme='top -u $USER'
fi

# Searchable Process Table
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Parent Directory + Verbose output
alias mkdir="mkdir -pv"

# Continue to download in case of interruption
alias wget="wget -c"

alias h='history'
# Statistics of history
alias stath="history|
  awk '{CMD[\$2]++;count++;}END { for (a in CMD)print CMD[a] \" \" CMD[a]/count*100 \"% \" a;}'|
  grep -v \"./\"|
  column -c3 -s \" \" -t|
  sort -nr | nl |  head -n10"
# Search history
alias hg="history | grep"
# Clear history
alias clhist='cat /dev/null > ~/.bash_history && history -c && exit'

alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%Y-%m-%d"'

# alias du='du -ach --max-depth=1 2> >(grep -v "^du: cannot \(access\|read\)" >&2)'
alias du="du -ahd 1"
alias du.='\du -ahd 0 2> >(grep -v "^du: cannot \(access\|read\)" >&2)'
# Interactive disk usage
if hash ncdu 2>/dev/null; then alias du2='ncdu'; fi

# Show my ip
alias myip="curl http://ipecho.net/plain; echo"

# resize images for web if mogrify exist
# This will resize all of the PNG images in the current directory, only if they are wider than 690px
if hash mogrify 2>/dev/null; then alias webify='mogrify -resize 690\> *.png'; fi

# Colorize grep and friends
if hash grep 2>/dev/null; then alias grep='grep --color=auto --exclude-dir=\.svn';fi
if hash fgrep 2>/dev/null; then alias fgrep='fgrep --color=auto';fi
if hash egrep 2>/dev/null; then alias egrep='egrep --color=auto';fi
if hash dfc 2>/dev/null; then alias df='dfc'; fi

if hash port 2>/dev/null; then
  alias updateme="sudo port selfupdate && sudo port upgrade outdated"
fi

if hash free 2>/dev/null; then
  alias free="free -mt"
else
  alias free="vm_stat | perl -ne '/page size of (\d+)/ and \$size=\$1; \
   /Pages\s+([^:]+)[^\d]+(\d+)/ and printf(\"%-16s % 16.2f Mb\n\", \"\$1:\", \
    \$2 * \$size / 1048576);'"
fi

# Stop after sending count ECHO_REQUEST packets #
if hash grc 2>/dev/null; then
  alias ping='grc ping -c 10'
  alias ps='grc ps aux'
else
  alias ping='ping -c 10'
  alias ps='ps aux'
fi

alias ports='netstat -tulanp'
