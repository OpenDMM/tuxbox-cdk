## Makefile for Tuxbox

all:
	@echo "You probably do not want to build all possible targets."
	@echo "Sensible targets are, e.g. yadd-enigma or flash-neutrino-jffs2-2x."
	@echo "If you REALLY want to build everything, then \"make everything\""

if TARGETRULESET_FLASH
everything: yadd-all flash-all-all-all serversupport extra 
else
everything: yadd-all extra serversupport
endif


################################################################
# High-level yadd targets

if KERNEL26
bare-os: yadd-u-boot kernel-cdk driver yadd-etc busybox module_init_tools tuxinfo misc_tools
else
bare-os: yadd-u-boot kernel-cdk driver yadd-etc busybox modutils tuxinfo
endif
	@TUXBOX_YADD_CUSTOMIZE@

yadd-none: bare-os config tuxbox_tools procps ftpd yadd-ucodes version
	@TUXBOX_YADD_CUSTOMIZE@

yadd-micro-neutrino: bare-os config yadd-ucodes camd2 switch neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-neutrino: yadd-none neutrino-plugins fx2-plugins neutrino
	@TUXBOX_YADD_CUSTOMIZE@

yadd-enigma: yadd-none enigma-plugins fx2-plugins enigma
	@TUXBOX_YADD_CUSTOMIZE@

yadd-lcars: yadd-none lcars
	@TUXBOX_YADD_CUSTOMIZE@

yadd-all: yadd-none plugins neutrino enigma lcars
	@TUXBOX_YADD_CUSTOMIZE@

extra: libs libs_optional contrib_apps fun dvb_apps root_optional udev devel bash

# Set up some default values (used only by serversetup).
include make/defaultvalues.mk

# Set up the build environment
include make/buildenv.mk

# Set up the cross compilation enironment, including linux kernel
# source and directory structure
include make/bootstrap.mk

# The automounter (optional)
include make/automount.mk

# The busybox (implements most standard Unix commands, like ls,...)
include make/busybox.mk

# Populate the etc directory in YADD
include make/etc.mk

# The ftpd
include make/ftpd.mk

# Some core tools (important and less important)
include make/rootutils.mk

# A number of libraries, some of which necessary for neutrino or enigma
include make/contrib-libs.mk

# Some non-GUI applications, none of which are essential
include make/contrib-apps.mk

# Tools (debugger etc) for the Tuxbox developer
include make/development-tools.mk

# The kaffe java-implementation (nonessential, presently does not build) 
include make/java-stuff.mk

# Gaming platforms (gnuboy scummvm sdldoom)
include make/fun.mk

# Nonessential DVB application 
include make/dvb-apps.mk

# Bluetooth (nonessential)
include make/bluetooth.mk

# FUSE and djmount for uPnP support (non-essential)
include make/upnp.mk

# The u-boot boot loader
include make/u-boot.mk

# Build kernel and its drivers
include make/linuxkernel.mk

# Install dvb configuration files (cables.xml & satellites.xml)
include make/dvb-config.mk

# dvbsnoop is a tool for analyzing dvb streams (non-essential)
include make/dvbsnoop.mk

# A nonessential library
include make/libdvb++.mk

# The zapit daemon
include make/zapit.mk

# More dvb tools, of which only streampes is installed per default
include make/dvb_tools.mk

# More misc libs, mostly nonessential
include make/misc_libs.mk

# Misc tools, not essential
include make/misc_tools.mk

# Enigma GUI
include make/enigma.mk

# nonessential entertainment, like "screensavers" for the lcd display
include make/funstuff.mk

# The LCARS GUI
include make/lcars.mk

# LCD tools
include make/lcd.mk

# Essential, and some less essential, libraries
include make/tuxbox_libs.mk

# A small, but absolutely essential library
include make/libtuxbox.mk

# The Neutrino GUI
include make/neutrino.mk

# Plugins
include make/plugins.mk

# Some small command line tools, several of which are essential
include make/tuxbox_tools.mk

# Application that run on the build host
include make/hostapps.mk

# Generate some support files for a YADD- or flashing-server
include make/serversupport.mk

# Optionally install ucodes in the image
include make/ucodes.mk

# Generate a /.version file in the image
include make/version.mk

if TARGETRULESET_FLASH
# High-level flash targets are:

# flash-[neutrino,enigma,all]-[cramfs,squashfs,jffs2,all]-[1x,2x,all]
# Expand all flash targets containg the word "all"
include make/flash-expand-targets.mk

# Create complete images ("without BN bootloader")
include make/fullimages.mk

# Create images of the root and var file systems
include make/partition-images.mk

# Create root and var filesystems, ready for image creation
include make/flashable-dirs.mk

# Strip libraries of symbols not needed.
include make/reduce-libs.mk

# Create the root file systems for jffs2-only, cramfs, and squashfs
# images (containing kernel but not GUI)
include make/flashroot-fs.mk

# Create the root file system, without kernel and GUI 
include make/flashroot.mk

# The streampes stuff
include make/flash-streampes.mk

# Build distribution lists in neutrino internet update format
include make/distribution-lists.mk

# /etc/cramfs.urls contains URLs for update lists
include make/cramfs.urls.mk
endif

# Files not to be deleted, even though they are intermediate products
include make/precious.mk

# "Phony" make targets
include make/phony.mk

# Create the TAGS file
include make/tags.mk

# A number of cleaning targets
include make/cleantargets.mk

# Target for building source distributions (hardly used these days of CVS :-)
include make/disttargets.mk

# Give the user rope to hang himself :-).  (Note: read from the
# generated Makefile during make run, automake or configure does not
# see it.)
-include ./Makefile.local
