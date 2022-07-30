# `archlinux` - Minimal ArchLinux image

This directory contains materials used to build the `eli/archlinux` image.

> **NOTE**: The `Containerfile` contains line by line comments and can serve as
> documentation.

## `pre-install` hooks

The following `pre-install` hooks are available with the default `eli/archlinux`
image:

- [`fstab`](../../docs/pre-install-hooks.md#fstab)
- [`hostname`](../../docs/pre-install-hooks.md#hostname)
- [`keymap`](../../docs/pre-install-hooks.md#keymap)
- [`locale`](../../docs/pre-install-hooks.md#locale)
- [`mkswap`](../../docs/pre-install-hooks.md#mkswap)
- [`root_passwd`](../../docs/pre-install-hooks.md#root_passwd)
- [`timezone`](../../docs/pre-install-hooks.md#timezone)
- [`tmpfs`](../../docs/pre-install-hooks.md#tmpfs)
- [`ucode`](#ucode---intelamd-microcode-update-image)

### `ucode` - Intel/AMD microcode update image

|  Option name  | Default value |           Description            |
| :-----------: | :-----------: | :------------------------------: |
| `INTEL_UCODE` |      ``       | Must be `y` to keep Intel ucode. |
|  `AMD_UCODE`  |      ``       |  Must be `y` to keep AMD ucode.  |
