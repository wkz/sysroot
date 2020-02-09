sysroot
=======

A very small sysroot containing a Linux kernel with the associated
headers and busybox. The kernel is tailored to only run under QEMU,
booting from a 9P root filesystem.

The intended use-case is to test software that:

- ...requires superuser privileges.
- ...runs on multiple architectures.
- ...could potentially cause a kernel panic.

It requires a crosstool-ng based toolchain and supports the following
architectures:

- `arm`
- `aarch64`
- `powerpc`
- `x86_64`

Compatible toolchains can be found here:
https://github.com/myrootfs/crosstool-ng
