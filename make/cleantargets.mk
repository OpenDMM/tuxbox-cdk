APPSCLEANUP:=rm -f $(DEPDIR)/neutrino $(DEPDIR)/enigma $(DEPDIR)/zapit $(DEPDIR)/plugins $(DEPDIR)/tuxbox_tools $(DEPDIR)/misc_tools $(DEPDIR)/misc_libs $(DEPDIR)/tuxbox_libs $(DEPDIR)/libtuxbox $(DEPDIR)/dvb_tools $(DEPDIR)/driver $(DEPDIR)/lcars $(DEPDIR)/lcd $(DEPDIR)/dvbsnoop 

depsclean:
	$(DEPSCLEANUP)
	$(APPSCLEANUP)
	rm -f $(DEPDIR)/u-boot $(DEPDIR)/linuxkernel $(DEPDIR)/driver

if TARGETRULESET_FLASH
mostlyclean-local: flash-clean cdk-clean
else
mostlyclean-local: cdk-clean
endif

cdk-clean:
	$(APPSCLEANUP)
	-$(MAKE) -C linux clean
	-$(MAKE) -C $(driverdir) KERNEL_LOCATION=$(buildprefix)/linux \
		BIN_DEST=$(targetprefix)/bin \
		INSTALL_MOD_PATH=$(targetprefix) clean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino clean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars clean
	-$(MAKE) -C $(appsdir)/dvb/zapit clean
	-$(MAKE) -C $(appsdir)/tuxbox/plugins clean
	-$(MAKE) -C $(appsdir)/tuxbox/tools clean
	-$(MAKE) -C $(appsdir)/misc/tools clean
	-$(MAKE) -C $(appsdir)/misc/libs clean
	-$(MAKE) -C $(appsdir)/tuxbox/libs clean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox clean
	-$(MAKE) -C $(appsdir)/dvb/tools clean
	-$(MAKE) -C $(appsdir)/dvb/config distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop clean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd clean
	-$(MAKE) -C $(hostappsdir) clean

clean-local:
	-$(MAKE) -C etc clean
	-$(MAKE) -C $(appsdir) clean
	-$(MAKE) -C $(driverdir) clean \
		KERNEL_LOCATION=$(buildprefix)/linux
	-rm -f linux
	-rm -rf build
	-rm -f $(bootprefix)/dboxflasher
	-rm -f $(bootprefix)/u-boot
	-rm -f $(bootprefix)/kernel-cdk
	-@CLEANUP@

distclean-local:
	-$(MAKE) -C root distclean
	-$(MAKE) -C $(appsdir) distclean
	-$(MAKE) -C $(appsdir)/dvb/configtools distclean
	-$(MAKE) -C $(appsdir)/dvb/dvbsnoop distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvb++ distclean
	-$(MAKE) -C $(appsdir)/dvb/dvb/libdvbsi++ distclean
	-$(MAKE) -C $(appsdir)/dvb/tools distclean
	-$(MAKE) -C $(appsdir)/dvb/zapit distclean
	-$(MAKE) -C $(appsdir)/misc/libs distclean
	-$(MAKE) -C $(appsdir)/misc/tools distclean
	-$(MAKE) -C $(appsdir)/tuxbox/enigma distclean
	-$(MAKE) -C $(appsdir)/tuxbox/funstuff distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcars distclean
	-$(MAKE) -C $(appsdir)/tuxbox/lcd distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libs distclean
	-$(MAKE) -C $(appsdir)/tuxbox/libtuxbox distclean
	-$(MAKE) -C $(appsdir)/tuxbox/neutrino distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools distclean
	-$(MAKE) -C $(hostappsdir) distclean
	-$(MAKE) -C $(appsdir)/tuxbox/tools/hotplug distclean
	-$(MAKE) -C $(driverdir) distclean KERNEL_LOCATION=$(buildprefix)/linux
	-rm Makefile-archive
	-rm rules-downcheck.pl
	-rm $(DEPDIR) -rf
	-rm -rf $(targetprefix)
	-rm -rf $(hostprefix)
	-rm -rf $(serversupport)
if TARGETRULESET_FLASH
	-rm -rf $(flashprefix)
endif


if TARGETRULESET_FLASH
################################################################
# flash-clean deletes everything created with the flash-* commands
# flash-developerclean leaves the flfs-images and the vmlinuz-* files.
# (This is sensible, while these files seldomly change, and take rather
# long to build.)

# flash-semiclean and flash-developerclean, are "homemade",
# flash-clean and flash-mostlyclean have semantics like in the GNU
# Makefile standards.

flash-semiclean:
	rm -f $(flashprefix)/*.cramfs $(flashprefix)/*.squashfs \
	$(flashprefix)/*.jffs2 $(flashprefix)/.*-flfs \
	$(flashprefix)/*.list
	rm -rf $(flashprefix)/root
	rm -rf $(flashprefix)/var*

flash-developerclean: flash-semiclean
	rm -rf $(flashprefix)/root-*
	rm -f $(flashprefix)/*.img*

flash-mostlyclean: flash-semiclean
	rm -rf $(flashprefix)/root-*
	rm -f $(flashprefix)/*.flfs*x

flash-clean: flash-mostlyclean
	rm -f $(flashprefix)/*.img*
endif ## TARGETRULESET_FLASH
