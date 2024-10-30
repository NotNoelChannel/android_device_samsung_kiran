# Paths and tools setup
LZMA_BIN := $(shell which lzma)
LZOP_BIN := $(shell which lzop)
MKBOOTIMG := $(shell which mkbootimg)  # Path to mkbootimg

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
	$(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "----- Made recovery image with LZMA -------- $@"

# Boot Image with LZMA Compression
LZMA_BOOT_RAMDISK := $(PRODUCT_OUT)/ramdisk-lzma.img
$(LZMA_BOOT_RAMDISK): $(BUILT_RAMDISK_TARGET)
	gunzip -f < $(BUILT_RAMDISK_TARGET) | $(LZMA_BIN) > $@

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(LZMA_BOOT_RAMDISK)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@ --ramdisk $(LZMA_BOOT_RAMDISK)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo "Made boot image with LZMA: $@"

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
	$(LZOP_BIN) -f9 -o $@ $(recovery_uncompressed_ramdisk)
	@echo "----- Made recovery image with LZOP ------ $@"
