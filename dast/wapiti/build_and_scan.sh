#!/bin/bash

MODE=http
TARGET=testhtml5.vulnweb.com
RESULT_DIR=./

mkdir -p ${RESULT_DIR}wapiti

#build Wapiti
podman build -t wapiti .
podman network create wapiti

#get rid of build env
podman image prune -f; podman rmi 9-minimal:latest -f

#run wapiti
podman run --rm --security-opt=no-new-privileges --network wapiti -v /etc/localtime:/etc/localtime:ro -it --name wapiti -d wapiti

#update and execute scan
podman exec wapiti wapiti --update
podman exec wapiti wapiti -v2 -u ${MODE}://${TARGET}

#get report
podman cp wapiti:/home/wapiti/.wapiti/generated_report $RESULT_DIR/wapiti
