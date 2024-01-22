# syntax=docker/dockerfile:1
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"

FROM ${repo}/${base_image}@sha256:${image_hash} AS builder

ENV SIEGE_VER 4.1.6

RUN \
    apk add --no-cache -t .siege-deps \
        wget \
        g++ \
        make \
        zlib-dev; \
    wget https://download.joedog.org/siege/siege-${SIEGE_VER}.tar.gz; \
    tar -xf siege-${SIEGE_VER}.tar.gz; \
    cd siege-${SIEGE_VER}; \
    ./configure; \
    make install; \
    cd /; \
    rm -rf siege-${SIEGE_VER}; \
    rm -f siege-${SIEGE_VER}.tar.gz; \
    apk del --no-network .siege-deps

FROM ${repo}/${base_image}@sha256:${image_hash}
COPY --chmod=755 --from=builder /usr/local/bin /usr/local/bin
COPY urls.txt .
RUN \
    mkdir -p /root/.siege; \
    siege.config
ENTRYPOINT [ "/bin/sh", "-c", "siege --delay=0.5 --file=urls.txt --internet --verbose --reps=200 --concurrent=15 --no-parser" ]
