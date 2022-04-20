# `eli_scripts/`

This directory contains scripts that **MUST** be present in the image to install (at path `/eli/scripts/`).
You may replace those file by custom one while conserving a similar behavior.

## `install` script

This script is used to install an OCI/Docker image on disk.

The script **MAY** support the following environment variable:

| Environment variable name | Description |
|:------------------------- | :---------- |
| `ELI_ROOTFS_DEVICE` | Path to device that will contain the root filesystem |
| `ELI_BOOTLOADER_DEVICE` | Path to device that will contain the bootloader |
| `ELI_BOOTLOADER_ARCH` | Bootloader target architecture hint |
| `ELI_BOOTLOADER_ID` | EFI bootloader ID |

## `install-iso`

This script is used to generate/install an ISO from an OCI/Docker image.

The script **MAY** support the following environment variable:


| Environment variable name | Description |
|:------------------------- | :---------- |
| `ELI_VOLUME_ID` | ISO volume ID |
| `ELI_PERSISTENT_PART` | Add a persistent partition to the ISO if it's a block device. |

## `set_env`

This script is used to set environment variable present in the image globally.
Exactly one environment variable is passed as argument to this script.
