# Paths and tools setup
LZMA_BIN := $(shell which lzma)
LZOP_BIN := $(shell which lzop)
MKBOOTIMG := $(shell which mkbootimg)  # Ensure mkbootimg path is correct
PRODUCT_OUT := /home/runner/TWRP/out/target/product/kiran

# Recovery Image with LZMA Compression
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_uncompressed_ramdisk) \
		$(recovery_kernel)
	@echo "----- Compressing recovery ramdisk with LZMA ------"
	rm -f $(recovery_uncompressed_ramdisk).lzma
	$(LZMA_BIN) $(recovery_uncompressed_ramdisk)
	$(hide) cp $(recovery_uncompressed_ramdisk).lzma $(recovery_ramdisk)
	@echo "----- Making recovery image with LZMA ------"
	$(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel \
		--ramdisk $(PRODUCT_OUT)/ramdisk-recovery.img \
		--cmdline "mem=768M ram=768M root=/dev/mmcblk0p24 ro rootfstype=ext4 rootwait systemd.unit=recovery-mode.target pwron.reason=0x0 console=ttyS1,115200n8 androidboot.selinux=permissive" \
		--base 0x00000000 --pagesize 2048 --ramdisk_offset 0x01000000 \
		--tags_offset 0x00000100 --dt device/samsung/kiran/kernel/dtb \
		--output $(PRODUCT_OUT)/recovery.img
	$(hide) $(call assert-max-image-size,$(PRODUCT_OUT)/recovery.img,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "----- Made recovery image with LZMA -------- $(PRODUCT_OUT)/recovery.img"

# Boot Image with LZMA Compression
LZMA_BOOT_RAMDISK := $(PRODUCT_OUT)/ramdisk-lzma.img
$(LZMA_BOOT_RAMDISK): $(BUILT_RAMDISK_TARGET)
	gunzip -f < $(BUILT_RAMDISK_TARGET) | $(LZMA_BIN) > $@

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(LZMA_BOOT_RAMDISK)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel \
		--ramdisk $(LZMA_BOOT_RAMDISK) \
		--cmdline "mem=768M ram=768M root=/dev/mmcblk0p24 ro rootfstype=ext4 rootwait systemd.unit=boot-mode.target" \
		--base 0x00000000 --pagesize 2048 --ramdisk_offset 0x01000000 \
		--tags_offset 0x00000100 --output $(PRODUCT_OUT)/boot.img
	$(hide) $(call assert-max-image-size,$(PRODUCT_OUT)/boot.img,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo "Made boot image with LZMA: $(PRODUCT_OUT)/boot.img"

# Recovery Image with LZOP Compression
recovery_uncompressed_device_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery-device.cpio
$(recovery_uncompressed_device_ramdisk): $(MKBOOTFS) \
		$(INSTALLED_RAMDISK_TARGET) \
		$(INTERNAL_RECOVERYIMAGE_FILES) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_prop) $(recovery_resource_deps) $(recovery_root_deps) \
		$(recovery_fstab) \
		$(RECOVERY_INSTALL_OTA_KEYS)
	$(call build-recoveryramdisk)
	@echo "----- Making uncompressed recovery ramdisk ------"
	$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

$(INSTALLED_RECOVERYIMAGE_TARGET_LZOP): $(recovery_uncompressed_ramdisk)
	@echo "----- Compressing recovery ramdisk with LZOP ------"
	$(LZOP_BIN) -f9 -o $(PRODUCT_OUT)/recovery-lzop.img $(recovery_uncompressed_ramdisk)
	@echo "----- Made recovery image with LZOP ------ $(PRODUCT_OUT)/recovery-lzop.img"
