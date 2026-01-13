#!/bin/bash
#
# Build ipkg of tailscale.combined.compressed
#

mkdir -p temp/tailscale-200micron/CONTROL temp/tailscale-200micron/usr/bin || true
mkdir -p temp/tailscale-200micron-compressed/CONTROL temp/tailscale-200micron-compressed/usr/bin || true

cat <<EOF > temp/tailscale-200micron/CONTROL/control
Package: tailscale-200micron
Version: 1.0.0
Architecture: all
Maintainer: Tailscale, Ari Stehney
Description: Fast and secure Wireguard-based VPN, 200micron lightweight fork.
Section: misc
Priority: optional
EOF

cat <<EOF > temp/tailscale-200micron-compressed/CONTROL/control
Package: tailscale-200micron-compressed
Version: 1.0.0
Architecture: all
Maintainer: Tailscale, Ari Stehney
Description: Fast and secure Wireguard-based VPN, 200micron lightweight fork. (UPX compressed version)
Section: misc
Priority: optional
EOF

cp tailscale.combined temp/tailscale-200micron/usr/bin/
ln -s /usr/bin/tailscale.combined temp/tailscale-200micron/usr/bin/tailscale
ln -s /usr/bin/tailscale.combined temp/tailscale-200micron/usr/bin/tailscaled

cp tailscale.combined.compressed temp/tailscale-200micron-compressed/usr/bin/
ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-200micron-compressed/usr/bin/tailscale
ln -s /usr/bin/tailscale.combined.compressed temp/tailscale-200micron-compressed/usr/bin/tailscaled

cd temp && opkg-build tailscale-200micron && opkg-build tailscale-200micron-compressed && cd ..
