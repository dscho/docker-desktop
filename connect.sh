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

# Make sure that we have an id_rsa file
test -f id_rsa || {
	echo "Need to generate a private/public ssh key pair" >&2
	test -z "$container" ||
	! echo "Stopping container $container" >&2 ||
	sudo docker stop "$container" ||
	die "Could not stop container $container; need to make an ssh key"

	ssh-keygen -b 4096 -f id_rsa -N '' &&
	cat id_rsa.pub |
	sudo docker run -cidfile=tmp.id "$image" \
		tee /home/docker/.ssh/authorized_keys &&
	container="$(cat tmp.id)" &&
	rm -f tmp.id &&
	sudo docker commit "$container" "$image" ||
	die "Could not insert private key into container"
	container=
}

# Make sure that docker-desktop is running
test -n "$container" ||
container="$(sudo docker run -h=docker-desktop -P -d "$image")" ||
die "Could not run $image"

# Determine port on which ssh is running
ssh_port="$(sudo docker port "$container" 22)"
ssh_port=${ssh_port##*:}

# Call xpra
xpra --ssh="ssh -i \"$(pwd)\"/id_rsa docker@127.0.0.1 -p $ssh_port" \
	attach ssh::10
