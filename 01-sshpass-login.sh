#!/bin/bash -e

ip=$1
username=$2
passwd=$3

OSDIST=$(lsb_release -i |awk -F: '{print tolower($2)}' | tr -d ' \t')
SSHPASS=sshpass

trap "printf \"\n%s\n\" exit ;exit" INT

if [[ $OSDIST == "centos" ]]; then
    if [[ ! -x "$(command -v $SSHPASS)" ]]; then
        sudo yum install $SSHPASS 
    fi
fi

if [[ $OSDIST == "ubuntu" ]]; then
    if [[ ! -x "$(command -v $SSHPASS)" ]]; then
        sudo apt install $SSHPASS 
    fi
fi

if [[ ! -x "$(command -v $SSHPASS)" ]]; then
    echo "$SSHPASS is not installed, please install it"
    exit 1
fi

checkUtils() {
    local -r msg="not found. Please make sure this is installed and in PATH."

    command -v awk >/dev/null 2>&1 || { echo >&2 "awk ${msg}"; exit 1; }
    command -v basename >/dev/null 2>&1 || { echo >&2 "basename ${msg}"; exit 1; }
    command -v cat >/dev/null 2>&1 || { echo >&2 "cat ${msg}"; exit 1; }
    command -v column >/dev/null 2>&1 || { echo >&2 "column ${msg}"; exit 1; }
    command -v echo >/dev/null 2>&1 || { echo >&2 "echo ${msg}"; exit 1; }
    command -v git >/dev/null 2>&1 || { echo >&2 "git ${msg}"; exit 1; }
    command -v grep >/dev/null 2>&1 || { echo >&2 "grep ${msg}"; exit 1; }
    command -v head >/dev/null 2>&1 || { echo >&2 "head ${msg}"; exit 1; }
    command -v seq >/dev/null 2>&1 || { echo >&2 "seq ${msg}"; exit 1; }
    command -v sort >/dev/null 2>&1 || { echo >&2 "sort ${msg}"; exit 1; }
    command -v tput >/dev/null 2>&1 || { echo >&2 "tput ${msg}"; exit 1; }
    command -v tr >/dev/null 2>&1 || { echo >&2 "tr ${msg}"; exit 1; }
    command -v uniq >/dev/null 2>&1 || { echo >&2 "uniq ${msg}"; exit 1; }
    command -v wc >/dev/null 2>&1 || { echo >&2 "wc ${msg}"; exit 1; }
}

if [ $# != 3 ]
then
    echo "Usage: $0 [ip] [username] [passwd]"
    if [ $# == 2 ]
    then
        passwd="$username"
        echo "Warning: using username as passwd"
    else
        exit 1
    fi
fi

counter()
{
count=0;
tput sc  #tput sc 存储光标位置
while :;
do
    if [ $count -lt 300 ];then
        if ! ping -c 1 -n -w 1 "$ip" &> /dev/null
        then
            tput rc # tput rc 恢复光标位置
            tput ed # tput ed 清除光标位置，到行尾的内容
        else
            break;
        fi
        printf "%s" $((++count))s;
    else
        echo -e "\ntried 300 times, ping failed, exit" 
        exit 0
    fi
done
}

checkUtils
printf "%s" "Waiting for $ip ... "
#while ! timeout 0.5 ping -c 1 -n "$1" &> /dev/null
counter
printf "\n%s\n" "$ip is online"

echo "do command \"$SSHPASS -p $passwd ssh $2@$ip\""
$SSHPASS -p "$passwd" ssh -X "$username"@"$ip" || exit
