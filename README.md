Eli - Linux distribution management made easy

## Dependencies

Eli relies on the following commands:
- `buildah`: A tool that facilitates building OCI images.

## Installation

To install eli, just clone the repository and create a `cmd/eli` symlink.

```shell
$ git clone https://github.com/negrel/eli.git

# Symlink to /usr/local/bin
ln -s `pwd`/cmd/eli /usr/local/bin/eli
```

## Update

```shell
$ git pull origin master
```