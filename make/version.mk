# Create the /.version file

# If the user has a customization, run it INSTEAD of the default action.

version: $(targetprefix)/.version

flash-version: $(flashprefix)/root/.version

$(flashprefix)/root/.version: $(flashprefix)/root
	if [ -x flash-version-local.sh ] ; then \
		sh flash-version-local.sh $(flashprefix) $(buildprefix); \
	else \
		echo "version=0200`date +%Y%m%d%H%M`" 	>  $@;	\
		echo "creator=`id -un`" 		>> $@;	\
		echo "imagename=newmake-image" 		>> $@;	\
		echo "homepage=http://www.tuxbox.org" 	>> $@;	\
	fi

$(targetprefix)/.version: $(targetprefix)
	if [ -x version-local.sh ] ; then \
		sh version-local.sh $(targetprefix) $(buildprefix); \
	else \
		echo "version=0200`date +%Y%m%d%H%M`" 	 > $@;	\
		echo "creator=`id -un`" 		>> $@;	\
		echo "imagename=newmake-yadd" 		>> $@;	\
		echo "homepage=http://www.tuxbox.org" 	>> $@;	\
	fi

