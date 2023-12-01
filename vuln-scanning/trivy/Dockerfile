# syntax=docker/dockerfile:1
# trivy: is a comprehensive and versatile security scanner.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS build-env

ENV GOPATH=/usr/local/bin/go \
    VER=0.47.0 \
    SNYK_API=

# clone go app, run snyk scans, install
RUN \
    apk add --no-cache -t .trivy-deps ca-certificates go git npm wget; \
    mkdir -p ${GOPATH}/src/github.com/aquasecurity; \
    cd ${GOPATH}/src/github.com/aquasecurity; \
    git clone --depth 1 --branch v${VER} https://github.com/aquasecurity/trivy; \
    cd trivy/; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /trivy-code-review.html; \
#    snyk test --json | snyk-to-html -o /trivy-deps.html; \
#    snyk monitor; \ 
    cd cmd/trivy/; \
    export GO111MODULE=on; \
    go install; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    mkdir /contrib; cd /contrib; \
    wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl; \
    wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/junit.tpl; \
    wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/gitlab-codequality.tpl; \
    wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/gitlab.tpl; \
    apk del --purge .trivy-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM ${base_image}

LABEL \
    org.opencontainers.image.name='Trivy' \
    org.opencontainers.image.description='Vulnerability and Misconfiguration Scanning.' \
    org.opencontainers.image.usage='https://github.com/aquasecurity/trivy' \
    org.opencontainers.image.url='https://www.aquasec.com/products/trivy/' \
    org.opencontainers.image.licenses='Apache License 2.0' \
    org.opencontainers.image.vendor='Aqua Security' \
    org.opencontainers.image.schema-version='0.47.0' \
    MAINTAINER="@rw"
    
RUN \
    apk add --no-cache clamav freshclam; \
    addgroup -g 65535 trivy; \
    adduser --shell /sbin/nologin --disabled-password -h /home/trivy --uid 65535 --ingroup trivy trivy
    
# copy over trivy built binary and report templates
COPY --chown=trivy:trivy --from=build-env /contrib/*.tpl /home/trivy/
COPY --chown=trivy:trivy --from=build-env /usr/local/bin/go/bin/ /usr/local/bin
#COPY --chown=trivy:trivy --from=build-env /trivy-code-review.html /home/trivy
#COPY --chown=trivy:trivy --from=build-env /trivy-deps.html /home/trivy

RUN \
    freshclam; \
    clamscan -rvi -l /home/trivy/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown trivy:trivy /home/trivy/last_scan.log; \
    grep -Hrn FOUND /home/trivy/last_scan.log; \
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*

USER trivy
WORKDIR /home/trivy
