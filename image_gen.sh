#!/bin/bash
# Create a SD card image to be used for flashing board
set -e

############################  SETUP PARAMETERS
app_name='image_gen'
debug_mode='0'

IMG="$(date +%F).img"
FAT="${BOARD}"
ROOTFS="rootfs"
BOOT_DIM=400
FREELO="$( losetup -f)"

############################  BASIC SETUP TOOLS
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

file_exists() {
    local ret='0'
    [ -e $1 ] || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

file_must_exists() {
    file_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' file to continue."
    fi
}

############################ SETUP FUNCTIONS

lodetach () {
    DEVICE="${1}"
    ATTEMPT="${2:-1}"

    if [ "${ATTEMPT}" -gt 3 ]
    then
        echo "Failed to detach loop device '${DEVICE}'."
        exit 1
    fi

    # Changes to block devices result in uevents which trigger rules which in
    # turn access the loop device (ex. udisks-part-id, blkid) which can cause
    # a race condition. We call 'udevadm settle' to help avoid this.
    if [ -x "$(which udevadm 2>/dev/null)" ]
    then
        udevadm settle
    fi

    # Loop back devices aren't the most reliable when it comes to writes.
    # We sleep and sync for good measure - better than build failure.
    sync
    sleep 1

     losetup -d "${DEVICE}" || lodetach "${DEVICE}" "$(expr ${ATTEMPT} + 1)"
}

calc_space () {
    local tar_file="$1"

    [ -e ${ROOTFS} ] && rm -fr ${ROOTFS}
    mkdir ${ROOTFS} && tar -zxf "$tar_file" -C ${ROOTFS}

    DU_DIM="$( du -ms ${ROOTFS} | cut -f1)"
    REAL_DIM="$(echo $(expr ${DU_DIM} + ${DU_DIM} \* 10 / 100 + 1))"
    REAL_DIM="$(($REAL_DIM + $BOOT_DIM + 100))"

    dd if=/dev/zero of=$IMG bs=1024k count=0 seek=${REAL_DIM} >/dev/null 2>&1
}

mkpart_mkfs () {
    losetup $FREELO $IMG 0
    parted -s ${FREELO} mklabel msdos || true
    parted -a optimal -s ${FREELO} mkpart primary fat32 1 ${BOOT_DIM} || true
    parted -a optimal -s ${FREELO} mkpart primary ext4 ${BOOT_DIM} 100% || true
    parted -s "${FREELO}" set 1 boot on || true
    parted -s "${FREELO}" set 1 lba off || true

    mkfs.vfat -F 32 -n "BOOT" ${FREELO}p1 >/dev/null 2>&1
    mkfs.ext4 -L "ROOTFS" ${FREELO}p2 >/dev/null 2>&1

    ret="$?"
    success "Setting up two partition and format"
    debug
}

boot_cp () {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ] || [ -e "$4" ]; then
        mkdir -p binary.tmp
        mount ${FREELO}p1 binary.tmp
        cp -fr $1 binary.tmp
        cp -fr $2 binary.tmp
        cp -fr $3 binary.tmp
        cp -fr $4 binary.tmp
        umount binary.tmp

        ret="$?"
        success "Copying $1 $2 $3 $4 to SD boot partition"
        debug
   fi
    }

rootfs_cp () {
     mount ${FREELO}p2 binary.tmp
     cp -af ${ROOTFS}/* binary.tmp

    sync && sleep 1
    umount binary.tmp
    rmdir binary.tmp
    sync
    lodetach ${FREELO}

    ret="$?"
    success "Copying ROOTFS contents to SD rootfs partition"
    debug
}

finalize () {

    zip -r $IMG.zip $IMG >/dev/null 2>&1

    ret="$?"
    success "Compressing SD image file"
    debug

    rm -rf ${ROOTFS}
    rm -rf $IMG
}

usage () 
{
    echo Usage:
    echo "    ./mk_image.sh BOARD_DIR"
    echo "                --BOARD_DIR    zcu102 or zcu104"
    echo "    BOARD_DIR must contain BOOT.BIN and xclbin"
}

############################ MAIN()
file_must_exists "BOOT.BIN"
file_must_exists "dpu.xclbin"
file_must_exists "image.ub"
file_must_exists "rootfs.tar.gz"
file_must_exists "*_base.hwh"

calc_space      "rootfs.tar.gz"

mkpart_mkfs

boot_cp         "BOOT.BIN" \
                "dpu.xclbin" \
                "image.ub" \
                "*_base.hwh"

rootfs_cp

finalize

msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` http://vim.spf13.com/"