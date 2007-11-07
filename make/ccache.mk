#################################################
#  ccache
#
#You can use ccache for compiling if it is installed on your system or Tuxbox-CDK in ~/cdk/bin.
#With this rule you can install ccache independ from your system. 
#Use <make ccache> for installing in cdk/bin. This own ccache-binary is preferred from configure.
#Isn't ccache installed on your system, you can also install later, but you must configure again.
#Most distributions contain the required packages or
#get the sources from http://samba.org/ftp/ccache

# generate general enviroment for ccache
CCACHE_ENV =	$(INSTALL) -d $(CCACHE_BINDIR);\
				$(CCACHE_LINKS);\
				$(CCACHE_SETUP);\
				$(CCACHE_TEST)

# own tuxbox-cdk ccache install path
CCACHE_TUXBOX_BIN = $(hostprefix)/bin/ccache

# own tuxbox-cdk ccache
ccache:

$(DEPDIR)/ccache: @DEPENDS_ccache@ directories
	@PREPARE_ccache@
	cd @DIR_ccache@ && \
		./configure \
			--build=$(build) \
			--host=$(build) \
			--prefix= && \
			$(MAKE) all && \
			$(MAKE) install DESTDIR=$(hostprefix)
		rm -rf  $(CCACHE_BINDIR);\
		$(INSTALL) -d $(CCACHE_BINDIR) ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/gcc ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/g++ ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-gcc ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-g++ ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-cpp ;\
			ln -s $(CCACHE_TUXBOX_BIN) $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-gcc-.3.4.4 ;\
		$(CCACHE_TUXBOX_BIN) -M $(maxcachesize) ;\
		$(CCACHE_TUXBOX_BIN) -F $(maxcachefiles) ;\
		$(CCACHE_TUXBOX_BIN) -s ;\
		rm -rf @DIR_ccache@
		touch $@

# tuxbox-cdk ccache enviroment dir
CCACHE_BINDIR = $(hostprefix)/ccache-bin

# generate links
CCACHE_LINKS = 	ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/gcc;\
 				ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/g++;\
				ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-gcc;\
				ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-g++;\
				ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-cpp;\
				ln -sf $(ccachedir)/ccache $(CCACHE_BINDIR)/powerpc-tuxbox-linux-gnu-gcc-.3.4.4 

# ccache test will show you ccache statistics
CCACHE_TEST =	$(ccachedir)/ccache -s 

# sets the options for ccache which are configured
CCACHE_SETUP =	$(ccachedir)/ccache -M $(maxcachesize);\
				$(ccachedir)/ccache -F $(maxcachefiles)

# cleans the markerfiles in .deps for make ccache
CCACHE_DEPSCLEANUP = rm -f .deps/ccache
