# `ubuntu` - Minimal Ubuntu images

This directory contains materials used to build the `eli/ubuntu` images and more sophisticated derived.

| Build argument     | Default value  | Description                                      |
| :----------------- | :------------: | :----------------------------------------------- |
| `KVER`               | `5.13.0-37` | Kernel version to use                         |
| `TZ`               | `Europe/Paris` | System time zone setting                         |
| `KEYMAP`           | `fr`           | Keyboard layout                                  |
| `ROOT_PASSWD`      | ``             | Encrypted `root` password (`*` to disable login) |
| `ELI_INTEL_UCODE`  | `y`            | Intel CPU microcode                              |
| `ELI_AMD_UCODE`    | `y`            | AMD CPU microcode                                |

> **NOTE**: The `Containerfile` contains line by line comments and can serve as documentation.
