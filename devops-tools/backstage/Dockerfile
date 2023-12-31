# syntax=docker/dockerfile:1
# backstage: an open platform for building developer portals.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"

FROM ${repo}/${base_image}@sha256:${image_hash}

RUN \
    # https://github.com/laverdet/isolated-vm#requirements
    apk add --no-cache -t .ivm-deps \
        python3 \
        make \
        g++; \
    # https://backstage.io/docs/getting-started/
    apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        git \
        npm \
        wget \
        yarn; \
    echo "backstage" | npx --yes @backstage/create-app@latest; \
    apk del --no-network --purge .ivm-deps

EXPOSE 3000
WORKDIR /backstage
RUN yarn add --cwd packages/backend pg
ENTRYPOINT [ "/bin/sh", "-c", "yarn dev" ]
