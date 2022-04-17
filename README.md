# Eli - Linux distribution management made easy

## Dependencies

Eli relies on the following commands:
- `bash`: GNU Bourne Again SHell.
- `buildah`: A tool that facilitates building OCI images.

### Kernel modules

- `loop`: to setup loopback device while generating Grub EFI boot image.

## Installation

To install eli, just clone the repository and create a `cmd/eli` symlink.

```shell
$ git clone https://github.com/negrel/eli.git

# Symlink to /usr/local/bin
ln -s `pwd`/cmd/eli /usr/local/bin/eli
```

## Update

It's simple as pulling from the master branch:

```shell
$ git pull origin master
```

## TODO

- [ ] Write help menu
- [ ] Write man pages
- [ ] Permanent partition on ISO installation
- [ ] Host installation (no ISO) in /boot/eli/<image>
- [ ] Provide example of full installation.
- [ ] Run eli.sh in container by default so we only depends on `buildah`
  - Provide CPU quota, memory limit and more (installation is CPU intensive)
- [ ] Ensure there is enough space on target device before starting installation
- [ ] Add dependency check (container and host) before starting installation
- [ ] Add support for SHELL instruction