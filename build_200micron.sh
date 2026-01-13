#!/usr/bin/env sh
#
# Runs `go build` with flags configured for binary distribution. All
# it does differently from `go build` is burn git commit and version
# information into the binaries, so that we can track down user
# issues.
#
# If you're packaging Tailscale for a distro, please consider using
# this script, or executing equivalent commands in your
# distro-specific build system.

set -eu
mkdir temp

go="go"
if [ -n "${TS_USE_TOOLCHAIN:-}" ]; then
	go="./tool/go"
fi

tags="${tags:+$tags,},$(GOOS= GOARCH= $go run ./cmd/featuretags --min --add=osrouter)"

CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=5 $go build -o tailscale.combined -tags ts_include_cli,$tags -ldflags="-s -w" ./cmd/tailscaled
mv tailscale.combined temp/

cp temp/tailscale.combined temp/tailscale.combined.compressed
./tool/upx-5.0.2-amd64_linux/upx --lzma --best ./temp/tailscale.combined.compressed
