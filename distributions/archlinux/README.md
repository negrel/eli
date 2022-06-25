# `archlinux` - Minimal ArchLinux image

This directory contains materials used to build the `eli/archlinux` image.

| Build argument     | Default value  | Description                                       |
| :----------------- | :------------: | :------------------------------------------------ |
| `TZ`               | `Europe/Paris` | System time zone setting                          |
| `KEYMAP`           | `fr`           | Keyboard layout                                   |
| `ROOT_PASSWD`      | ``             | Encrypted `root` password (`*` to disable login)  |
| `ELI_INTEL_UCODE`  | `y`            | Intel CPU microcode                               |
| `ELI_AMD_UCODE`    | `y`            | AMD CPU microcode                                 |
| `TMPFS_SIZE`       | `100%`         | size of /tmp (and rootfs if an overlayfs is used) |

> **NOTE**: The `Containerfile` contains line by line comments and can serve as documentation.
