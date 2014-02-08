#!/bin/sh

# This script is supposed to perform all the steps necessary for you to
# connect to the shiny new Xpra session running inside Docker container

die () {
	echo "$*" >&2
	exit 1
}

image=dscho/docker-desktop

# Make sure that we have a public ssh key in shared/
test -f shared/id_rsa.pub || {
	echo "Need to generate a private/public ssh key pair" >&2
	container="$(sudo docker ps |
		sed -n "s|^\([^ ]*\) *$image:latest .*|\1|p")"
	test -z "$container" ||
	! echo "Stopping container $container" >&2 ||
	sudo docker stop "$container" ||
	die "Could not stop container $container; need to make an ssh key"

	ssh-keygen -b 4096 -f id_rsa -N '' &&
	mv id_rsa.pub shared/ ||
	die "Could not generate/copy private key"
}

wait_for_socket () {
	counter=0
	while test ! -S "$1"
	do
		printf .
		counter=$(($counter+1))
		test $counter -lt 5 ||
		die " Socket $1 not available"
		sleep 1
	done
	printf '\r'
}

# Make sure that docker-desktop is running
test -S shared/docker-desktop-10 || {
	sudo docker run -h=docker-desktop \
		-v "$(pwd)"/shared/:/shared -P -t -i -d "$image" &&
	# Give the container some time to start up, like, one second
	wait_for_socket shared/docker-desktop-10
} ||
die "Could not run $image"


# Call xpra
socat UNIX-LISTEN:shared/$(hostname)-10 UNIX:shared/docker-desktop-10 &
wait_for_socket shared/$(hostname)-10 &&
XPRA_ALLOW_ALPHA=0 ALLOW_ALPHA=0 xpra --socket-dir="$(pwd)"/shared/ attach :10
