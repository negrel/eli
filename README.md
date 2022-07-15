# Eli - Linux distribution management made easy

## Dependencies

Eli relies on the following commands:
- `bash`: GNU Bourne Again SHell.
- `jq`: Command-line JSON processor.
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

## Known limitations

- File size can't exceed your tmpfs size

## :stars: Show your support

Please give a :star: if this project helped you!

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)
