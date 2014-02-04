DOCKER-DESKTOP
==============

##Description

This Dockerfile creates a docker image and once it's executed it creates a container that runs X11 and SSH services.
The ssh is used to forward X11 and provide you encrypted data communication between the docker container and your local machine.

Xpra allows to display the applications running inside of the container such as Firefox, LibreOffice, xterm, etc. with recovery connection capabilities. Xpra also uses a custom protocol that is self-tuning and relatively latency-insensitive, and thus is usable over worse links than standard X.

The applications can be rootless, so the client machine manages the windows that are displayed.

Fluxbox and ROX-Filer creates a very minimalist way to manages the windows and files. 


![Docker L](image/docker-desktop.png "Docker-Desktop")

OBS: The client machine needs to have a X11 server installed (Xpra). See the "Notes" below. 

##Docker Installation

###On Ubuntu:
Docker is available as a Ubuntu PPA (Personal Package Archive), hosted on launchpad which makes installing Docker on Ubuntu very easy.

```
#Add the PPA sources to your apt sources list.
sudo apt-get install python-software-properties && sudo add-apt-repository ppa:dotcloud/lxc-docker
 
# Update your sources
sudo apt-get update
 
# Install, you will see another warning that the package cannot be authenticated. Confirm install.
sudo apt-get install lxc-docker
```
###On Windows:
Requirements:
- Installation Tutorial (http://docs.docker.io/en/latest/installation/windows/)

###On Mac OS X:
Requirements:
- Installation Tutorial (http://docs.docker.io/en/latest/installation/vagrant/)

##Installation


###Building the docker image

```
$ docker build -t [username]/docker-desktop git://github.com/rogaha/docker-desktop.git

OR

$ git clone https://github.com/rogaha/docker-desktop.git
$ cd docker-desktop
$ docker build -t [username]/docker-desktop .
```

###Running the docker container and attach to it

```
$ ./connect
```

##Notes

###On Windows:
Requirements:
- Xpra <= 0.9.8 (https://www.xpra.org/dists/windows/)
- Path: C:\Program Files(x86)\Xpra\Xpra_cmd.exe

###On OS X:
Requirements:
- Xpra Version <= 0.9.8 (https://www.xpra.org/dists/osx/x86/)
- Path: /Applications/Xpra.app/Contents/Helpers/xpra


###On Linux:
Requirements:
- Xpra: You can use apt-get to install it -> apt-get install xpra
- Path: /usr/bin/xpra
