#!/bin/bash

set -eux

# make output dir's
mkdir -p ./{config,pcap,logs,artifacts}

# build locally
podman build -t arkime .

# cleanup
podman image prune -f
podman rmi oraclelinux:9 -f

# run arkime
podman run --rm -it \
           --name arkime \
           --net=host \
           --cap-add=net_admin \
           --cap-add=net_raw \
           --cap-add=sys_nice \
           -p 8005:8005 \
           -p 9200:9200 \
           -e OS_HOST=opensearch \
           -e OS_PORT=9200 \
           -v ./config:/data/config \
           -v ./pcap:/data/pcap \
           -v ./logs:/data/logs \
           -d arkime

# get build artifacts
podman cp arkime:/home/arkime/artifacts .

# watch startup
watch podman logs arkime
