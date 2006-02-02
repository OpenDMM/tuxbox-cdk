if TARGETRULESET_FLASH
.PHONY: core libs root apps boot devel java copy lib compress \
	depsclean mostlyclean clean distclean \
	flash-clean flash-semiclean flash-developerclean flash-mostlyclean
else
.PHONY: core libs root apps boot devel java depsclean mostlyclean clean distclean
endif
