flash-all: flash-lcdmenu flash-plugins flash-ftpd flash-ssh flash-sshd flash-lib flash-all-all-all

flash-ssl: flash-ssh flash-sshd flash-lib

flash-neutrino-all flash-enigma-all: flash-%-all: \
flash-lcdmenu flash-plugins flash-ftpd flash-lib flash-%-all-all

flash-lcars-all flash-lcars $(flashprefix)/.part_lcars:
	@echo "This target is no longer supported"
	false

rebuild-flash:
	-rm -rf $(flashprefix)/root

$(flashprefix)/.flash: $(flashprefix)/root

flash-ftpd $(flashprefix)/.part_ftpd: $(flashprefix)/root/sbin/in.ftpd

flash-ssh $(flashprefix)/.part_ssh: $(flashprefix)/root/bin/ssh

flash-sshd $(flashprefix)/.part_sshd: $(flashprefix)/root/sbin/sshd

flash-plugin_dreamdata $(flashprefix)/.part_plugin_dreamdata: \
$(flashprefix)/root/lib/tuxbox/plugins/dreamdata.so

flash-dropbear $(flashprefix)/.part_dropbear: $(flashprefix)/root/sbin/dropbear

flash-dvb-tools $(flashprefix)/.part_dvb_tools: \
$(flashprefix)/root/sbin/streampes

flash-ftpfs $(flashprefix)/.part_ftpfs: $(flashprefix)/root/bin/lufsd

flash-neutrino $(flashprefix)/.part_neutrino: \
$(flashprefix)/root-cramfs-neutrino

flash-enigma $(flashprefix)/.part_enigma: $(flashprefix)/root-cramfs-enigma

flash-plugins $(flashprefix)/.part_plugins: $(myflashplugins)

flash-lcdmenu $(flashprefix)/.part_lcdmenu: $(flashprefix)/root/bin/lcdmenu

flash-lib:

flash-cramfs flash-squashfs: flash-%: $(flashprefix)/root-neutrino.%

flash-cramfsimages flash-squashfsimages: flash-%images: flash-all-%-all

flash-cramfsneutrinoimages flash-squashfsneutrinoimages: \
flash-%neutrinoimages: flash-neutrino-%-all

flash-cramfsenigmaimages flash-squashfsenigmaimages: \
flash-%enigmaimages: flash-enigma-%-all

flash-var-jffs2: $(flashprefix)/var-neutrino.jffs2

flash-root-jffs2: $(flashprefix)/root-neutrino.jffs2

flash-jffs2image: flash-all-jffs2-all

$(flashprefix)/root-cramfs-neutrino.img \
$(flashprefix)/root-squashfs-neutrino.img: \
$(flashprefix)/root-%-neutrino.img: \
$(flashprefix)/root-neutrino.%
	cp $< $@

$(flashprefix)/root-cramfs-enigma.img \
$(flashprefix)/root-squashfs-enigma.img: \
$(flashprefix)/root-%-enigma.img: \
$(flashprefix)/root-enigma.%
	cp $< $@

$(flashprefix)/cramfsjffs2neutrino_1x.img \
$(flashprefix)/cramfsjffs2neutrino_2x.img: \
$(flashprefix)/cramfsjffs2neutrino_%.img: \
$(flashprefix)/neutrino-cramfs.img%
	cp $< $@

$(flashprefix)/squashfsjffs2neutrino_1x.img \
$(flashprefix)/squashfsjffs2neutrino_2x.img: \
$(flashprefix)/squashfsjffs2neutrino_%.img: \
$(flashprefix)/neutrino-squashfs.img%
	cp $< $@

$(flashprefix)/cramfsjffs2enigma_1x.img \
$(flashprefix)/cramfsjffs2enigma_2x.img: \
$(flashprefix)/cramfsjffs2enigma_%.img: \
$(flashprefix)/enigma-cramfs.img%
	cp $< $@

$(flashprefix)/squashfsjffs2enigma_1x.img \
$(flashprefix)/squashfsjffs2enigma_2x.img: \
$(flashprefix)/squashfsjffs2enigma_%.img: \
$(flashprefix)/enigma-squashfs.img%
	cp $< $@

flash-apps $(flashprefix)/.part_apps: \
flash-ftpd flash-plugins flash-dvb-tools flash-ftpfs

flash-cramfsroot: $(flashprefix)/root-squashfs
flash-squashfsroot: $(flashprefix)/root-squashfs

$(flashprefix)/.cramfs: $(flashprefix)/root-cramfs

$(flashprefix)/var-jffs2.img: $(flashprefix)/var-neutrino.jffs2
	cp $< $@

$(flashprefix)/root-jffs2.img:$(flashprefix)/root-neutrino.jffs2
	cp $< $@

$(flashprefix)/jffs2only.img: flash-all-jffs2-all

$(flashprefix)/.squashfs-flfs $(flashprefix)/.cramfs-flfs: \
$(flashprefix)/.%-flfs: \
$(flashprefix)/%.flfs1x $(flashprefix)/%.flfs2x

$(flashprefix)/.mkflfs: $(hostprefix)/bin/mkflfs
