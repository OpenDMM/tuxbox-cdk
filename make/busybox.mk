if ENABLE_IDE
POSSIBLY_IDE=-Dide
endif

$(DEPDIR)/busybox: bootstrap @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dyadd $(POSSIBLY_IDE) Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		@INSTALL_busybox@
	@CLEANUP_busybox@
	touch $@


if TARGETRULESET_FLASH

flash-busybox: bootstrap $(flashprefix)/root @DEPENDS_busybox@ Patches/busybox.config.m4 Patches/busybox.diff
	@PREPARE_busybox@
	m4 -Dflash $(POSSIBLY_IDE) Patches/busybox.config.m4 > @DIR_busybox@/.config
	cd @DIR_busybox@ && \
		$(MAKE) dep all \
			CROSS=$(target)- \
			CFLAGS_EXTRA="$(TARGET_CFLAGS)" && \
		$(MAKE) install PREFIX=$(flashprefix)/root
	@CLEANUP_busybox@
	@FLASHROOTDIR_MODIFIED@

endif

.PHONY: flash-busybox
