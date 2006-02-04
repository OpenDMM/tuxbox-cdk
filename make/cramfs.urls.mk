# Experimental, does (essentially) nothing unless $(updatehttpprefix) is
# nonempty.

# Create a file with URLs containing lists of possible image files for
# updating. Don't let the name confuse: This convers all sort of image
# files, not just cramfs. The file name is well established though.

$(flashprefix)/root/etc/cramfs.urls:
	@rm -f $@
	@touch $@
	if [ ! -z $(updatehttpprefix) ] ; then \
		echo $(updatehttpprefix)cramfs.list 	>> $@; \
		echo $(updatehttpprefix)squashfs.list 	>> $@; \
		echo $(updatehttpprefix)img.list 	>> $@; \
	fi
	@TUXBOX_CUSTOMIZE@
