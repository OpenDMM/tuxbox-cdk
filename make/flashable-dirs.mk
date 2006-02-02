# This section builds directories that can be used to create filesystems
#
# Pattern: $partition-$gui[-$filesystem]

$(flashprefix)/var-neutrino $(flashprefix)/var-enigma: \
$(flashprefix)/var-%: \
$(flashprefix)/root-%-cramfs-p
	rm -rf $@
	cp -rd $</var $@
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$(flashprefix)/.junk flashprefix_rw=$@
	rm -rf $(flashprefix)/.junk
	if [ -d $</etc/ssh ] ; then \
		cp -rd $</etc/ssh $@/etc/ssh ; \
	fi
	$(INSTALL) -d $@/plugins
	$(INSTALL) -d $@/tuxbox/plugins
	$(MAKE) -C $(appsdir)/tuxbox/tools/camd install prefix=$@
	$(target)-strip --remove-section=.comment --remove-section=.note $@/bin/camd2
#	cp $</bin/camd2 $@/bin/camd2
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-neutrino-jffs2 $(flashprefix)/root-enigma-jffs2: \
$(flashprefix)/root-%-jffs2: \
$(flashprefix)/root-%-jffs2-p
	rm -rf $@
	cp -rd $< $@
	$(MAKE) flash-bootlogos flashbootlogosdir=$@/var/tuxbox/boot
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$@
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

# Read-only-root mods
$(flashprefix)/root-neutrino-cramfs $(flashprefix)/root-neutrino-squashfs: \
$(flashprefix)/root-neutrino-%: \
$(flashprefix)/root-neutrino-%-p $(flashprefix)/var-neutrino
	rm -rf $@
	cp -dr $< $@
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/.junk
	rm -rf $(flashprefix)/.junk
	rm -fr $@/boot
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf ../var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/bin/camd2 $@/bin/camd2
	mv $@/etc/init.d/rcS.insmod $@/etc/init.d/rcS
	@TUXBOX_CUSTOMIZE@

$(flashprefix)/root-enigma-cramfs $(flashprefix)/root-enigma-squashfs: \
$(flashprefix)/root-enigma-%: \
$(flashprefix)/root-enigma-%-p $(flashprefix)/var-enigma
	rm -rf $@
	cp -dr $< $@
	$(MAKE) -C root install-flash flashprefix_ro=$@ flashprefix_rw=$(flashprefix)/var-enigma
	rm -fr $@/boot
	rm -fr $@/var/*
	echo "/dev/mtdblock/3     /var     jffs2     defaults     0 0" >> $@/etc/fstab
	if [ -d $@/etc/ssh ] ; then \
		rm -fr $@/etc/ssh ; \
		ln -sf ../var/etc/ssh $@/etc/ssh ; \
	fi
	ln -sf /var/etc/issue.net $@/etc/issue.net
	ln -sf /var/etc/localtime $@/etc/localtime
	ln -sf /var/bin/camd2 $@/bin/camd2
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
