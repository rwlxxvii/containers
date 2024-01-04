#!/bin/bash

set -e

# almalinux 9 install

epel-release()
{
    dnf -y install 'dnf-command(builddep)'
    dnf -y install epel-release
    /usr/bin/crb enable
    dnf update -y
}

podman-deps()
{
    dnf -y install \
        containers-common \
        crun \
        iptables \
        netavark \
        nftables \
        slirp4netns
}

go-install()
{
    dnf install -y git
    export GOPATH=~/go
    git clone https://go.googlesource.com/go $GOPATH
    cd $GOPATH
    cd src
    ./all.bash
    export PATH=$GOPATH/bin:$PATH
}

crun-install()
{
    dnf install -y git make
    git clone https://github.com/opencontainers/runc.git $GOPATH/src/github.com/opencontainers/runc
    cd $GOPATH/src/github.com/opencontainers/runc
    make BUILDTAGS="selinux seccomp"
    cp runc /usr/bin/runc
}

conmon-install()
{
    dnf install -y \
        gcc \
        git \
        glib2-devel \
        glibc-devel \
        libseccomp-devel \
        make \
        pkgconfig \
        git \
        make
    git clone https://github.com/containers/conmon
    cd conmon
    export GOCACHE="$(mktemp -d)"
    make
    make podman
}

cni-net()
{
    mkdir -p /etc/containers
    curl -L -o /etc/containers/registries.conf https://src.fedoraproject.org/rpms/containers-common/raw/main/f/registries.conf
    curl -L -o /etc/containers/policy.json https://src.fedoraproject.org/rpms/containers-common/raw/main/f/default-policy.json
}

<<comment
modify make BUILDTAGS= to include the following options if needed

Build Tag	                        Feature	                            Dependency
apparmor	                        apparmor support	                libapparmor
exclude_graphdriver_btrfs	        exclude btrfs	                    libbtrfs
exclude_graphdriver_devicemapper	exclude device-mapper	            libdm
libdm_no_deferred_remove	        exclude deferred removal in libdm	libdm
seccomp	                            syscall filtering	                libseccomp
selinux	                            selinux process and mount labeling	
systemd	                            journald logging	                libsystemd

comment

podman-install()
{
    dnf install -y git make
    git clone https://github.com/containers/podman/
    cd podman
    make BUILDTAGS="selinux seccomp" PREFIX=/usr
    make install PREFIX=/usr
}

epel-release
podman-deps
go-install
crun-install
conmon-install
cni-net
podman-install