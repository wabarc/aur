DOCKER ?= $(shell which docker || which podman)
VERSION = $(shell curl -s https://api.github.com/repos/wabarc/wayback/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed -e 's/v//g')

.PHONY: build
build:
	$(DOCKER) build -t builder .
	$(DOCKER) run --rm -v $(PWD):/aur builder

volume: build

srcinfo:
	$(DOCKER) build -t builder .
	$(DOCKER) run --rm -v $(PWD):/aur builder \
			sudo -u nobody makepkg --printsrcinfo > .SRCINFO

version:
	$(shell sed -i 's/pkgver=latest/pkgver=$(VERSION)/g' ./PKGBUILD)
	$(shell sed -i 's/pkgver = latest/pkgver = $(VERSION)/g' ./.SRCINFO)

clean:
	rm -rf src/* pkg/* *.tar.zst
