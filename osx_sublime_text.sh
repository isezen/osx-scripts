#!/bin/bash
# sh -c "$(curl -sL https://git.io/v2pDA)"
#
_usage() {
  cat<<EOF
  Sublime Text OSX Installer Script v16.03.11
  Ismail SEZEN sezenismail@gmail.com 2016
  WARNING: ONLY FOR OSX
  USAGE:
    $ $0 -ih
  OR
    $ sh -c "\$(curl -sL https://git.io/v2pDA)"
  ARGUMENTS:
  -i  | --install : Install Sublime Text
  -y  | -- yes    : Do not promt, install everything.
  -h  | --help    : Shows this message.
  DESCRIPTION:
  This script will download and install latest
  Sublime Text and whole predefined plugins and settings.
EOF
}

INSTALL=0
ANSWER=0
if [[ ! "$BASH" =~ .*$0.* ]]; then
  while getopts "h?iy" opt; do
    case "$opt" in
      h|\?) INSTALL=0
      ;;
      i) INSTALL=1
      ;;
      y) ANSWER=1
      ;;
    esac
  done
  shift $((OPTIND-1))
else
  INSTALL=1
  ANSWER=1
fi

if [[ $INSTALL -eq 0 ]]; then
  _usage
  exit 0
fi

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is ONLY for MAC OSX."
  exit 0
fi

# Handle right user name
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER

# install sublime text
dir_app="/Applications/Sublime Text.app"
path_subl="$dir_app/Contents/SharedSupport/bin/subl"
if [ -d  "$dir_app" ]; then
  echo '- Sublime Text already exist.'
else
  # get latest Sublime text download url
  # shellcheck disable=SC1003
  url=$(grep -e 'dmg' <(curl -s "https://www.sublimetext.com/3")|
        sed 's/\"https/\'$'\n\"https/g' | sed 's/\"/\"\'$'\n/2'|grep 'https')
  url="${url//\"}" # remove " symbols, curl complains
  fname=${url##*/} # get filename
  url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
  if [ ! -f "$fname" ]; then # if dmg file does not exist
  	echo "* Downloading: $fname"
    curl -s -o "$fname" "$url"
  fi
  hdiutil attach "$fname" > /dev/null
  cp -r /Volumes/Sublime\ Text/Sublime\ Text.app /Applications/
  hdiutil detach /Volumes/Sublime\ Text/ > /dev/null
  echo "* Installed: Sublime Text"
fi

path_bin="/usr/local/bin"
fsubl="$path_bin/subl"
if [ ! -f "$fsubl" ]; then # Create a symlink for terminal
  if [[ $ANSWER -eq 0 ]]; then
    echo "Do you want to create a symlink for Sublime Text?"
    read -t 20 -n 1 -p "sudo password might be asked: (y/[n])? " answer
    [[ -z "$answer" ]] && answer="n"
    echo
  else
    answer="y"
  fi

  if [ "$answer" == "y" ]; then
    # echo "You need to enter sudo password to create symlink:"
    sudo mkdir -p "$path_bin"
    sudo ln -s "$path_subl" "$fsubl"
    echo "* Created Symlink [$fsubl]"
  fi
else
  echo "- [$fsubl] exist."
fi

# download and install Package Control Plugin
dir_setting="/Users/$USR/Library/Application Support/Sublime Text 3"
dir_inst_packages="$dir_setting/Installed Packages"
mkdir -p "$dir_inst_packages"

url="https://packagecontrol.io/Package Control.sublime-package"
fname=${url##*/} # get filename
url=$( printf "%s\n" "$url" | sed 's/ /%20/g') # replace space by %20
if [ ! -f "$dir_inst_packages/$fname" ];then
  curl -s -o "$fname" "$url"
  mv "$fname" "$dir_inst_packages/"
  echo "* Installed: Package Control Plugin"
else
  echo "- Package Control Plugin already exist."
fi

# Save predefined settings for SL and packages
if [[ $ANSWER -eq 0 ]]; then
  echo
  echo "Do you want to install predefined package settings?"
  echo "WARNING #1: This will override your current settings"
  echo "WARNING #2: You have to install linters seperately."
  read -t 20 -n 1 -p "in 20 sec, [n] will be selected: (y/[n])? " answer
  [[ -z "$answer" ]] && answer="n"
  echo
else
  answer="y"
fi

if [ "$answer" == "n" ]; then
  echo "* You can open ST. Enjoy! ^_^"
  exit 0
fi

# Set Skim.app for LaTeX Tools support
# this setting helps you use Skim.app for
# LaTeX writing/editing in Sublime Text.
if [ -d  /Applications/Skim.app ]; then
  defaults write -app Skim SKTeXEditorPreset -string ""
  defaults write -app Skim SKTeXEditorCommand -string "$path_subl"
  defaults write -app Skim SKTeXEditorArguments -string "\"%file\":%line"
fi

dir_user="$dir_setting/Packages/User"
mkdir -p "$dir_user"
echo "Target Dir: $dir_user"
fname="Preferences.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
  "auto_complete": false,
  "caret_style": "solid",
  "color_scheme": "Packages/Color Scheme - Default/Twilight.tmTheme",
  "draw_white_space": "all",
  "ensure_newline_at_eof_on_save": true,
  "file_exclude_patterns":
  [
    ".atomignore",
    ".gitignore",
    ".zedstate",
    "*.aux",
    "*.fls",
    "*.lof",
    "*.lot",
    "*.out",
    "*.toc",
    "*.blg",
    "*.bbl",
    "*.log",
    "*.bst",
    "*.cls",
    "*.fdb_latexmk",
    "*.synctex.gz",
    "*.synctex.gz(busy)",
    ".DS_Store"
  ],
  "find_selected_text": true,
  "fold_buttons": true,
  "folder_exclude_patterns":
  [
    ".git",
    "__pycache__",
    "env",
    "env3"
  ],
  "font_face": "Ubuntu Mono",
  "font_options":
  [
    "subpixel_antialias",
    "no_bold"
  ],
  "font_size": 18,
  "highlight_line": true,
  "highlight_modified_tabs": true,
  "ignored_packages":
  [
    "Vintage"
  ],
  "line_padding_bottom": 0,
  "line_padding_top": 0,
  "open_files_in_new_window": false,
  "rulers":
  [
    79,
    99
  ],
  "scroll_past_end": false,
  "show_full_path": true,
  "show_minimap": false,
  "tab_size": 4,
  "translate_tabs_to_spaces": false,
  "trim_trailing_white_space_on_save": true,
  "wide_caret": true,
  "word_wrap": true,
  "wrap_width": 160
}
EOF
echo "* Created $fname"

fname="Default (OSX).sublime-settings"
cat <<EOF > "$dir_user/$fname"
[
  {"keys": ["f5"], "command": "pydev"},
  // Remapping of *some* SublimeREPL shortcuts
  { "keys": ["ctrl+super+s"], "command": "repl_transfer_current", "args": {"scope": "selection"}},
  { "keys": ["ctrl+shift+,", "s"], "command": "repl_transfer_current", "args": {"scope": "selection", "action":"view_write"}},
  { "keys": ["ctrl+shift+super+f"], "command": "repl_transfer_current", "args": {"scope": "file"}},
  { "keys": ["shift+ctrl+,", "f"], "command": "repl_transfer_current", "args": {"scope": "file", "action":"view_write"}},
  { "keys": ["ctrl+super+l"], "command": "repl_transfer_current", "args": {"scope": "lines"}},
  { "keys": ["shift+ctrl+,", "l"], "command": "repl_transfer_current", "args": {"scope": "lines", "action":"view_write"}},
  { "keys": ["ctrl+super+b"], "command": "repl_transfer_current", "args": {"scope": "block"}},
  { "keys": ["shift+ctrl+,", "b"], "command": "repl_transfer_current", "args": {"scope": "block", "action":"view_write"}}
]
EOF
echo "* Created $fname"

fname="Package Control.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
  "bootstrapped": true,
  "in_process_packages":
  [
  ],
  "installed_packages":
  [
    "All Autocomplete",
    "Bash Build System",
    "BracketHighlighter",
    "GitGutter",
    "LaTeXTools",
    "Package Control",
    "PackageResourceViewer",
    "SendTextPlus",
    "SideBarEnhancements",
    "SublimeCodeIntel",
    "SublimeLinter",
    "SublimeLinter-annotations",
    "SublimeLinter-chktex",
    "SublimeLinter-contrib-lintr",
    "SublimeLinter-flake8",
    "SublimeLinter-pylint",
    "SublimeLinter-shellcheck",
    "SublimeREPL"
  ]
}
EOF
echo "* Created $fname"

fname="bh_core.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
  "high_visibility_enabled_by_default": true
}
EOF
echo "* Created $fname"

fname="SendText+.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
    "auto_advance" : true,
    "auto_advance_non_empty": false,
    "defaults" : [
        {
            "platform": "osx",
            "prog": "iTerm"
        },
        {
            "platform": "windows",
            "prog": "Cmder"
        },
        {
            "platform": "linux",
            "prog": "tmux"
        }
    ],
    "send_text_plus_keybinds": true
}
EOF
echo "* Created $fname"

fname="LaTeXTools.sublime-settings"
cat <<EOF > "$dir_user/$fname"
// LaTeXTools Preferences
{
  "cite_auto_trigger": true,
  "ref_auto_trigger": true,
  "keep_focus": true,
  "forward_sync": true,
  "osx":  {
    "texpath" : "$PATH:/usr/texbin:/usr/local/bin:/opt/local/bin"
  },
  "windows": {
    "texpath" : "",
    "distro" : "miktex"
  },
  "linux" : {
    "texpath" : "$PATH:/usr/texbin",
    "python2": "",
    "sublime": "sublime-text",
    "sync_wait": 1.5
  },
  "builder": "traditional",
  "builder_path": "",
  "builder_settings" : {
    "display_log" : false,
    "osx" : {
      // See README or third-party documentation
    },
    "windows" : {
      // See README or third-party documentation
    },
    "linux" : {
      // See README or third-party documentation
    }
  },
  "cite_panel_format": ["{author_short} {year} - {title_short} ({keyword})","{title}"],
  "cite_autocomplete_format": "{keyword}: {title}"
}
EOF
echo "* Created $fname"

fname="SublimeLinter.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
    "user": {
        "debug": false,
        "delay": 0.25,
        "error_color": "D02000",
        "gutter_theme": "Packages/SublimeLinter/gutter-themes/Default/Default.gutter-theme",
        "gutter_theme_excludes": [],
        "lint_mode": "background",
        "linters": {
            "annotations": {
                "@disable": false,
                "args": [],
                "errors": [
                    "FIXME"
                ],
                "excludes": [],
                "warnings": [
                    "NOTE",
                    "README",
                    "TODO",
                    "XXX",
                    "@todo"
                ]
            },
            "chktex": {
                "@disable": false,
                "args": [],
                "erroron": [
                    16
                ],
                "excludes": [],
                "inputfiles": [
                    0
                ],
                "nowarn": [
                    22,
                    30
                ]
            },
            "flake8": {
                "@disable": false,
                "args": [],
                "builtins": "",
                "excludes": [],
                "ignore": "",
                "jobs": "1",
                "max-complexity": -1,
                "max-line-length": null,
                "select": "",
                "show-code": false
            },
            "lintr": {
                "@disable": false,
                "args": [],
                "cache": "TRUE",
                "excludes": [],
                "linters": "default_linters"
            },
            "pylint": {
                "@disable": false,
                "args": [],
                "disable": "",
                "enable": "",
                "excludes": [],
                "paths": [],
                "rcfile": "",
                "show-codes": false
            },
            "shellcheck": {
                "@disable": false,
                "args": [],
                "exclude": "",
                "excludes": []
            }
        },
        "mark_style": "outline",
        "no_column_highlights_line": false,
        "passive_warnings": false,
        "paths": {
            "linux": [],
            "osx": [],
            "windows": []
        },
        "python_paths": {
            "linux": [],
            "osx": [],
            "windows": []
        },
        "rc_search_limit": 3,
        "shell_timeout": 10,
        "show_errors_on_save": false,
        "show_marks_in_minimap": true,
        "syntax_map": {
            "html (django)": "html",
            "html (rails)": "html",
            "html 5": "html",
            "javascript (babel)": "javascript",
            "magicpython": "python",
            "php": "html",
            "python django": "python",
            "pythonimproved": "python"
        },
        "warning_color": "DDB700",
        "wrap_find": true
    }
}
EOF
echo "* Created $fname"

fname="SublimeREPL.sublime-settings"
cat <<EOF > "$dir_user/$fname"
{
  "filter_ascii_color_codes": true,
  "default_extend_env": {"PS1": "$"},
  "show_transferred_text": false
}
EOF
echo "* Created $fname"

fname="pydev.py"
cat <<EOF > "$dir_user/$fname"
    def run(self):
        self.window.run_command('set_layout', {"cols":[0.0, 1.0], "rows":[0.0, 0.5, 1.0], "cells":[[0, 0, 1, 1], [0, 1, 1, 2]]})
        self.window.run_command('run_existing_window_command', {
                                "id": "repl_python_ipython",
                                "file": "config/Python/Main.sublime-menu",
                                "shell": true
                            })
        self.window.run_command('move_to_group', { "group": 1 })
# import sublime, sublime_plugin

# class PydevCommand(sublime_plugin.WindowCommand):
#     def run(self):
#         self.window.run_command('set_layout', {"cols":[0.0, 1.0], "rows":[0.0, 0.5, 1.0], "cells":[[0, 0, 1, 1], [0, 1, 1, 2]]})
#         self.window.run_command('repl_open',{"type": "subprocess",
#                                              "encoding": "utf8",
#                                              "cmd": ["python2.7", "-i", "-u", "\$file"],
#                                              "cwd": "\$file_path",
#                                              "syntax": "Packages/Python/Python.tmLanguage",
#                                              "external_id": "python2.7",
#                                              "extend_env": {"PYTHONIOENCODING": "utf-8"}
#                                              })
#         self.window.run_command('move_to_group', { "group": 1 })
EOF
echo "* Created $fname"

echo "* Open ST, when prompted, RESTART, Enjoy! ^_^"
