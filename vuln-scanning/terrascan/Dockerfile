# syntax=docker/dockerfile:1
# terrascan: static code analyzer for Infrastructure as Code.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS build-env

ENV GOPATH=/usr/local/bin/go \
    TERRA_VER=1.18.5 \
    SNYK_API=

RUN \
    apk add --no-cache -t .terrascan-deps \
        ca-certificates \
        go \
        git \
        npm; \
    mkdir -p ${GOPATH}/src/github.com/terrascan; \
    cd ${GOPATH}/src/github.com/terrascan; \
    git clone --depth 1 --branch v${TERRA_VER} https://github.com/tenable/terrascan; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
    cd terrascan/; \
#    snyk code test --json | snyk-to-html -o /terrascan-code-review.html; \
#    snyk test --all-projects --json | snyk-to-html -o /terrascan-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    cd cmd/terrascan/; \
    CGO_ENABLED=0; \
    GO111MODULE=on; \
    go install; \
    apk del --purge .terrascan-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM ${base_image}

RUN \
    apk add --no-cache clamav freshclam; \
    addgroup -g 65535 terrascan; \
    adduser --shell /sbin/nologin --disabled-password -h /home/terrascan --uid 65535 --ingroup terrascan terrascan
    
COPY --chown=terrascan:terrascan --from=build-env /usr/local/bin/go/bin/ /usr/local/bin
#COPY --chown=terrascan:terrascan --from=build-env /terrascan-code-review.html /home/terrascan
#COPY --chown=terrascan:terrascan --from=build-env /terrascan-deps.html /home/terrascan

RUN \
    freshclam; \
    clamscan -rvi -l /home/terrascan/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown terrascan:terrascan /home/terrascan/last_scan.log; \
    grep -Hrn " FOUND" /home/terrascan/last_scan.log; \ 
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*
    
USER terrascan
RUN terrascan init
WORKDIR /home/terrascan
CMD [ "sh" ]
