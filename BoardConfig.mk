#
# Copyright (C) 2018 The TwrpBuilder Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := device/samsung/kiran

# Platform
TARGET_ARCH                  := arm
TARGET_ARCH_VARIANT          := armv7-a-neon
TARGET_CPU_VARIANT           := generic
TARGET_CPU_ABI               := armeabi-v7a
TARGET_CPU_ABI2              := armeabi
TARGET_BOOTLOADER_BOARD_NAME := sc7727s
TARGET_BOARD_PLATFORM        := sc8830
TARGET_BOARD_PLATFORM_GPU    := mali-400
BOARD_VENDOR                 := samsung

# Bootloader
TW_NO_REBOOT_BOOTLOADER     := true
TW_HAS_DOWNLOAD_MODE        := true
BOARD_HAS_NO_MISC_PARTITION := true

# Recovery
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 8338608
BOARD_FLASH_BLOCK_SIZE := 0
BOARD_HAS_NO_REAL_SDCARD := true
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_USES_RECOVERY_AS_BOOT := true 
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_RECOVERY_SWIPE := true
BOARD_USES_MMCUTILS := true
BOARD_SUPPRESS_EMMC_WIPE := true
TW_INPUT_BLACKLIST := "hbtp_vm"
BOARD_CANT_BUILD_RECOVERY_FROM_BOOT_PATCH := true

# Kernel
TARGET_KERNEL_SOURCE := kernel/samsung/kiran
TARGET_KERNEL_CONFIG := tizen_kiran_defconfig
BOARD_CUSTOM_BOOTIMG_MK := $(LOCAL_PATH)/shbootimg.mk
BOARD_KERNEL_CMDLINE := mem=768M ram=768M root=/dev/mmcblk0p24 ro rootfstype=ext4 rootwait systemd.unit=recovery-mode.target pwron.reason=0x0 console=ttyS1,115200n8 androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --dt $(LOCAL_PATH)/kernel/dtb

# Recovery
RECOVERY_GRAPHICS_USE_LINELENGTH := true

# TeamWin Recovery
TW_THEME                := portrait_hdpi
TW_EXCLUDE_TZDATA       := false
TW_EXCLUDE_NANO         := false
TW_EXCLUDE_BASH         := false
TW_INCLUDE_FB2PNG       := true
TW_FORCE_USE_BUSYBOX    := true
TW_INCLUDE_CRYPTO       := true
TW_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone1/temp"


