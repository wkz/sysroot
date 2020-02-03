kernel-ver := 5.5.1
kernel-maj := $(word 1,$(subst ., ,$(kernel-ver)))
kernel-dir := linux-$(kernel-ver)
kernel-tar := $(kernel-dir).tar.xz
kernel-url := https://cdn.kernel.org/pub/linux/kernel/v$(kernel-maj).x/$(kernel-tar)

busybox-ver := 1.31.1
busybox-dir := busybox-$(busybox-ver)
busybox-tar := $(busybox-dir).tar.bz2
busybox-url := https://www.busybox.net/downloads/$(busybox-tar)

$(kernel-dir)/Makefile: $(kernel-tar)
	tar maxf $<
$(kernel-tar):
	wget -q $(kernel-url)

$(busybox-dir)/Makefile: $(busybox-tar)
	tar maxf $<
$(busybox-tar):
	wget -q $(busybox-url)

