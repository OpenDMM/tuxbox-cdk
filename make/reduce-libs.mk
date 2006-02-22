$(flashprefix)/root-neutrino-cramfs/lib/ld.so.1 \
$(flashprefix)/root-neutrino-squashfs/lib/ld.so.1 \
$(flashprefix)/root-neutrino-jffs2/lib/ld.so.1 \
$(flashprefix)/root-enigma-cramfs/lib/ld.so.1 \
$(flashprefix)/root-enigma-squashfs/lib/ld.so.1 \
$(flashprefix)/root-enigma-jffs2/lib/ld.so.1: \
%/lib/ld.so.1: %
	find $</lib -maxdepth 1 -type f -o -type l | xargs rm -f
	cp -d $(targetprefix)/lib/libnss_dns-?.*.so $</lib
	cp -d $(targetprefix)/lib/libnss_files-?.*.so $</lib
	$(MKLIBS) --target $(target) --ldlib ld.so.1 --libc-extras-dir \
		$(targetprefix)/lib/libc_pic \
		-d $</lib \
		-D -L $(mklibs_librarypath) \
		--root $< \
		`find $</bin/ -path "*bin/?*"` \
		`find $</lib/ -name "libnss_*"` \
		`find $</lib/ -name "*.so" -type f` \
		`find $</sbin/ -path "*sbin/?*"`
	if [ -e $(flashprefix)/root/lib/liblufs-ftpfs.so.2.0.0 ]; then \
		cp $(flashprefix)/root/lib/liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so.2.0.0 ; \
		ln -sf liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so.2 ; \
		ln -sf liblufs-ftpfs.so.2.0.0 $</lib/liblufs-ftpfs.so ; \
	fi
	$(target)-strip --remove-section=.comment --remove-section=.note \
		`find $</bin/ -path "*bin/?*"` \
		`find $</sbin/ -path "*sbin/?*"` 2>/dev/null || /bin/true
	$(target)-strip --remove-section=.comment --remove-section=.note --strip-unneeded \
		`find $</lib/tuxbox -name "*.so"` 2>/dev/null || /bin/true
	$(target)-strip $</lib/* 2>/dev/null || /bin/true
	chmod u+rwX,go+rX -R $</
	find $</lib -name *.la | xargs rm -f
	rm -rf $</include
