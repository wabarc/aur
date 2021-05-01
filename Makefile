DOCKER ?= $(shell which docker || which podman)
VERSION = $(shell curl -s 'https://api.github.com/repos/wabarc/wayback/tags?per_page=1' | grep '"name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed -e 's/v//g')

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
	$(shell sed -Ei 's/pkgver=[0-9]+\.[0-9]+\.[0-9]+/pkgver=$(VERSION)/g' ./PKGBUILD)
	$(shell sed -Ei 's/pkgver = [0-9]+\.[0-9]+\.[0-9]+/pkgver = $(VERSION)/g' ./.SRCINFO)

publish:
	$(MAKE) version
	git checkout main
	git commit -am "Release v$(VERSION)"
	git checkout aur
	git fetch aur master
	git reset --hard aur/master
	git checkout main -- .SRCINFO PKGBUILD
	git commit -am "Release v$(VERSION)"
	git push aur aur:master
	git push origin main

clean:
	rm -rf src/* pkg/* *.tar.zst
