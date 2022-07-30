# `pre-install` hooks

This file contains the documentation about common `pre-install` hooks.

## `fstab`

> **NOTE**: This option is disabled in ISO installation.

|   Option name    | Default value |                                 Description                                 |
| :--------------: | :-----------: | :-------------------------------------------------------------------------: |
| `FSTAB_EXT_FILE` |      ``       | Path to an fstab extension file, the file will be appended to `/etc/fstab`. |

## `hostname`

| Option name | Default value  |                        Description                        |
| :---------: | :------------: | :-------------------------------------------------------: |
| `HOSTNAME`  | `$ELI_DISTRIB` | An hostname, the value will be written to `/etc/hostname` |

> **NOTE**: An entry will also be added to /etc/hosts

## `keymap`

| Option name | Default value |                         Description                          |
| :---------: | :-----------: | :----------------------------------------------------------: |
|  `KEYMAP`   |     `en`      | A keymap, the value will be written to `/etc/vconsole.conf`. |

## `locale`

| Option name |    Default value    |                                                 Description                                                  |
| :---------: | :-----------------: | :----------------------------------------------------------------------------------------------------------: |
|  `LOCALE`   | `en_US.UTF-8 UTF-8` | Locale settings to use, the value will be written to `/etc/locale.gen` before generating `/etc/locale.conf`. |

## `mkswap`

|  Option name  | Default value |    Description    |
| :-----------: | :-----------: | :---------------: |
| `SWAP_DEVICE` |      ``       | Path to a device. |

## `root_passwd`

|  Option name  | Default value |           Description           |
| :-----------: | :-----------: | :-----------------------------: |
| `ROOT_PASSWD` |      ``       | Encrypted root password to use. |

> **NOTE**: You can generate an encrypted password with
> `mkpasswd -m sha-512 <my_passwd>`

## `timezone`

| Option name | Default value |     Description      |
| :---------: | :-----------: | :------------------: |
|    `TZ`     |   `Etc/UTC`   | The timezone to use. |

> **NOTE**: The list of timezone is available under `/usr/share/zoneinfo/`.

## `tmpfs`

|   Option name    | Default value |         Description          |
| :--------------: | :-----------: | :--------------------------: |
| `TMPFS_TMP_SIZE` |    `100%`     | Maximum size of `/tmp` tmpfs |
| `TMPFS_RUN_SIZE` |    `100%`     | Maximum size of `/run` tmpfs |

The default size is 100% of the RAM. On most distribution, the default values
are 50%, `eli` increases it because of `tmpfs` this limitation:

> A single file size can't exceed the size of your physical RAM.

`eli` uses `/run` for the upper layer of the `overlayfs`.
