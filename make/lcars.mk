# tuxbox/lcars

$(appsdir)/tuxbox/lcars/config.status: bootstrap libcurl libfreetype $(targetprefix)/include/tuxbox/plugin.h libcommoncplusplus
	cd $(appsdir)/tuxbox/lcars && $(CONFIGURE)

lcars: $(appsdir)/tuxbox/lcars/config.status
	$(MAKE) -C $(appsdir)/tuxbox/lcars all install

# if TARGETRULESET_FLASH
# # Untested! 
# flash-lcars: $(flashprefix)/root/bin/lcars

# $(flashprefix)/root/bin/lcars: lcars $(flashprefix)/root
# 	$(INSTALL) -d $(flashprefix)/root/share/fonts
# 	$(INSTALL) $(targetprefix)/bin/lcars $(flashprefix)/root/bin
# 	cp -rd $(targetprefix)/etc/init.d/start_lcars $(flashprefix)/root/etc/init.d/
# 	cp -rd $(targetprefix)/share/fonts/ds9.ttf $(flashprefix)/root/share/fonts
# 	cp -rd $(targetprefix)/var/tuxbox/config/lcars $(flashprefix)/root/var/tuxbox/config

# endif
