#!/usr/bin/env bash

# Runtime Environment
set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Formatting stuff
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_ORANGE=$(tput setaf 3)
readonly C_BLUE='\033[1;34m'
readonly NC='\033[0m' # No Color

# Number of xargs processes to run in parallel
declare xargs_processes=0
declare concatenation_list=$(mktemp)
declare -a xargs_arguments=()

# Check on Requirements
function require  {
	command -v "${1}" >/dev/null 2>&1 || e_error "$(printf "Program '%s' required, but it's not installed" "${1}")"
}

require mktemp
require xargs
require git

# Error message and error exit, redirecting stdout to stderr
function e_error {
    echo -e >&2 "${C_RED}✘ Error:${NC} ${*-}";
    exit 1;
}

function e_info {
    echo -e "${C_BLUE}❱ Info:${NC} ${*-}"
}

function e_warning {
    echo -e "${C_ORANGE}❱ Warning:${NC} ${*-}"
}

function e_success () {
    echo -e "${C_GREEN}✔ Success:${NC} ${*-}"
}

if [ "$#" -gt 1 ]; then
	echo;
	echo "Usage: "
	echo "$0 <repos> "
	echo;
	echo "Parameters:"
	echo "<repos> File with repos"
    e_error "Parameters no more than 1"
elif [ "$#" -eq 0 ]; then
    e_warning "Defautl repo ${remote_files_array[@]} would be used"
fi

xargs_arguments+=( -I{} )
xargs_arguments+=( -P ${xargs_processes} )
xargs_arguments+=( git clone --depth 1 )
xargs_arguments+=( {} )

remote_files_array=(\
    git://github.com/yangye8/100-shell-scripts.git \
)

if [ "$#" == 1 ];then
    e_info "xargs "${xargs_arguments[@]}" < $1"
    xargs "${xargs_arguments[@]}" < $1
else
    for base_url in "${remote_files_array[@]}"; do
    	echo "${base_url}" >> $concatenation_list
    done
    e_info "xargs "${xargs_arguments[@]}" < $concatenation_list"
    xargs "${xargs_arguments[@]}" < $concatenation_list
fi

echo;
e_success "Finished.";
echo;
