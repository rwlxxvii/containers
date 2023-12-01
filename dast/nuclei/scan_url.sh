#!/bin/bash

DATE=$(date +"%Y%m%d")
MODE=http
TARGET=testhtml5.vulnweb.com
RESULT_DIR=./
THREADS=35
IMAGE=alpine:edge

mkdir -p ${RESULT_DIR}nuclei

#build Nuclei
podman build -t nuclei .
podman network create nuclei

#get rid of build env
podman image prune -f; podman rmi ${IMAGE} -f

#run nuclei
podman run --rm --security-opt=no-new-privileges --network nuclei -v /etc/localtime:/etc/localtime:ro -it --name nuclei -d nuclei

#update templates
podman exec nuclei nuclei -ut

#execute scan
podman exec nuclei nuclei -c $THREADS -ni -u ${MODE}://${TARGET} -o /home/nuclei/nuclei-${MODE}-${TARGET}-${DATE}.log

#get results
podman cp nuclei:/home/nuclei $RESULT_DIR/nuclei
