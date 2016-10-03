SUBDIRS = swtpm-utils dracut .

if FEDORA17
plymouthdir=/usr/lib/dracut/modules.d/90crypt-tpm
dist_plymouth_SCRIPTS=dracut/Fedora17/crypt-tpm/cryptroot-ask.sh \
		      dracut/Fedora17/crypt-tpm/cryptroot-ask-tpm.sh \
		      dracut/Fedora17/crypt-tpm/crypt-cleanup.sh \
		      dracut/Fedora17/crypt-tpm/crypt-lib.sh \
		      dracut/Fedora17/crypt-tpm/module-setup.sh \
		      dracut/Fedora17/crypt-tpm/parse-crypt.sh \
		      dracut/Fedora17/crypt-tpm/parse-keydev.sh \
		      dracut/Fedora17/crypt-tpm/probe-keydev.sh \
		      dracut/Fedora17/crypt-tpm/tpm-try-authless-indexes.sh

yumpluginconfdir=/etc/yum/pluginconf.d
dist_yumpluginconf_SCRIPTS=yum/post-transaction-actions.conf

yumpluginsdir=/usr/lib/yum-plugins
dist_yumplugins_SCRIPTS=yum/post-transaction-actions.py

yumpostactionsdir=/etc/yum/post-actions
dist_yumpostactions_SCRIPTS=yum/tpm-luks.action
endif

if RHEL6
plymouthdir=/usr/share/dracut/modules.d/50plymouth-tpm
dist_plymouth_SCRIPTS=dracut/RHEL6/plymouth-tpm/install \
		      dracut/RHEL6/plymouth-tpm/check \
		      dracut/RHEL6/plymouth-tpm/plymouth-newroot.sh \
		      dracut/RHEL6/plymouth-tpm/cryptroot-ask.sh \
		      dracut/RHEL6/plymouth-tpm/installkernel \
		      dracut/RHEL6/plymouth-tpm/plymouth-populate-initrd \
		      dracut/RHEL6/plymouth-tpm/cryptroot-ask-tpm.sh \
		      dracut/RHEL6/plymouth-tpm/cryptroot-dontask-tpm.sh \
		      dracut/RHEL6/plymouth-tpm/plymouth-emergency.sh \
		      dracut/RHEL6/plymouth-tpm/plymouth-pretrigger.sh \
		      dracut/RHEL6/create-plain-key.sh

yumpluginconfdir=/etc/yum/pluginconf.d
dist_yumpluginconf_SCRIPTS=yum/post-transaction-actions.conf

yumpluginsdir=/usr/lib/yum-plugins
dist_yumplugins_SCRIPTS=yum/post-transaction-actions.py

yumpostactionsdir=/etc/yum/post-actions
dist_yumpostactions_SCRIPTS=yum/tpm-luks.action
endif

if UBUNTU14
plymouth_hooksdir=/etc/initramfs-tools/hooks
plymouthdir=/etc/initramfs-tools/scripts/local-top
plymouth_extradir=/usr/share/tpm-luks
dist_plymouth_hooks_SCRIPTS=initramfs-tools/Ubuntu14.04/hooks/cryptroot
dist_plymouth_SCRIPTS=initramfs-tools/Ubuntu14.04/scripts/local-top/cryptroot
dist_plymouth_extra_SCRIPTS=initramfs-tools/cryptroot-ask-tpm.sh \
			    initramfs-tools/cryptroot-dontask-tpm.sh \
			    initramfs-tools/create-plain-key.sh

# IRT@Nexor - Update this path to '/etc/kernel/postinst.d' once Debian-style kernel updates are working properly..
aptkernelpostactionsdir=/usr/share/tpm-luks
dist_aptkernelpostactions_SCRIPTS=apt/zzz-tpm-luks-update
endif

dist_sbin_SCRIPTS=tpm-luks/tpm-luks-chain-hashes \
	     tpm-luks/tpm-luks \
	     tpm-luks/tpm-luks-gen-tgrub2-pcr-values \
	     tpm-luks/tpm-luks-update \
	     tpm-luks/tpm-luks-init

confdir=/etc
conf_SCRIPTS=tpm-luks.conf

CLEANFILES = yum/tpm-luks.action tpm-luks.conf apt/zzz-tpm-luks-update

yum/tpm-luks.action: yum/tpm-luks.action.in
	@SED@ -e s!\@sbindir\@!"@sbindir@"!g < $< > $@-t
	mv $@-t $@

apt/zzz-tpm-luks-update: apt/zzz-tpm-luks-update.in
	@SED@ -e s!\@sbindir\@!"@sbindir@"!g < $< > $@-t
	mv $@-t $@

EXTRA_DIST = tpm-luks.conf.in yum/tpm-luks.action.in apt/zzz-tpm-luks-update.in

tpm-luks.conf: tpm-luks.conf.in
	@SED@ -e s!\@sbindir\@!"@sbindir@"!g < $< > $@-t
	mv $@-t $@

install-exec-hook:
	if test ! -e ${DESTDIR}/etc/tpm-luks.conf; then cp tpm-luks.conf ${DESTDIR}/etc; fi

