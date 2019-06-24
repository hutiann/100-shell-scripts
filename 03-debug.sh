#!/bin/bash

debug_mode='0'

DEBUG()
{
[ "$_DEBUG" == "on"  ] && $@ || :
}

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

exists() {
[[ -x $(type -P "$1" 2>/dev/null) ]];
[[ -x $(command -v "$1" 2>/dev/null) ]];
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

warn() {
    echo "$1" >&2

}

die() {
    warn "$1"
    exit 1
}

repeat()
{
while :;
do
    "$@" && return
    sleep 1
done
}
#repeat() { while :; do $@ && return; sleep 10;one }

for i in {1..10}
do
    DEBUG echo $i
done

exists sl || echo "Please install sl." <&2
