define(`dooption',`ifelse(`$2',`n', `# $1 is not set', `$1=y')')dnl
ifdef(`yadd',`define(`option',`dooption($1,$2)')',`define(`option',`dooption($1,$3)')')dnl
dnl
#
# Automatically generated make config: don't edit
#
HAVE_DOT_CONFIG=y

#
# General Configuration
#
option(`CONFIG_FEATURE_BUFFERS_USE_MALLOC', `n', `n')
option(`CONFIG_FEATURE_BUFFERS_GO_ON_STACK', `y', `y')
option(`CONFIG_FEATURE_BUFFERS_GO_IN_BSS', `n', `n')
option(`CONFIG_FEATURE_VERBOSE_USAGE', `n', `n')
option(`CONFIG_FEATURE_INSTALLER', `n', `n')
option(`CONFIG_LOCALE_SUPPORT', `n', `n')
option(`CONFIG_FEATURE_DEVFS', `y', `y')
option(`CONFIG_FEATURE_DEVPTS', `y', `y')
option(`CONFIG_FEATURE_CLEAN_UP', `n', `n')
option(`CONFIG_FEATURE_SUID', `n', `n')
option(`CONFIG_FEATURE_SUID_CONFIG', `n', `n')
option(`CONFIG_SELINUX', `n', `n')

#
# Build Options
#
option(`CONFIG_STATIC', `n', `n')
option(`CONFIG_LFS', `n', `y')
# USING_CROSS_COMPILER is not set
EXTRA_CFLAGS_OPTIONS=""
option(`CONFIG_AUTH_IN_VAR_ETC', `n', `y')

#
# Installation Options
#
option(`CONFIG_INSTALL_NO_USR', `y', `y')
PREFIX=""

#
# Archival Utilities
#
option(`CONFIG_AR', `n', `n')
option(`CONFIG_BUNZIP2', `n', `n')
option(`CONFIG_CPIO', `n', `n')
option(`CONFIG_DPKG', `n', `n')
option(`CONFIG_DPKG_DEB', `n', `n')
option(`CONFIG_GUNZIP', `y', `y')
option(`CONFIG_FEATURE_GUNZIP_UNCOMPRESS', `n', `n')
option(`CONFIG_GZIP', `y', `y')
option(`CONFIG_RPM2CPIO', `n', `n')
option(`CONFIG_RPM', `n', `n')
option(`CONFIG_TAR', `y', `y')
option(`CONFIG_FEATURE_TAR_CREATE', `y', `y')
option(`CONFIG_FEATURE_TAR_BZIP2', `n', `n')
option(`CONFIG_FEATURE_TAR_FROM', `n', `n')
option(`CONFIG_FEATURE_TAR_GZIP', `y', `y')
option(`CONFIG_FEATURE_TAR_COMPRESS', `n', `n')
option(`CONFIG_FEATURE_TAR_OLDGNU_COMPATABILITY', `n', `n')
option(`CONFIG_FEATURE_TAR_GNU_EXTENSIONS', `y', `y')
option(`CONFIG_FEATURE_TAR_LONG_OPTIONS', `n', `n')
option(`CONFIG_UNCOMPRESS', `n', `n')
option(`CONFIG_UNZIP', `n', `n')

#
# Common options for cpio and tar
#
option(`CONFIG_FEATURE_UNARCHIVE_TAPE', `n', `n')

#
# Coreutils
#
option(`CONFIG_BASENAME', `y', `y')
option(`CONFIG_CAL', `n', `n')
option(`CONFIG_CAT', `y', `y')
option(`CONFIG_CHGRP', `y', `n')
option(`CONFIG_CHMOD', `y', `y')
option(`CONFIG_CHOWN', `y', `n')
option(`CONFIG_CHROOT', `y', `n')
option(`CONFIG_CMP', `n', `n')
option(`CONFIG_CP', `y', `y')
option(`CONFIG_CUT', `y', `y')
option(`CONFIG_DATE', `y', `y')
option(`CONFIG_FEATURE_DATE_ISOFMT', `y', `y')
option(`CONFIG_DD', `y', `n')
option(`CONFIG_DF', `y', `y')
option(`CONFIG_DIRNAME', `y', `y')
option(`CONFIG_DOS2UNIX', `n', `y')
option(`CONFIG_DU', `y', `y')
option(`CONFIG_FEATURE_DU_DEFALT_BLOCKSIZE_1K', `n', `y')
option(`CONFIG_ECHO', `y', `y')
option(`CONFIG_FEATURE_FANCY_ECHO', `y', `y')
option(`CONFIG_ENV', `y', `y')
option(`CONFIG_EXPR', `y', `y')
option(`CONFIG_FALSE', `y', `y')
option(`CONFIG_FOLD', `n', `n')
option(`CONFIG_HEAD', `y', `y')
option(`CONFIG_FEATURE_FANCY_HEAD', `n', `n')
option(`CONFIG_HOSTID', `n', `n')
option(`CONFIG_ID', `y', `y')
option(`CONFIG_INSTALL', `n', `n')
option(`CONFIG_LENGTH', `n', `n')
option(`CONFIG_LN', `y', `y')
option(`CONFIG_LOGNAME', `n', `n')
option(`CONFIG_LS', `y', `y')
option(`CONFIG_FEATURE_LS_FILETYPES', `y', `y')
option(`CONFIG_FEATURE_LS_FOLLOWLINKS', `y', `y')
option(`CONFIG_FEATURE_LS_RECURSIVE', `n', `y')
option(`CONFIG_FEATURE_LS_SORTFILES', `y', `y')
option(`CONFIG_FEATURE_LS_TIMESTAMPS', `y', `y')
option(`CONFIG_FEATURE_LS_USERNAME', `y', `y')
option(`CONFIG_FEATURE_LS_COLOR', `y', `y')
option(`CONFIG_MD5SUM', `n', `n')
option(`CONFIG_MKDIR', `y', `y')
option(`CONFIG_MKFIFO', `n', `n')
option(`CONFIG_MKNOD', `y', `y')
option(`CONFIG_MV', `y', `y')
option(`CONFIG_OD', `n', `n')
option(`CONFIG_PRINTF', `n', `n')
option(`CONFIG_PWD', `y', `y')
option(`CONFIG_REALPATH', `n', `n')
option(`CONFIG_RM', `y', `y')
option(`CONFIG_RMDIR', `y', `y')
option(`CONFIG_SEQ', `n', `n')
option(`CONFIG_SHA1SUM', `n', `n')
option(`CONFIG_SLEEP', `y', `y')
option(`CONFIG_FEATURE_FANCY_SLEEP', `n', `n')
option(`CONFIG_SORT', `y', `y')
option(`CONFIG_STTY', `n', `n')
option(`CONFIG_SYNC', `n', `y')
option(`CONFIG_TAIL', `y', `y')
option(`CONFIG_FEATURE_FANCY_TAIL', `n', `y')
option(`CONFIG_TEE', `n', `n')
option(`CONFIG_TEST', `y', `y')

#
# test (forced enabled for use with shell)
#
option(`CONFIG_FEATURE_TEST_64', `n', `n')
option(`CONFIG_TOUCH', `y', `y')
option(`CONFIG_TR', `n', `n')
option(`CONFIG_TRUE', `y', `y')
option(`CONFIG_TTY', `y', `y')
option(`CONFIG_UNAME', `y', `y')
option(`CONFIG_UNIQ', `y', `y')
option(`CONFIG_USLEEP', `n', `n')
option(`CONFIG_UUDECODE', `n', `n')
option(`CONFIG_UUENCODE', `n', `n')
option(`CONFIG_WATCH', `n', `n')
option(`CONFIG_WC', `n', `n')
option(`CONFIG_WHO', `n', `n')
option(`CONFIG_WHOAMI', `y', `y')
option(`CONFIG_YES', `y', `y')

#
# Common options for cp and mv
#
option(`CONFIG_FEATURE_PRESERVE_HARDLINKS', `n', `n')

#
# Common options for ls and more
#
option(`CONFIG_FEATURE_AUTOWIDTH', `y', `y')

#
# Common options for df, du, ls
#
option(`CONFIG_FEATURE_HUMAN_READABLE', `y', `y')

#
# Console Utilities
#
option(`CONFIG_CHVT', `n', `n')
option(`CONFIG_CLEAR', `y', `y')
option(`CONFIG_DEALLOCVT', `n', `n')
option(`CONFIG_DUMPKMAP', `n', `n')
option(`CONFIG_LOADFONT', `n', `n')
option(`CONFIG_LOADKMAP', `n', `y')
option(`CONFIG_OPENVT', `n', `n')
option(`CONFIG_RESET', `y', `y')
option(`CONFIG_SETKEYCODES', `n', `n')

#
# Debian Utilities
#
option(`CONFIG_MKTEMP', `n', `n')
option(`CONFIG_PIPE_PROGRESS', `n', `n')
option(`CONFIG_READLINK', `n', `n')
option(`CONFIG_RUN_PARTS', `n', `n')
option(`CONFIG_START_STOP_DAEMON', `n', `n')
option(`CONFIG_WHICH', `n', `n')

#
# Editors
#
option(`CONFIG_AWK', `n', `n')
option(`CONFIG_PATCH', `n', `n')
option(`CONFIG_SED', `y', `y')
option(`CONFIG_VI', `y', `y')
option(`CONFIG_FEATURE_VI_COLON', `y', `y')
option(`CONFIG_FEATURE_VI_YANKMARK', `y', `y')
option(`CONFIG_FEATURE_VI_SEARCH', `y', `y')
option(`CONFIG_FEATURE_VI_USE_SIGNALS', `y', `y')
option(`CONFIG_FEATURE_VI_DOT_CMD', `y', `y')
option(`CONFIG_FEATURE_VI_READONLY', `y', `y')
option(`CONFIG_FEATURE_VI_SETOPTS', `y', `y')
option(`CONFIG_FEATURE_VI_SET', `y', `y')
option(`CONFIG_FEATURE_VI_WIN_RESIZE', `y', `y')
option(`CONFIG_FEATURE_VI_OPTIMIZE_CURSOR', `y', `y')

#
# Finding Utilities
#
option(`CONFIG_FIND', `y', `y')
option(`CONFIG_FEATURE_FIND_MTIME', `n', `y')
option(`CONFIG_FEATURE_FIND_PERM', `n', `n')
option(`CONFIG_FEATURE_FIND_TYPE', `y', `y')
option(`CONFIG_FEATURE_FIND_XDEV', `n', `n')
option(`CONFIG_FEATURE_FIND_NEWER', `n', `n')
option(`CONFIG_FEATURE_FIND_INUM', `n', `n')
option(`CONFIG_GREP', `y', `y')
option(`CONFIG_FEATURE_GREP_EGREP_ALIAS', `n', `n')
option(`CONFIG_FEATURE_GREP_FGREP_ALIAS', `n', `n')
option(`CONFIG_FEATURE_GREP_CONTEXT', `n', `n')
option(`CONFIG_XARGS', `y', `y')
option(`CONFIG_FEATURE_XARGS_SUPPORT_CONFIRMATION', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_QUOTES', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_TERMOPT', `n', `n')
option(`CONFIG_FEATURE_XARGS_SUPPORT_ZERO_TERM', `n', `n')

#
# Init Utilities
#
option(`CONFIG_INIT', `y', `y')
option(`CONFIG_FEATURE_USE_INITTAB', `y', `y')
option(`CONFIG_FEATURE_INITRD', `n', `n')
option(`CONFIG_FEATURE_INIT_COREDUMPS', `n', `n')
option(`CONFIG_FEATURE_INIT_SWAPON', `n', `n')
option(`CONFIG_FEATURE_EXTRA_QUIET', `n', `n')
option(`CONFIG_HALT', `y', `y')
option(`CONFIG_POWEROFF', `n', `y')
option(`CONFIG_REBOOT', `y', `y')
option(`CONFIG_MESG', `n', `n')

#
# Login/Password Management Utilities
#
option(`CONFIG_USE_BB_PWD_GRP', `n', `n')
option(`CONFIG_ADDGROUP', `n', `n')
option(`CONFIG_DELGROUP', `n', `n')
option(`CONFIG_ADDUSER', `n', `n')
option(`CONFIG_DELUSER', `n', `n')
option(`CONFIG_GETTY', `n', `n')
option(`CONFIG_FEATURE_UTMP', `n', `n')
option(`CONFIG_FEATURE_WTMP', `n', `n')
option(`CONFIG_LOGIN', `y', `y')
option(`CONFIG_FEATURE_SECURETTY', `n', `n')
option(`CONFIG_PASSWD', `y', `y')
option(`CONFIG_SU', `n', `n')
option(`CONFIG_SULOGIN', `n', `n')
option(`CONFIG_VLOCK', `n', `n')

#
# Common options for adduser, deluser, login, su
#
option(`CONFIG_FEATURE_SHADOWPASSWDS', `y', `n')

#
# Miscellaneous Utilities
#
option(`CONFIG_ADJTIMEX', `n', `n')
option(`CONFIG_CROND', `n', `n')
option(`CONFIG_CRONTAB', `n', `n')
option(`CONFIG_DC', `n', `n')
option(`CONFIG_DEVFSD', `n', `n')
option(`CONFIG_LAST', `n', `n')
option(`CONFIG_HDPARM', `n', `n')
option(`CONFIG_MAKEDEVS', `n', `n')
option(`CONFIG_MT', `n', `n')
option(`CONFIG_RX', `n', `n')
option(`CONFIG_STRINGS', `n', `n')
option(`CONFIG_TIME', `n', `n')
option(`CONFIG_WATCHDOG', `n', `n')

#
# Linux Module Utilities
#
option(`CONFIG_INSMOD', `n', `y')
option(`CONFIG_FEATURE_2_4_MODULES', `n', `y')
option(`CONFIG_FEATURE_2_6_MODULES', `n', `n')
option(`CONFIG_FEATURE_INSMOD_VERSION_CHECKING', `n', `y')
option(`CONFIG_FEATURE_INSMOD_KSYMOOPS_SYMBOLS', `n', `n')
option(`CONFIG_FEATURE_INSMOD_LOADINKMEM', `n', `n')
option(`CONFIG_FEATURE_INSMOD_LOAD_MAP', `n', `n')
option(`CONFIG_LSMOD', `n', `y')
option(`CONFIG_MODPROBE', `n', `n')
option(`CONFIG_RMMOD', `n', `y')
option(`CONFIG_FEATURE_CHECK_TAINTED_MODULE', `n', `n')

#
# Networking Utilities
#
option(`CONFIG_FEATURE_IPV6', `n', `n')
option(`CONFIG_ARPING', `n', `n')
option(`CONFIG_FTPGET', `n', `n')
option(`CONFIG_FTPPUT', `n', `n')
option(`CONFIG_HOSTNAME', `y', `y')
option(`CONFIG_HTTPD', `n', `n')
option(`CONFIG_IFCONFIG', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_STATUS', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_SLIP', `n', `n')
option(`CONFIG_FEATURE_IFCONFIG_MEMSTART_IOADDR_IRQ', `n', `n')
option(`CONFIG_FEATURE_IFCONFIG_HW', `n', `y')
option(`CONFIG_FEATURE_IFCONFIG_BROADCAST_PLUS', `n', `y')
option(`CONFIG_IFUPDOWN', `y', `y')
option(`CONFIG_FEATURE_IFUPDOWN_IP', `y', `n')
option(`CONFIG_FEATURE_IFUPDOWN_IP_BUILTIN', `y', `y')
option(`CONFIG_FEATURE_IFUPDOWN_IPV4', `y', `y')
option(`CONFIG_FEATURE_IFUPDOWN_IPV6', `n', `n')
option(`CONFIG_FEATURE_IFUPDOWN_IPX', `n', `n')
option(`CONFIG_FEATURE_IFUPDOWN_MAPPING', `n', `n')
option(`CONFIG_INETD', `y', `y')
option(`CONFIG_FEATURE_INETD_SUPPORT_BILTIN_ECHO', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BILTIN_DISCARD', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BILTIN_TIME', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BILTIN_DAYTIME', `n', `n')
option(`CONFIG_FEATURE_INETD_SUPPORT_BILTIN_CHARGEN', `n', `n')
option(`CONFIG_IP', `y', `y')
option(`CONFIG_FEATURE_IP_ADDRESS', `y', `y')
option(`CONFIG_FEATURE_IP_LINK', `y', `y')
option(`CONFIG_FEATURE_IP_ROUTE', `y', `y')
option(`CONFIG_FEATURE_IP_TUNNEL', `y', `n')
option(`CONFIG_IPCALC', `n', `n')
option(`CONFIG_IPADDR', `n', `n')
option(`CONFIG_IPLINK', `n', `n')
option(`CONFIG_IPROUTE', `n', `n')
option(`CONFIG_IPTUNNEL', `n', `n')
option(`CONFIG_NAMEIF', `n', `n')
option(`CONFIG_NC', `n', `n')
option(`CONFIG_NETSTAT', `n', `n')
option(`CONFIG_NSLOOKUP', `n', `y')
option(`CONFIG_PING', `y', `y')
option(`CONFIG_FEATURE_FANCY_PING', `n', `y')
option(`CONFIG_PING6', `n', `n')
option(`CONFIG_ROUTE', `n', `y')
option(`CONFIG_TELNET', `n', `y')
option(`CONFIG_FEATURE_TELNET_TTYPE', `n', `y')
option(`CONFIG_FEATURE_TELNET_AUTOLOGIN', `n', `n')
option(`CONFIG_TELNETD', `y', `y')
option(`CONFIG_FEATURE_TELNETD_INETD', `y', `y')
option(`CONFIG_TFTP', `n', `n')
option(`CONFIG_TRACEROUTE', `n', `n')
option(`CONFIG_VCONFIG', `n', `n')
option(`CONFIG_WGET', `y', `y')
option(`CONFIG_FEATURE_WGET_STATUSBAR', `y', `y')
option(`CONFIG_FEATURE_WGET_AUTHENTICATION', `n', `y')
option(`CONFIG_FEATURE_WGET_IP6_LITERAL', `n', `n')

#
# udhcp Server/Client
#
option(`CONFIG_UDHCPD', `n', `n')
option(`CONFIG_UDHCPC', `y', `y')
option(`CONFIG_FEATURE_UDHCP_SYSLOG', `n', `n')
option(`CONFIG_FEATURE_UDHCP_DEBUG', `n', `n')

#
# Process Utilities
#
option(`CONFIG_FREE', `y', `y')
option(`CONFIG_KILL', `y', `y')
option(`CONFIG_KILLALL', `y', `y')
option(`CONFIG_PIDOF', `y', `y')
option(`CONFIG_PS', `y', `y')
option(`CONFIG_RENICE', `n', `n')
option(`CONFIG_TOP', `n', `n')
option(`CONFIG_UPTIME', `y', `y')
option(`CONFIG_SYSCTL', `n', `n')

#
# Another Bourne-like Shell
#
option(`CONFIG_FEATURE_SH_IS_ASH', `y', `y')
option(`CONFIG_FEATURE_SH_IS_HUSH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_LASH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_MSH', `n', `n')
option(`CONFIG_FEATURE_SH_IS_NONE', `n', `n')
option(`CONFIG_ASH', `y', `y')

#
# Ash Shell Options
#
option(`CONFIG_ASH_JOB_CONTROL', `y', `y')
option(`CONFIG_ASH_ALIAS', `y', `y')
option(`CONFIG_ASH_MATH_SUPPORT', `n', `n')
option(`CONFIG_ASH_MATH_SUPPORT_64', `n', `n')
option(`CONFIG_ASH_GETOPTS', `n', `n')
option(`CONFIG_ASH_CMDCMD', `n', `n')
option(`CONFIG_ASH_MAIL', `n', `n')
option(`CONFIG_ASH_OPTIMIZE_FOR_SIZE', `y', `y')
option(`CONFIG_ASH_RANDOM_SUPPORT', `n', `n')
option(`CONFIG_HUSH', `n', `n')
option(`CONFIG_LASH', `n', `n')
option(`CONFIG_MSH', `n', `n')

#
# Bourne Shell Options
#
option(`CONFIG_FEATURE_SH_EXTRA_QUIET', `n', `n')
option(`CONFIG_FEATURE_SH_STANDALONE_SHELL', `n', `n')
option(`CONFIG_FEATURE_COMMAND_EDITING', `y', `y')
CONFIG_FEATURE_COMMAND_HISTORY=15
option(`CONFIG_FEATURE_COMMAND_SAVEHISTORY', `n', `n')
option(`CONFIG_FEATURE_COMMAND_TAB_COMPLETION', `y', `y')
option(`CONFIG_FEATURE_COMMAND_USERNAME_COMPLETION', `n', `n')
option(`CONFIG_FEATURE_SH_FANCY_PROMPT', `n', `y')

#
# System Logging Utilities
#
option(`CONFIG_SYSLOGD', `n', `n')
option(`CONFIG_FEATURE_ROTATE_LOGFILE', `n', `n')
option(`CONFIG_FEATURE_REMOTE_LOG', `n', `n')
option(`CONFIG_FEATURE_IPC_SYSLOG', `n', `n')
option(`CONFIG_KLOGD', `n', `n')
option(`CONFIG_LOGGER', `n', `n')

#
# Linux System Utilities
#
option(`CONFIG_DMESG', `y', `y')
option(`CONFIG_FBSET', `n', `n')
option(`CONFIG_FDFLUSH', `n', `n')
option(`CONFIG_FDFORMAT', `n', `n')
option(`CONFIG_FDISK', `n', `n')
option(`CONFIG_FREERAMDISK', `n', `n')
option(`CONFIG_FSCK_MINIX', `n', `n')
option(`CONFIG_MKFS_MINIX', `n', `n')
option(`CONFIG_GETOPT', `n', `n')
option(`CONFIG_HEXDUMP', `n', `n')
option(`CONFIG_HWCLOCK', `n', `n')
option(`CONFIG_LOSETUP', `n', `n')
option(`CONFIG_MKSWAP', `n', `n')
option(`CONFIG_MORE', `y', `y')
option(`CONFIG_FEATURE_USE_TERMIOS', `y', `y')
option(`CONFIG_PIVOT_ROOT', `n', `n')
option(`CONFIG_RDATE', `n', `y')
option(`CONFIG_SWAPONOFF', `n', `n')
option(`CONFIG_MOUNT', `y', `y')
option(`CONFIG_NFSMOUNT', `y', `y')
option(`CONFIG_UMOUNT', `y', `y')
option(`CONFIG_FEATURE_MOUNT_FORCE',`n',`y')

#
# Common options for mount/umount
#
option(`CONFIG_FEATURE_MOUNT_LOOP', `y', `y')
option(`CONFIG_FEATURE_MTAB_SUPPORT', `n', `n')

#
# Debugging Options
#
option(`CONFIG_DEBUG', `n', `n')
