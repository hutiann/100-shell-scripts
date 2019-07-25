#!/bin/bash

SECONDS=0
job=5

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
    WAIT=$((RANDOM*3/10000))
    echo  "[$(date +%T)] progress $i is sleeping for $WAIT seconds zzz…"
    sleep $WAIT &
done
wait
echo -e "time-consuming: $SECONDS seconds"
echo ""

Nproc=5 #最大并发进程数
function PushQue {      #将PID值追加到队列中
    Que="$Que $1"
    Nrun=$((Nrun+1))
}

function GenQue {       #更新队列信息，先清空队列信息，然后检索生成新的队列信息
    OldQue=$Que
    Que=""; Nrun=0
    for PID in $OldQue; do
        if [[ -d /proc/$PID ]]; then
            PushQue $PID
        fi
    done
}

function ChkQue {       #检查队列信息，如果有已经结束了的进程的PID，那么更新队列信息
    OldQue=$Que
    for PID in $OldQue; do
        if [[ ! -d /proc/$PID ]];   then
            GenQue; break
        fi
    done
}

for ((i=1; i<=$Njob; i++)); do
           echo "progress $i is sleeping for 3 seconds zzz…"
           sleep 3 &
           PID=$!
           PushQue $PID
           while [[ $Nrun -ge $Nproc ]]; do          # 如果Nrun大于Nproc，就一直ChkQue
                 ChkQue
                 sleep 0.1
           done
done
wait

echo -e "time-consuming: $SECONDS   seconds"    #显示脚本执行耗时#!/bin/bash
