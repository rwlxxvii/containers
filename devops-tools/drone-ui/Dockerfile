# syntax=docker/dockerfile:1
# drone-ui: provides access to applications and critical systems with fine-grained authorizations without managing credentials or exposing your network.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"

FROM ${repo}/${base_image}@sha256:${image_hash}

ARG DRONE_URL
ARG DRONE_TOKEN
EXPOSE 3001/tcp

RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        git \
        npm \
        tzdata; \
    git clone https://github.com/drone/drone-ui.git; \
    cd drone-ui; \
    npm install; \
    cp .env.example .env.development.local; \
    export REACT_APP_DRONE_SERVER=${DRONE_URL}; \
    # find your token in your Drone account settings (click your Avatar in the UI).
    export REACT_APP_DRONE_TOKEN=${DRONE_TOKEN}; \
    \
    npm run start; \
    npm run build; \
    npm run serve; \
    npm run lint:fix
