#!/bin/sh

# This script attaches to the Docker container's interactive root shell.

die () {
	echo "$*" >&2
	exit 1
}

image=dscho/docker-desktop
container="$(sudo docker ps |
	sed -n "s|^\([^ ]*\) *$image:latest .*|\1|p")"
test -n "$container" ||
die "No container running"

sudo docker attach "$container"
