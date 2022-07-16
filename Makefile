default: build/archlinux

build/%:
	buildah bud --layers -t eli/$(@F) -f distributions/$(@F)/Containerfile.in distributions/
