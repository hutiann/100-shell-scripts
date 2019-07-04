#!/bin/bash

debug_mode='0'
ret=1

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

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

exists() {
[[ -x $(type -P "$1" 2>/dev/null) ]];
[[ -x $(command -v "$1" 2>/dev/null) ]];
}

timer()
{
tput sc
count=0;
while :;
do
    sleep 1
    tput rc
    tput ed
    echo -n "Time Elapsed : $((count++))"s;
done
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

bashdb () {

    #bash --debugger xx.sh
    #bashdb xx.sh

    # n 执行下一条语句，遇到函数，不进入函数里面执行，将函数当作黑盒
    # s n 单步执行n次，遇到函数进入函数里面
    # b 行号n 在行号n处设置断点
    # d 行号n 撤销行号n处的断点
    # c 行号n 一直执行到行号n处
    # R 重新启动
    # Finish 执行到程序最后
    # cond n expr 条件断点

    if ! program_exists bashdb; then
        wget https://netix.dl.sourceforge.net/project/bashdb/bashdb/4.4-0.94/bashdb-4.4-0.94.tar.gz
        tar -xvf bashdb-*.tar.gz
        cd bashdb-* || exit
        ./configure
        make
        sudo make install
    fi

    ret=0
    success "bashdb installed"
}

main () {
for i in {1..10}
do
    DEBUG echo $i
done

bashdb
}

main "$@"
