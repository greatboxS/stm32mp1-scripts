# !/bin/bash
export CUR_DIR=$(pwd)
. $CUR_DIR/platform.sh

UBOOT_BUILD=__build/uboot
UBOOT_OUTPUT=__output/uboot

UBOOT_CONFIG=stm32mp15_basic_defconfig
UBOOT_DT=stm32mp15a-dk1
UBOOT_BUILD_TYPE=basic # basic | dev | trusted
UBOOT_IMAGES="$UBOOT_BUILD/u-boot-spl.stm32 \
                $UBOOT_BUILD/u-boot.img"
UBOOT_CLEAN=0
UBOOT_GEN_CONFIG=0

argument_parser() {
    while getopts "hc:d:t:f" opt; do
    case $opt in
        c)
            if [ ! -z "$OPTARG" ]
            then
                UBOOT_CONFIG=$OPTARG
            fi
            UBOOT_GEN_CONFIG=1
        ;;

        d)
            if [ ! -z "$OPTARG" ]
            then
                UBOOT_DT=$OPTARG
            fi
        ;;

        t)
            if [ ! -z "$OPTARG" ]
            then
                UBOOT_BUILD_TYPE=$OPTARG
            fi
        ;;

        f)
            UBOOT_CLEAN=1
        ;;

        h)
            echo "Options:"
            echo "Configuration file:           -c <default stm32mp15_basic_defconfig>"
            echo "Device tree file:             -d <default stm32mp15a-dk1>"
            echo "Build type:                   -t <default basic, (basic|dev|trusted)"
            echo "Clean:                        -f"
            exit;
        ;;
        esac
    done
}

argument_parser $@

case $UBOOT_BUILD_TYPE in
    basic)
        UBOOT_IMAGES="$UBOOT_BUILD/u-boot-spl.stm32 \
                        $UBOOT_BUILD/u-boot.dtb"
    ;;
    dev)
        UBOOT_IMAGES="$UBOOT_BUILD/u-boot-nobi.bin \
                        $UBOOT_BUILD/u-boot.dtb"
    ;;
    trusted)
        UBOOT_IMAGES="$UBOOT_BUILD/u-boot-spl.stm32 \
                        $UBOOT_BUILD/u-boot.img"
    ;;
esac

echo ""
echo "----------------------------------------------------------------"
echo "Build configuration:      $UBOOT_CONFIG"
echo "Device tree:              $UBOOT_DT"
echo "Build type:               $UBOOT_BUILD_TYPE"
echo "----------------------------------------------------------------"

if [ UBOOT_CLEAN -eq 1 ]
then
    echo "--- Clean old configuration file"
    make mrproper O=$UBOOT_BUILD
fi

if [ UBOOT_GEN_CONFIG -eq 1 ]
then
    echo "--- Generate new configuration"
    make $UBOOT_CONFIG O=$UBOOT_BUILD
fi

echo "--- Build u-boot"
make DEVICE_TREE=$UBOOT_DT O=$UBOOT_BUILD -j4

for img in $UBOOT_IMAGES
do
    if [ -f img ]
    then
        cp -vr $UBOOT_IMAGES $UBOOT_OUTPUT
    else
        echo "-- Image $img not found"
    fi
done

echo ""