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

Nevertheless, you can have large file on other filesystems.

## Contributing

If you want to contribute to `eli` to add a feature or improve the code contact
me at [negrel.dev@protonmail.com](mailto:negrel.dev@protonmail.com), open an
[issue](https://github.com/negrel/eli/issues) or make a
[pull request](https://github.com/negrel/eli/pulls).

## :stars: Show your support

Please give a :star: if this project helped you!

[![buy me a coffee](https://uc80e5ba3058c2d15b2a77972a8b.previews.dropboxusercontent.com/p/thumb/ABkAj4l5EiWEUsvoBF2gg6RQnKie-CpWLAeL6Wm8qcba1dGkkFusA7JSInK0VyAB2YDh4nA8ggslHKgAC1QMn12RA6tg0crts3S_meF6xfKl2Wj9KOCGFMvNOiYEgN5SJLG57IkpHtzqMdBKgzPvstEWq199H-IO2XNMox--bf5c24JMJXv2giJZ5WSgMbs6xq1Ky99FCGLKQK3VRKMtBUOfib_4mw7r7skHpX5Ozqr0YmA4jl8dj2J_4EPyB0XmgjOmyQRYJkllhohsBsL5JNYZ_G_2NV84BloNW4nuk2-Tk4Dk9xDbHgDKs8aw_a7lKp20U06i47SE5RoIaR-0mZc2AOXsIGhZLRk3fPrlsE7CBySn4nn03nSGRat5vHc61jE/p.png)](https://www.buymeacoffee.com/negrel)

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)
