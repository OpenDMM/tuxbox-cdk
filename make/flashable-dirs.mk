# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]

$(flashprefix)/var-neutrino $(flashprefix)/var-enigma: \
$(flashprefix)/var-%: \
$(flashprefix)/root-% $(flashprefix)/root
	rm -rf $@
	cp -rd $</var $@
	cp -rd $(flashprefix)/root/var/* $@
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
	rm -rf $(flashprefix)/.junk
	if [ -d $(flashprefix)/root/etc/ssh ] ; then \
		cp -rd $(flashprefix)/root/etc/ssh $@/etc/ssh ; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2 $(flashprefix)/root-enigma-jffs2 $(flashprefix)/root-lcars-jffs2: \
$(flashprefix)/root-%-jffs2: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-jffs2
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-jffs2/* $@
	$(MAKE) $@/lib/ld.so.1 mklibs_librarypath=$</lib:$</lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-cramfs $(flashprefix)/root-neutrino-squashfs: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-neutrino
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-neutrino/* $@
	$(MAKE) $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-neutrino/lib:$(flashprefix)/root-neutrino/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/bin/camd2 $@/bin/camd2
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-cramfs $(flashprefix)/root-enigma-squashfs: \
$(flashprefix)/root-enigma-%: \
$(flashprefix)/root-% $(flashprefix)/root $(flashprefix)/root-enigma
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $</* $@
	cp -rd $(flashprefix)/root-enigma/* $@
	$(MAKE) $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root-enigma/lib:$(flashprefix)/root-enigma/lib/tuxbox/plugins:$(flashprefix)/root/lib:$(flashprefix)/root/lib/tuxbox/plugins:$</lib:$(targetprefix)/lib:$(targetprefix)/lib/tuxbox/plugins
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf /var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
	ln -sf /var/bin/camd2 $@/bin/camd2
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-null-jffs2: $(flashprefix)/root $(flashprefix)/root-jffs2
	rm -rf $@
	cp -rd $(flashprefix)/root $@
	cp -rd $(flashprefix)/root-jffs2/* $@
	rm -rf $@/lib/tuxbox/plugins
	$(MAKE) $@/lib/ld.so.1 mklibs_librarypath=$(flashprefix)/root/lib:$(flashprefix)/root-jffs2/lib:$(targetprefix)/lib
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

## "Private"
flash-bootlogos:
	$(INSTALL) -d $(flashbootlogosdir)
	if [ -e $(logosdir)/logo-lcd  ] ; then \
		 cp $(logosdir)/logo-lcd $(flashbootlogosdir) ; \
	fi
	if [ -e $(logosdir)/logo-fb ] ; then \
		 cp $(logosdir)/logo-fb $(flashbootlogosdir) ; \
	fi