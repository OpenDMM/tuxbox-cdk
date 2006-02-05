$(flashprefix)/root-enigma-cramfs-p \
$(flashprefix)/root-enigma-squashfs-p \
$(flashprefix)/root-enigma-jffs2-p: \
$(flashprefix)/root-enigma-%-p: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-enigma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-enigma/* $@
	cp -rd $</* $@
	$(MAKE) $@/lib/ld.so.1
	@TUXBOX_CUSTOMIZE@
