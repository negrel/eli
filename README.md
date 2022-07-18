# Eli - Bare metal installables OCI/Docker images.

> Eli is a set of OCI/Docker images that you can install on bare metal using `eli` cli tool.

## Installation

To install `eli`, just clone the repository and create a `./eli` symlink.

```shell
$ git clone https://github.com/negrel/eli.git

# Symlink to /usr/local/bin
ln -s `pwd`/eli /usr/local/bin/eli
```

## Update

Just pull the master branch:

```shell
$ git pull origin master
```

## Build the images

```shell
# Build one of the Containerfile under distributions/
$ make build/archlinux
...
```

Currently, the following images are available:
- `archlinux`

## Known limitations

The following limitations are known to date:
- File size can't exceed your tmpfs size (squashfs)

## :stars: Show your support

Please give a :star: if this project helped you!

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)
