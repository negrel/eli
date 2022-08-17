# `eli` - Bootable OCI/Docker images on bare metal.

Make ISO files from OCI/Docker images.

## Docs

Documentation is available under [`./docs`](./docs/README.md).

## Getting started

First, you must install `eli` and its dependencies.

## Installing

To install `eli`, just clone the repository and create a symlink:

```shell
$ git clone https://github.com/negrel/eli.git

# Symlink to /usr/local/bin
ln -s `pwd`/eli/eli /usr/local/bin/eli
```

You must also have the following binaries:

- `bash`: GNU Bourne-Again SHell
- `buildah`: A command line tool that facilitates building OCI container images.
- the coreutils
- `chroot`: change root directory

The first thing to do is to build an installable image. You can choose any one
from this [list](#supported-images).

For this example, we will use the `archlinux` image.

```shell
# Build the ArchLinux base image
$ sudo make build/archlinux
buildah bud \
        --layers -t eli/archlinux \
        -f archlinux/Containerfile.in distributions/
STEP 1/20: FROM docker.io/library/archlinux:latest
STEP 2/20: ARG ELI_DISTRIB=archlinux
...
```

Once the image is built, we can start an installation. You can either choose to produce an ISO file out of the image or
perform a regular installation with a boot and a root partition.

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

## Contributing

If you want to contribute to `eli` to add a feature or improve the code contact
me at [negrel.dev@protonmail.com](mailto:negrel.dev@protonmail.com), open an
[issue](https://github.com/negrel/eli/issues) or make a
[pull request](https://github.com/negrel/eli/pulls).

## :stars: Show your support

Please give a :star: if this project helped you!

[![buy me a coffee](.github/bmc-button.png)](https://www.buymeacoffee.com/negrel)

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)
