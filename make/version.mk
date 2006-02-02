version: $(targetprefix)/.version

flash-version: $(flashprefix)/root/.version

$(flashprefix)/root/.version: $(flashprefix)/root
	echo "version=0200`date +%Y%m%d%H%M`" 	> $@
	echo "creator=`id -un`" 		>> $@
	echo "imagename=newmake-image" 		>> $@
	echo "homepage=http://www.tuxbox.org" 	>> $@

$(targetprefix)/.version: $(targetprefix)
	echo "version=0200`date +%Y%m%d%H%M`" 	> $@
	echo "creator=`id -un`" 		>> $@
	echo "imagename=newmake-yadd" 		>> $@
	echo "homepage=http://www.tuxbox.org" 	>> $@

