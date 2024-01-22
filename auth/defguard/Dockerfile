FROM docker.io/rust:1.74 as chef

WORKDIR /build

RUN \
    cargo install cargo-chef; \
    rustup component add rustfmt

FROM chef as planner

RUN \
    git clone https://github.com/DefGuard/defguard; \
    cd defguard; \
    cargo chef prepare --recipe-path /build/recipe.json; \
    git clone https://github.com/DefGuard/ui

FROM chef AS builder

COPY --from=planner /build/recipe.json recipe.json

RUN \
    cargo chef cook --release --recipe-path recipe.json; \
    apt-get update; \
    apt-get -y install \
        protobuf-compiler \
        libprotobuf-dev; \
    cargo install --locked --path . --root /build/defguard

FROM node:20.5-alpine3.17 as web

WORKDIR /app

COPY --from=planner /build/defguard/web/package.json .
COPY --from=planner /build/defguard/web/pnpm-lock.yaml .
COPY --from=planner /build/defguard/web/.npmrc .

RUN \
    npm i -g pnpm; \
    pnpm install --ignore-scripts --frozen-lockfile

COPY --from=planner /build/defguard/web/ .
COPY --from=planner /build/defguard/ui defguard-ui/

RUN \
    pnpm run generate-translation-types; \
    pnpm build

FROM debian:bookworm-slim as runtime

RUN \
    apt-get update -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        libssl-dev; \
    rm -rf /var/lib/apt/lists/*

COPY --from=planner /build/defguard/user_agent_header_regexes.yaml /app/user_agent_header_regexes.yaml
WORKDIR /app
COPY --from=builder /build/defguard/bin/defguard .
COPY --from=web /app/dist ./web/dist
COPY --from=planner /build/defguard/web/src/shared/images/svg ./web/src/shared/images/svg
ENTRYPOINT ["./defguard"]