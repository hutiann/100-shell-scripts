#!/bin/bash -e

ip=$1
username=$2
passwd=$3
loop=0

OSDIST=$(lsb_release -i |awk -F: '{print tolower($2)}' | tr -d ' \t')
SSHPASS=sshpass

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

trap "printf \"\n%s\n\" exit ;exit" INT
printf "%s" "Waiting for $ip ... "
#while ! timeout 0.5 ping -c 1 -n "$1" &> /dev/null
while ! ping -c 1 -n -w 1 "$ip" &> /dev/null
do
    printf "%d%c" $((++loop)) "."
    [ $loop == 300 ] && echo -e "\ntried 300 times, ping failed, exit" && exit
done
printf "\n%s\n" "$ip is online"

echo "do command \"$SSHPASS -p $passwd ssh $2@$ip\""
$SSHPASS -p "$passwd" ssh "$username"@"$ip" || exit
