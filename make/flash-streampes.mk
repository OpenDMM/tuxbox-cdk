## flash-dvb-tools
## TODO: fix if possible

flash-streampes: $(flashprefix)/root $(appsdir)/dvb/tools/stream/streampes $(appsdir)/dvb/zapit/src/zapit
	$(INSTALL) $(appsdir)/dvb/tools/stream/streamsec $</sbin
	$(INSTALL) $(appsdir)/dvb/tools/stream/streamts $</sbin
	$(INSTALL) $(appsdir)/dvb/tools/stream/streampes $</sbin
	$(INSTALL) $(appsdir)/dvb/zapit/src/.libs/udpstreampes $</sbin
	@TUXBOX_CUSTOMIZE@
