#################################################
#  ccache
#
#You can use ccache for compiling if it is installed on your system or cdk/bin.
#With this rule you can install ccache independ from your system. 
#Use <make ccache> for installing in cdk/bin.
#Isn't ccache installed, you can also install later. 
#Most distributions contain the required packages or
#get the sources from http://samba.org/ftp/ccache

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
		rm -rf  $(hostprefix)/ccache-bin;\
		$(INSTALL) -d $(hostprefix)/ccache-bin ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/gcc ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/g++ ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/powerpc-tuxbox-linux-gnu-gcc ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/powerpc-tuxbox-linux-gnu-g++ ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/powerpc-tuxbox-linux-gnu-cpp ;\
		ln -s $(hostprefix)/bin/ccache $(hostprefix)/ccache-bin/powerpc-tuxbox-linux-gnu-gcc-.3.4.4 ;\
		$(hostprefix)/bin/ccache -M $(maxcachesize) ;\
		$(hostprefix)/bin/ccache -F $(maxcachefiles) ;\
		$(hostprefix)/bin/ccache -s ;\
		rm -rf @DIR_ccache@
		touch $@
