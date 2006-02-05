$(flashprefix)/root-neutrino-cramfs-p \
$(flashprefix)/root-neutrino-squashfs-p \
$(flashprefix)/root-neutrino-jffs2-p: \
$(flashprefix)/root-neutrino-%-p: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	cp -rd $</* $@
	$(MAKE) $@/lib/ld.so.1
	@TUXBOX_CUSTOMIZE@
