#!/bin/bash
#并行计算 $! 保存着最近一个后台进程的PID

REPO_LIST=(\
    git://github.com/yangye8/100-shell-scripts.git \
    git://github.com/Rolinh/dfc.git \
    git://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git \
    git://github.com/pengutronix/memtool.git \
    git://github.com/vamanea/mtd-utils.git \
    git://github.com/apenwarr/netselect.git \
    git://github.com/openssh/openssh-portable
    git://github.com/ridernator/stopwatch.git \
    git://github.com/gregkh/usbutils.git \
    git://github.com/Xilinx/XRT.git \
)

parallar()
{
PIDARRAY=()
for repo in "${REPO_LIST[@]}"
do
    git clone "$repo" &
    PIDARRAY+=("$!")
done
wait "${PIDARRAY[@]}"
}
parallar
