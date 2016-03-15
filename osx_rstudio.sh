#!/bin/bash
# sh -c "$(curl -sL https://git.io/vaTdJ)"
#
[[ -z "$SUDO_USER" ]] && USR=$USER || USR=$SUDO_USER
APPNAME="RStudio"
DIR_APP="/Applications/$APPNAME.app"
ONLYMAC="This script is ONLY for MAC OSX."
URL="https://www.rstudio.com/products/rstudio/download/"
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
   $ sh -c "\$(curl -sL https://git.io/vacoq)"
  ARGUMENTS:
  -i | --install : Install $APPNAME
  -f | --force   : Force to reinstall
  -h | --help    : Shows this message
  DESCRIPTION:
  This script will download and install/update
  latest $APPNAME.

EOF
}

# My RStudio Settings
function _predefined_settings() {
  dir_setting="/Users/$USR"
  dir_user="$dir_setting/.rstudio-desktop/monitored/user-settings"
  fname="user-settings"
  cat <<EOF > "$dir_user/$fname"
  alwaysSaveHistory="1"
  cleanTexi2DviOutput="1"
  cleanupAfterRCmdCheck="1"
  contextIdentifier="429479EE"
  cranMirrorCountry="us"
  cranMirrorHost="RStudio"
  cranMirrorName="Global (CDN)"
  cranMirrorUrl="https://cran.rstudio.com/"
  enableLaTeXShellEscape="1"
  errorHandlerType="0"
  hideObjectFiles="1"
  initialWorkingDirectory="~"
  lineEndingConversion="2"
  loadRData="1"
  newlineInMakefiles="1"
  removeHistoryDuplicates="1"
  restoreLastProject="1"
  reuseSessionsForProjectLinks="1"
  rprofileOnResume="0"
  saveAction="-1"
  securePackageDownload="1"
  showLastDotValue="0"
  showUserHomePage="sessions"
  uiPrefs="{\n    \"always_complete_characters\" : 3,\n    \"always_complete_console\" : true,\n    \"always_complete_delay\" : 250,\n    \"always_enable_concordance\" : true,\n    \"auto_append_newline\" : true,\n    \"auto_expand_error_tracebacks\" : false,\n    \"background_diagnostics_delay_ms\" : 2000,\n    \"blinking_cursor\" : true,\n    \"check_arguments_to_r_function_calls\" : true,\n    \"check_for_updates\" : true,\n    \"clear_hidden\" : true,\n    \"code_complete\" : \"always\",\n    \"code_complete_other\" : \"always\",\n    \"continue_comments_on_newline\" : false,\n    \"default_encoding\" : \"UTF-8\",\n    \"default_latex_program\" : \"pdfLaTeX\",\n    \"default_project_location\" : \"~/project\",\n    \"default_sweave_engine\" : \"Sweave\",\n    \"diagnostics_in_function_calls\" : true,\n    \"diagnostics_on_save\" : true,\n    \"enable_background_diagnostics\" : true,\n    \"enable_emacs_keybindings\" : false,\n    \"enable_rstudio_connect\" : false,\n    \"enable_snippets\" : true,\n    \"enable_style_diagnostics\" : true,\n    \"export_plot_options\" : {\n        \"copyAsMetafile\" : false,\n        \"format\" : \"png\",\n        \"height\" : 476,\n        \"keepRatio\" : false,\n        \"viewAfterSave\" : true,\n        \"width\" : 570\n    },\n    \"focus_console_after_exec\" : false,\n    \"font_size_points\" : 10,\n    \"handle_errors_in_user_code_only\" : true,\n    \"highlight_r_function_calls\" : true,\n    \"highlight_selected_line\" : true,\n    \"highlight_selected_word\" : true,\n    \"ignore_uppercase_words\" : true,\n    \"ignore_words_with_numbers\" : true,\n    \"insert_matching\" : true,\n    \"insert_numbered_latex_sections\" : false,\n    \"insert_parens_after_function_completion\" : true,\n    \"insert_spaces_around_equals\" : true,\n    \"navigate_to_build_error\" : true,\n    \"new_proj_git_init\" : false,\n    \"num_spaces_for_tab\" : 2,\n    \"packages_pane_enabled\" : true,\n    \"pane_config\" : {\n        \"panes\" : [\n            \"Source\",\n            \"Console\",\n            \"TabSet1\",\n            \"TabSet2\"\n        ],\n        \"tabSet1\" : [\n            \"Environment\",\n            \"History\",\n            \"Build\",\n            \"VCS\",\n            \"Presentation\"\n        ],\n        \"tabSet2\" : [\n            \"Files\",\n            \"Plots\",\n            \"Packages\",\n            \"Help\",\n            \"Viewer\"\n        ]\n    },\n    \"pdf_previewer\" : \"rstudio\",\n    \"preferred_document_outline_width\" : 110,\n    \"print_margin_column\" : 80,\n    \"reindent_on_paste\" : true,\n    \"restore_source_documents\" : true,\n    \"rmd_preferred_template_path\" : \"\",\n    \"rmd_viewer_type\" : 0,\n    \"root_document\" : \"\",\n    \"save_before_sourcing\" : true,\n    \"save_files_before_build\" : false,\n    \"save_plot_as_pdf_options\" : {\n        \"cairo_pdf\" : true,\n        \"height\" : 5.740000000000000,\n        \"portrait\" : true,\n        \"viewAfterSave\" : true,\n        \"width\" : 5.177083333333333\n    },\n    \"show_diagnostics_cpp\" : true,\n    \"show_diagnostics_other\" : true,\n    \"show_diagnostics_r\" : true,\n    \"show_doc_outline_rmd\" : true,\n    \"show_indent_guides\" : true,\n    \"show_inline_toolbar_for_r_code_chunks\" : true,\n    \"show_invisibles\" : false,\n    \"show_line_numbers\" : true,\n    \"show_margin\" : true,\n    \"show_publish_ui\" : true,\n    \"show_signature_tooltips\" : true,\n    \"show_unnamed_chunks_in_document_outline\" : true,\n    \"soft_wrap_r_files\" : false,\n    \"source_with_echo\" : false,\n    \"spelling_dictionary_language\" : \"en_US\",\n    \"strip_trailing_whitespace\" : true,\n    \"surround_selection\" : \"quotes_and_brackets\",\n    \"syntax_color_console\" : true,\n    \"tab_multiline_completion\" : false,\n    \"theme\" : \"Twilight\",\n    \"toolbar_visible\" : true,\n    \"use_rcpp_template\" : true,\n    \"use_roxygen\" : false,\n    \"use_spaces_for_tab\" : true,\n    \"use_vim_mode\" : false,\n    \"valign_argument_indent\" : true,\n    \"warn_if_no_such_variable_in_scope\" : true,\n    \"warn_if_variable_defined_but_not_used\" : true\n}"
  useDevtools="1"
  useInternet2="1"
  vcsEnabled="1"
  vcsGitExePath=""
  vcsSvnExePath=""
  vcsTerminalPath=""
  vcsUseGitBash="1"
  viewDirAfterRCmdCheck="0"
EOF
  echo "* Created $dir_user/$fname"
}

function _get_FURL() {
  if [ -z "${FURL+x}" ]; then
    FURL="$(curl -s "$URL"|
            grep -oP 'https\S*RStudio-[0-9]\.[0-9][0-9]\.[0-9][0-9][0-9]\S*dmg')"
  fi
}

function _get_VER() {
  if [ -z "${VER+x}" ]; then
    _get_FURL
    VER=$(echo "$FURL"|
          grep -oP '[0-9]\.[0-9][0-9]\.[0-9][0-9][0-9]')
  fi
}

function _ver_check() {
  _get_VER
  if [ -d "$DIR_APP" ]; then
    read_str="$DIR_APP/Contents/Info.plist CFBundleShortVersionString"
    # shellcheck disable=SC2086
    cur_ver=$(defaults read $read_str)
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
  fname=${url##*/} # get filename
  _setup "$fname_tmp" "/${fname%.dmg}/RStudio.app"
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
fi

if [[ $INSTALL -eq 0 ]]; then _usage;exit; fi
if [[ "$OSTYPE" != "darwin"* ]]; then echo "$ONLYMAC";exit; fi
if ! hash R 2>/dev/null; then echo '* Install R'; exit 0; fi

if [[ $FORCE -eq 0 ]]; then _ver_check; fi
if [[ $INSTALL -ne 0 ]]; then _install; fi
echo "$MSG"

# for LC_CTYPE failed error
defaults write org.R-project.R force.LANG en_US.UTF-8

_predefined_settings

