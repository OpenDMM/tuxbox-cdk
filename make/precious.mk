################################################################ 
# This .PRECIOUS-bizarreness is there to tell Make that these files are not
# just "intermediate products", but are not to be deleted.  For the
# directories, these are not really valuable, however, make tries to
# delete them with rm, and this fails, generating error messages that
# may be ugly and/or confusing.

.PRECIOUS: \
$(flashprefix)/neutrino-cramfs.img% $(flashprefix)/enigma-cramfs.img% \
$(flashprefix)/neutrino-squashfs.img% $(flashprefix)/enigma-squashfs.img% \
$(flashprefix)/neutrino-jffs2.img% $(flashprefix)/enigma-jffs2.img% \
$(flashprefix)/root-%-jffs2  $(flashprefix)/root-% \
$(flashprefix)/root-neutrino-% $(flashprefix)/root-enigma-% \
$(flashprefix)/root-neutrino-%-p $(flashprefix)/root-enigma-%-p \
$(flashprefix)/vmlinuz-% \
$(flashprefix)/var-%.jffs2 \
$(flashprefix)/root-%.jffs2 \
$(flashprefix)/root-%.cramfs $(flashprefix)/root-%.squashfs \
%/lib/ld.so.1 \
$(flashprefix)/root/lib/tuxbox/plugins/%.cfg
