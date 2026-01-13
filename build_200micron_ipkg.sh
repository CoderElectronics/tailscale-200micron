#!/bin/bash
#
# Build ipkg of tailscale.combined.compressed
#

mkdir -p temp/tailscale-200micron/CONTROL temp/tailscale-200micron/usr/bin

cat <<EOF > temp/tailscale-200micron/CONTROL/control
Package: tailscale-200micron
Version: 1.0.0
Architecture: all
Maintainer: Tailscale, Ari Stehney
Description: Fast and secure Wireguard-based VPN, 200micron lightweight fork
Section: misc
Priority: optional
EOF

cp tailscale.combined.compressed temp/tailscale-200micron/usr/bin/
ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-200micron/usr/bin/tailscale
ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-200micron/usr/bin/tailscaled

cd temp && opkg-build tailscale-200micron && cd ..
