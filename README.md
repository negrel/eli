# `eli` - Bootable, immutable OCI/Docker images on bare metal.

Your Linux installation as a bootable, immutable OCI/Docker image, bare metal.

## Docs

Documentation is available under [`./docs`](./docs/README.md).

## Installation

To install `eli`, just clone the repository and create a symlink:

```shell
$ git clone https://github.com/negrel/eli.git

# Symlink to /usr/local/bin
ln -s `pwd`/eli/eli /usr/local/bin/eli
```

You must also install the following dependencies:

- `buildah`: A command line tool that facilitates building OCI container images.
- `jq`: Command-line JSON processor

## Getting started

The first thing to do is to build an installable image. You can choose any one
from this [list](#supported-images).

For this example, we will use the `archlinux` image.

```shell
# Build the ArchLinux base image
$ sudo make build/archlinux
buildah bud \
        --layers -t eli/archlinux \
        -f distributions/archlinux/Containerfile.in distributions/
...
```

Once the image is built, we can start an installation. Currently, two
installation modes are available:

- `iso`: Produce an ISO image out of the OCI/Docker image
- `regular`: A regular installation with a boot and a root partition.

For this example, we will produce an ISO image.

```shell
# If you want to produce an ISO file.
$ iso_dst=/path/to/destination/iso

# If you want to burn the ISO on a device.
# WARNING this will FORMAT your usb stick directly
$ iso_dst=/dev/<my_usb_stick>

$ sudo eli install-iso eli/archlinux $iso_dst
...
```

That's it ! You successfully produced your first ISO from an OCI/Docker image.

## Supported images

Currently, the following images are availables:

- `archlinux`

## Known limitations

### File size

Size of a single file can't exceed your physical RAM. This is a limitation of
`tmpfs` that is used as the upper layer of an `overlayfs`.

Nevertheless, you can have large on other filesystems.

## :stars: Show your support

Please give a :star: if this project helped you!

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)
