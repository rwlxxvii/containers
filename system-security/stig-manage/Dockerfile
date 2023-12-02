# syntax=docker/dockerfile:1
# stig-manager: API and Web client for managing the assessment of Information Systems for compliance.
ARG repo="docker.io" \
    base_image="alpine:edge" \
    image_hash="3e44438281baf26907675b99c9a4a421c4d4a57c954120327e703aa8329086bd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    addgroup -g 65535 node; \
    adduser --shell /sbin/nologin --disabled-password -h /home/node --uid 65535 --ingroup node node; \
    apk add --no-cache \
        alpine-baselayout \
        alpine-baselayout-data \
        alpine-keys \
        apk-tools \
        busybox \
        busybox-binish \
        ca-certificates-bundle \
        libc-utils \
        libcrypto3 \
        libgcc \
        libssl3 \
        libstdc++ \
        musl \
        musl-utils \
        scanelf \
        ssl_client \
        zlib \
        npm \
        git; \
    apk add --no-cache -t .av-scan \
        clamav \
        freshclam; \
    mkdir -p /home/node/client; \
    mkdir -p /home/node/docs

WORKDIR /home/node

# easier to download files into container for rolling updates, just change version
ARG STIG_MAN_VER=1.3.14

RUN \
    git clone --depth 1 --branch v${STIG_MAN_VER} https://github.com/NUWCDIVNPT/stig-manager.git; \
    cp -r stig-manager/api/source .; \
    mkdir -p client; \
    cp -r stig-manager/client/dist ./client; \
    mkdir -p docs; \
    cp -r stig-manager/docs/_build/html ./docs; \
    chown -R node:node /home/node; \
    rm -rf stig-manager; \
    apk del --no-network git
    
#COPY --chown=node:node ./api/source .
#COPY --chown=node:node ./client/dist ./client
#COPY --chown=node:node ./docs/_build/html ./docs

RUN \
    npm ci; \
    df -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t 2>/dev/null; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    grep -Hrn FOUND clamav_scan.log; \ 
    apk del --no-network --purge .av-scan; \
    rm -rf /var/cache/apk/*
    
ENV STIGMAN_CLIENT_DIRECTORY=./client \
    STIGMAN_DOCS_DIRECTORY=./docs

USER node
EXPOSE 54000
HEALTHCHECK --interval=120s --timeout=3s --start-period=120s CMD node healthcheck.js
CMD [ "node", "index.js" ]
