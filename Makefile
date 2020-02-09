kernel-ver := 5.5.1
kernel-maj := $(word 1,$(subst ., ,$(kernel-ver)))
kernel-dir := linux-$(kernel-ver)
kernel-tar := $(kernel-dir).tar.xz
kernel-url := https://cdn.kernel.org/pub/linux/kernel/v$(kernel-maj).x/$(kernel-tar)

busybox-ver := 1.31.1
busybox-dir := busybox-$(busybox-ver)
busybox-tar := $(busybox-dir).tar.bz2
busybox-url := https://www.busybox.net/downloads/$(busybox-tar)

sysroot := sysroot-$(kernel-ver)

tc = $(1)-unknown-linux-gnu$(if $(filter $(1),arm),eabi,)
karch = $(if $(filter $(1),aarch64),arm64,$(1))
kbuild = $(MAKE) CROSS_COMPILE=$(call tc,$(2))- ARCH=$(call karch,$(2)) O=../$(3) \
		-C $(1) $(4)

%-$(sysroot).tar.xz: %-$(sysroot)/init
	tar cJf $@ $(dir $<)

%-$(sysroot)/init: \
			skel/init \
			%-$(sysroot)/usr/include/linux/version.h \
			%-$(sysroot)/boot/vmlinuz-$(kernel-ver) \
			%-$(sysroot)/bin/busybox
	$(call tc,$*)-populate -m -s skel/ -d $*-$(sysroot)/ -l c:m

%-$(sysroot)/usr/include/linux/version.h: %-kernel-obj/vmlinux |%-$(sysroot)/usr
	+$(call kbuild,$(kernel-dir),$*,$(dir $<),INSTALL_HDR_PATH=$(CURDIR)/$*-$(sysroot)/usr headers_install)

%-$(sysroot)/boot/vmlinuz-$(kernel-ver): %-kernel-obj/vmlinux |%-$(sysroot)/boot
	+$(call kbuild,$(kernel-dir),$*,$(dir $<),INSTALL_PATH=$(CURDIR)/$(dir $@) install)

%-kernel-menuconfig: $(kernel-dir)/Makefile |%-kernel-obj
	$(call kbuild,$(kernel-dir),$*,$|,menuconfig)

%-kernel-obj/vmlinux: %-kernel-obj/.config |%-kernel-obj
	+$(call kbuild,$(kernel-dir),$*,$|)

%-kernel-obj/.config: %-kernel.config $(kernel-dir)/Makefile |%-kernel-obj
	cp $< $@

$(kernel-dir)/Makefile: $(kernel-tar)
	tar maxf $<
$(kernel-tar):
	wget -q $(kernel-url)


%-$(sysroot)/bin/busybox: %-busybox-obj/busybox |%-$(sysroot)
	+$(call kbuild,$(busybox-dir),$*,$(dir $<),install) && \
		cp -a $(dir $<)/_install/* $*-$(sysroot)/

%-busybox-menuconfig: $(busybox-dir)/Makefile |%-busybox-obj
	$(call kbuild,$(busybox-dir),$*,$|,menuconfig)

%-busybox-obj/busybox: %-busybox-obj/.config |%-busybox-obj
	+$(call kbuild,$(busybox-dir),$*,$|)

%-busybox-obj/.config: busybox.config $(busybox-dir)/Makefile |%-busybox-obj
	cp $< $@

$(busybox-dir)/Makefile: $(busybox-tar)
	tar maxf $<
$(busybox-tar):
	wget -q $(busybox-url)


%-$(sysroot) %-$(sysroot)/boot %-$(sysroot)/usr %-kernel-obj %-busybox-obj:
	mkdir -p $@

.SECONDARY:
