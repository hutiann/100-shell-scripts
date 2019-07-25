#!/bin/bash

SECONDS=0
job=9
Nproc=3

for ((i=0; i<job; i++)); do
{
   WAIT=$((RANDOM/10000))
   echo  "[$(date +%T)] progress $i is sleeping for $WAIT seconds zzz…"
   sleep $WAIT
}
done
echo -e "time-consuming: $SECONDS seconds"
echo ""


echo "wait命令以循环中最慢的进程结束为结束（水桶效应）"
SECONDS=0
for ((i=0; i<job; i++)); do
   WAIT=$((RANDOM/10000))
   echo  "[$(date +%T)] progress $i is sleeping for $WAIT seconds zzz…"
   sleep $WAIT &
done
wait
echo -e "time-consuming: $SECONDS seconds"
echo ""

echo "用数组控制并发数目"
SECONDS=0
pid=()
function ChkArray {
    index=0
    for PID in ${pid[*]}; do
        if [[ ! -d /proc/$PID ]]; then
            pid=(${pid[@]:0:$index} ${pid[@]:$index+1})
            break
        fi
        ((index++))
    done
}

for ((i=1; i<=job; i++)); do
    echo "progress $i is sleeping for 3 seconds zzz…"
    sleep 3 &
    pid+=("$!")
    while [[ ${#pid[*]} -ge $Nproc ]]; do
          ChkArray
          sleep 0.1
    done
done
wait
echo -e "time-consuming: $SECONDS   seconds"
echo ""
