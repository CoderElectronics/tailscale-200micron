build:
    #!/bin/bash
    set -eu
    mkdir temp || true

    go="go"
    if [ -n "${TS_USE_TOOLCHAIN:-}" ]; then
    go="./tool/go"
    fi

    tags="${tags:+$tags,},$(GOOS= GOARCH= $go run ./cmd/featuretags --min --add=osrouter)"

    CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=5 $go build -o tailscale.combined -tags ts_include_cli,$tags -ldflags="-s -w" ./cmd/tailscaled
    mv tailscale.combined temp/

    cp temp/tailscale.combined temp/tailscale.combined.compressed
    ./tool/upx-5.0.2-amd64_linux/upx --lzma --best ./temp/tailscale.combined.compressed

package:
    #!/bin/bash
    mkdir -p temp/tailscale/CONTROL temp/tailscale/usr/bin || true
    mkdir -p temp/tailscale-compressed/CONTROL temp/tailscale-compressed/usr/bin || true

    cat <<EOF > temp/tailscale/CONTROL/control
    Package: tailscale
    Version: 1.0.0
    Architecture: all
    Maintainer: Tailscale, Ari Stehney
    Description: Fast and secure Wireguard-based VPN, 200micron lightweight fork.
    Section: misc
    Priority: optional
    EOF

    cat <<EOF > temp/tailscale-compressed/CONTROL/control
    Package: tailscale-compressed
    Version: 1.0.0
    Architecture: all
    Maintainer: Tailscale, Ari Stehney
    Description: Fast and secure Wireguard-based VPN, 200micron lightweight fork. (UPX compressed version)
    Section: misc
    Priority: optional
    EOF

    cp tailscale.combined temp/tailscale/usr/bin/
    ln -s /usr/bin/tailscale.combined temp/tailscale/usr/bin/tailscale
    ln -s /usr/bin/tailscale.combined temp/tailscale/usr/bin/tailscaled

    cp tailscale.combined.compressed temp/tailscale-compressed/usr/bin/
    ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-compressed/usr/bin/tailscale
    ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-compressed/usr/bin/tailscaled

    opkg-build temp/tailscale && opkg-build temp/tailscale-compressed
    cp *.ipk $DEST_DIR || true

install:
    $BR_DIR/sendfile-ser.sh *.ipk
    $BR_DIR/sendcmd-ser.sh "opkg install *.ipk && rm *.ipk"

clean:
    rm -rf temp *.ipk

all: clean build package
