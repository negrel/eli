# Hooks

This directory contains hooks run during an installation.

Currently, only `pre-install` hooks are supported.

If possible, hooks shouldn't require an internet connection and should be short
(to not slow down the installation).

Hooks should be used to customize the image before install (changing hostname,
fstab, etc).
