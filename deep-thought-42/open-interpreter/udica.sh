#!/bin/bash
#
# udica - Generate SELinux policies for containers.
#
# as user "interpreter"
#

#create directories for container
mkdir -p /home/interpreter/data

#enfore SELinux
setenforce 1
sed -e "s#SELINUX=.*#SELINUX=enforcing#" -i /etc/selinux/config

#install udica
dnf install -y udica

#build and run interpreter container
podman network create terpnet
podman build -t interpreter .
podman run --rm -it \
  -v /home/interpreter/data:/data:rw \
  --network terpnet --name interpreter -d interpreter

#generate policy
podman inspect interpreter > interpreter.json
udica -j interpreter.json interpreter

#use policy
semodule -i interpreter.cil /usr/share/udica/templates/{base_container.cil,net_container.cil,home_container.cil}

#Restart the container with: "--security-opt label=type:interpreter.process" parameter
podman run --security-opt label=type:interpreter.process \
  -v /home/interpreter/data:/data:rw \
  --network terpnet --rm -it interpreter -d interpreter
