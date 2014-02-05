#!/bin/sh

# This script is supposed to perform all the steps necessary for you to
# connect to the shiny new Xpra session running inside Docker container

die () {
	echo "$*" >&2
	exit 1
}

image=dscho/docker-desktop
container="$(sudo docker ps |
	sed -n "s|^\([^ ]*\) *$image:latest .*|\1|p")"

# Make sure that we have a public ssh key in shared/
test -f shared/id_rsa.pub || {
	echo "Need to generate a private/public ssh key pair" >&2
	test -z "$container" ||
	! echo "Stopping container $container" >&2 ||
	sudo docker stop "$container" ||
	die "Could not stop container $container; need to make an ssh key"

	ssh-keygen -b 4096 -f id_rsa -N '' &&
	mv id_rsa.pub shared/ ||
	die "Could not generate/copy private key"
	container=
}

# Make sure that docker-desktop is running
test -n "$container" ||
container="$(sudo docker run -h=docker-desktop \
	-v "$(pwd)"/shared/:/shared -P -t -i -d "$image")" ||
die "Could not run $image"

# Determine port on which ssh is running
ssh_port="$(sudo docker port "$container" 22)"
ssh_port=${ssh_port##*:}

# Call xpra
xpra --ssh="ssh -o NoHostAuthenticationForLocalhost=true -i \"$(pwd)\"/id_rsa docker@127.0.0.1 -p $ssh_port" \
	attach ssh::10
