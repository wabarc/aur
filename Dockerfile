FROM archlinux:latest

ARG WAYBACK_IPFS_APIKEY

RUN pacman -Syu base-devel git go --noconfirm --overwrite '*'

WORKDIR /aur

COPY . .

RUN set -eu pipefail; \
    cp -r /aur /build; \
    chgrp nobody /build; \
    chmod g+ws /build; \
    setfacl -m u::rwx,g::rwx /build

WORKDIR /build

RUN set -eu pipefail && \
    chmod a+r /build/PKGBUILD && \
    make version && \
    sudo -u nobody GOPATH=/tmp/go GOCACHE=/tmp/.cache WAYBACK_IPFS_APIKEY=$WAYBACK_IPFS_APIKEY makepkg -sf --noconfirm

RUN chmod a+x /build/entrypoint.sh

ENTRYPOINT ["/build/entrypoint.sh"]
