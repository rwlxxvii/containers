# syntax=docker/dockerfile:1
# syft: A CLI tool and Go library for generating a Software Bill of Materials (SBOM) from container images and filesystems. 
# grype: A vulnerability scanner for container images and filesystems.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='Anchore Tools' \
    org.opencontainers.image.description='Scan for Vulnerabilities, Misconfigurations, and gather SBOM.' \
    org.opencontainers.image.usage='https://anchore.com/opensource/' \
    org.opencontainers.image.url='https://anchore.com/opensource/' \
    org.opencontainers.image.vendor='Anchore' \
    org.opencontainers.image.licenses='Apache License 2.0' \
    org.opencontainers.image.schema-version='Grype 0.73.4, Syft 0.98.0'

FROM base AS go-builder

ENV SYFT_VER=0.98.0 \
    GRYPE_VER=0.73.4 \
    GOPATH=/usr/local/bin/go \
    SNYK_API=

RUN \
    apk add --no-cache -t .anchore-deps \
        ca-certificates \
        go \
        git \
        npm; \
    apk add --no-cache -t .av-scan \
        clamav \
        freshclam; \
    mkdir -p ${GOPATH}/src/github.com/syft; \
    cd ${GOPATH}/src/github.com/syft; \
    git clone --depth 1 --branch v${SYFT_VER} https://github.com/anchore/syft; \
#   npm install -g snyk; \
#   npm install -g snyk-to-html; \
#   snyk config set api=${SNYK_API}; \
    cd syft/; \
#    snyk code test --json | snyk-to-html -o /syft-code-review.html; \
#    snyk test --json | snyk-to-html -o /syft-deps.html; \
#    snyk monitor; \ 
    export GO111MODULE=on; \
    cd cmd/syft/; \
    go install; \
    mkdir -p ${GOPATH}/src/github.com/grype; \
    cd ${GOPATH}/src/github.com/grype; \
    git clone --depth 1 --branch v${GRYPE_VER} https://github.com/anchore/grype; \
    cd grype; \
#    snyk code test --json | snyk-to-html -o /grype-code-review.html; \
#    snyk test --json | snyk-to-html -o /grype-deps.html; \
#    snyk monitor; \
    cd cmd/grype; \
    go install; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    apk del --no-network --purge .anchore-deps; \
    freshclam; \
    clamscan -rvi -l /clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    grep -Hrn FOUND /clamav_scan.log; \ 
    apk del --no-network --purge .av-scan; \
    rm -rf /var/cache/apk/*; \
    rm -rf ${GOPATH}/src/github.com

FROM base

RUN \
    addgroup -g 65535 anchore; \
    adduser --shell /sbin/nologin --disabled-password -h /home/anchore --uid 65535 --ingroup anchore anchore
    
COPY --chown=anchore:anchore --from=go-builder /usr/local/bin/go/bin/ /usr/local/bin
COPY --chown=anchore:anchore --from=go-builder /clamav_scan.log /home/anchore
#COPY --chown=anchore:anchore --from=go-builder /syft-code-review.html /home/anchore
#COPY --chown=anchore:anchore --from=go-builder /syft-deps.html /home/anchore
#COPY --chown=anchore:anchore --from=go-builder /grype-code-review.html /home/anchore
#COPY --chown=anchore:anchore --from=go-builder /grype-deps.html /home/anchore

WORKDIR /home/anchore/
USER anchore
