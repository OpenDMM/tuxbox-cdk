$(flashprefix)/root-neutrino-cramfs-p/lib/ld.so.1 \
$(flashprefix)/root-neutrino-squashfs-p/lib/ld.so.1 \
$(flashprefix)/root-neutrino-jffs2-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-cramfs-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-squashfs-p/lib/ld.so.1 \
$(flashprefix)/root-enigma-jffs2-p/lib/ld.so.1: \
%/lib/ld.so.1: %
	find $</lib -maxdepth 1 -type f -o -type l | xargs rm -f
	cp -d $(targetprefix)/lib/libnss_dns-?.*.so $</lib
	cp -d $(targetprefix)/lib/libnss_files-?.*.so $</lib
	$(MKLIBS) --target $(target) --ldlib ld.so.1 --libc-extras-dir \
		$(targetprefix)/lib/libc_pic \
		-d $</lib \
		-D -L $(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins \
		--root $< \
		`find $</bin/ -path "*bin/?*"` \
		`find $</lib/ -name "libnss_*"` \
		`find $</lib/ -name "*.so" -type f` \
		`find $</sbin/ -path "*sbin/?*"`
	$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $</bin/ -path "*bin/?*"` \
		`find $</sbin/ -path "*sbin/?*"` 2>/dev/null || /bin/true
	$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $</lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	$(target)-strip $</lib/* 2>/dev/null || /bin/true
	chmod u+rwX,go+rX -R $</
	find $</lib -name *.la | xargs rm -f
	rm -rf $</include
