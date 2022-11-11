# !/bin/bash
export CUR_DIR=$(pwd)
. $CUR_DIR/platform.sh

LINUX_BUILD=__build/linux
LINUX_OUTPUT=__output/linux

LINUX_IMAGES="$LINUX_BUILD/vmlinux \
                $LINUX_BUILD/arch/$ARCH/boot/zImage \
                $LINUX_BUILD/arch/$ARCH/boot/Image"

LINUX_CONFIG=stm32mp15_defconfig
LINUX_DT=stm32mp15a-dk1
LINUX_CLEAN=0
LINUX_GEN_CONFIG=0

argument_parser() {
    while getopts "hc:d:t:f" opt; do
    case $opt in
        c)
            if [ ! -z "$OPTARG" ]
            then
                LINUX_CONFIG=$OPTARG
            fi
            LINUX_GEN_CONFIG=1
        ;;

        d)
            if [ ! -z "$OPTARG" ]
            then
                LINUX_DT=$OPTARG
            fi
        ;;

        t)
            if [ ! -z "$OPTARG" ]
            then
                LINUX_BUILD_TYPE=$OPTARG
            fi
        ;;

        f)
            LINUX_CLEAN=1
        ;;

        h)
            echo "Options:"
            echo "Configuration file:           -c <default stm32mp15_basic_defconfig>"
            echo "Device tree file:             -d <default stm32mp15a-dk1>"
            echo "Clean:                        -f"
            exit;
        ;;
        esac
    done
}

argument_parser $@

echo ""
echo "----------------------------------------------------------------"
echo "Build configuration:      $LINUX_CONFIG"
echo "Device tree:              $LINUX_DT"
echo "----------------------------------------------------------------"

if [ LINUX_CLEAN -eq 1 ]
then
    echo "--- Clean old configuration file"
    make mrproper O=$LINUX_BUILD
fi

if [ LINUX_GEN_CONFIG -eq 1 ]
then
    echo "--- Generate new configuration"
    make $LINUX_CONFIG O=$LINUX_BUILD
fi

echo "--- Build u-boot"
make DEVICE_TREE=$LINUX_DT O=$LINUX_BUILD -j4

for img in $LINUX_IMAGES
do
    if [ -f img ]
    then
        cp -vr $LINUX_IMAGES $LINUX_OUTPUT
    else
        echo "-- Image $img not found"
    fi
done

echo ""