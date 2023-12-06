# syntax=docker/dockerfile:1
# atmos: Workflow automation tool for DevOps.
# https://atmos.tools/quick-start

ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    addgroup -g 65535 atmos; \
    adduser --shell /sbin/nologin --disabled-password -h /.atmos --uid 65535 --ingroup atmos atmos; \
    mkdir -p /stacks/workflows /components/terraform /usr/local/etc/atmos /home/atmos; \
    chown -R atmos:atmos /stacks/workflows /components/terraform /usr/local/etc/atmos /home/atmos

FROM base AS go-builder

ENV GOPATH=/usr/local/bin/go \
    VER=1.50.0
    
#ENV SNYK_API

RUN \
    apk add --no-cache -t .build-deps \
        ca-certificates \
        go \
        git \
        make \
        npm; \
    \
    mkdir -p ${GOPATH}/src/github.com/cloudposse; \
    cd ${GOPATH}/src/github.com/cloudposse; \
    git clone --depth 1 --branch v${VER} https://github.com/cloudposse/atmos; \
    cd atmos/; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /atmos-code-review.html; \
#    snyk test --json | snyk-to-html -o /atmos-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    \
    go install; \
    apk del --purge .build-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM base

COPY --chown=atmos:atmos atmos.yml /usr/local/etc/atmos/atmos.yaml
COPY --chown=atmos:atmos --from=go-builder /usr/local/bin/go/bin/ /usr/local/bin
#COPY --chown=atmos:atmos --from=go-builder /atmos-code-review.html /home/atmos
#COPY --chown=atmos:atmos --from=go-builder /atmos-deps.html /home/atmos

VOLUME [ "/stacks", "/components" ]
USER atmos
# bin check
RUN atmos -h
WORKDIR /home/atmos