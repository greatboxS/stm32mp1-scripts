# !/bin/bash
# Device tree
DT_NAME=stm32mp157a-dk1.dtb

# platform selection
BOOT_DEVICE_SELECTED=sd
BOOT_DEVICE=STM32MP_SDMMC=1
PLATFORM_SELECTED=stm32mp15
PLATFORM=STM32MP15=1

# Build mode
DEBUG_MODE=0
BUILD_MODE=release

# Build output image type
BUILD_TYPE=stm32
STM32_IMAGE=1
ARCH_SP=sp_min
BUILD_DIR=build

# Clean
BUILD_CLEAN=0

# Parsing all arguments
while getopts "hcgd:b:p:t:o:" opt; do
    case $opt in
    d)
        if [ ! -z "$OPTARG" ]
        then
            DT_NAME=$OPTARG
        fi
        LINUX_GEN_CONFIG=1
    ;;

    b)
        if [ ! -z "$OPTARG" ]
        then
            BOOT_DEVICE_SELECTED=$OPTARG
        fi
    ;;

    p)
        if [ $OPTARG = "stm32mp13" ]; then
            PLATFORM_SELECTED=OPTARG
            PLATFORM=STM32MP13=1
			ARCH_SP=none
			STM32_IMAGE=0
			DT_NAME=""
        fi
    ;;

    g)
        DEBUG_MODE=1
        BUILD_MODE=debug
    ;;

    t)
        if [ $OPTARG = "optee" -o $OPTARG = "fip" -o $OPTARG = "none" ]
		then
            BUILD_TYPE=$OPTARG
            if [ $OPTARG = "fip" ]
            then
                STM32_IMAGE=0
			else
				ARCH_SP=$OPTARG
            fi
        fi
    ;;

	o)
		BUILD_DIR=$OPTARG
	;;

	c)
		BUILD_CLEAN=1
	;;

    h)
        echo "Options:"
        echo "Device tree file:             -d <default stm32mp15a-dk1>"
        echo "Boot device:                  -b <sd | emmc | usb | uart | rnand | spi_nand | spi_nor>"
        echo "Enable debug mode:            -g"
        echo "Build secure partition type: 	-t <sp_min | optee | fip | none>"
        echo "Build output:                 -o <default build/>"
        echo "Build clean:                  -c"
        exit;
    ;;
    esac
done

case $BOOT_DEVICE_SELECTED in
sd)
    BOOT_DEVICE=STM32MP_SDMMC=1
;;
emmc)
    BOOT_DEVICE=STM32MP_EMMC=1
;;
usb)
    BOOT_DEVICE=STM32MP_USB_PROGRAMMER=1
;;
uart)
    BOOT_DEVICE=STM32MP_UART_PROGRAMMER=1
;;
rnand)
    BOOT_DEVICE=STM32MP_RAW_NAND=1
;;
spi_nand)
    BOOT_DEVICE=STM32MP_SPI_NAND=1
;;
spi_nor)
    BOOT_DEVICE=STM32MP_SPI_NOR=1
;;
esac

echo "------------------------------------------------------------------"
echo "Build platform:			$PLATFORM_SELECTED"
echo "Build type:    			$BUILD_MODE"
echo ""
echo "Option         			$PLATFORM"
echo "               			STM32MP_USE_STM32IMAGE=$STM32_IMAGE"
echo "              			AARCH32_SP=$ARCH_SP"
echo "               			$BOOT_DEVICE"
echo "              			DTB_FILE_NAME=$DT_NAME"
echo "               			DEBUG=$DEBUG_MODE"
echo "               			BUILD_BASE=$BUILD_DIR"
echo "------------------------------------------------------------------"

if [ $BUILD_CLEAN -eq 1 ]; then
	echo "-- Clean old building"
	make \
	PLAT=stm32mp1 \
	ARCH=aarch32 CROSS_COMPILE=arm-linux-gnueabi- \
	STM32MP_USE_STM32IMAGE=$STM32_IMAGE \
	AARCH32_SP=$ARCH_SP \
	DTB_FILE_NAME=$DT_NAME \
	$PLATFORM \
	$BOOT_DEVICE \
	DEBUG=$DEBUG_MODE \
	BUILD_BASE=$BUILD_DIR \
	clean
	echo ""
fi

# Build TF-A image
echo "-- Start building all TF-A images"
make \
PLAT=stm32mp1 \
ARCH=aarch32 CROSS_COMPILE=arm-linux-gnueabi- \
STM32MP_USE_STM32IMAGE=$STM32_IMAGE \
AARCH32_SP=$ARCH_SP \
DTB_FILE_NAME=$DT_NAME \
$PLATFORM \
$BOOT_DEVICE \
DEBUG=$DEBUG_MODE \
BUILD_BASE=$BUILD_DIR \
all -j4
echo ""