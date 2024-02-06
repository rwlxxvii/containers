# syntax=docker/dockerfile:1
# chain-bench: An open-source tool for auditing your software supply chain stack for security compliance based on a new CIS Software Supply Chain benchmark. 
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    addgroup -g 65535 chainb; \
    adduser --shell /sbin/nologin --disabled-password -h /home/chain-bench --uid 65535 --ingroup chainb chainb

FROM base AS go-builder

ENV GOPATH=/usr/local/bin/go \
    VER=0.1.10
    
#ENV SNYK_API 

RUN \
    apk add --no-cache -t .chainb-deps \
        ca-certificates \
        go \
        git \
        make \
        npm; \
    mkdir -p ${GOPATH}/src/github.com/aquasecurity; \
    cd ${GOPATH}/src/github.com/aquasecurity; \
    git clone --depth 1 --branch v${VER} https://github.com/aquasecurity/chain-bench; \
    cd chain-bench/; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /chain-bench-code-review.html; \
#    snyk test --json | snyk-to-html -o /chain-bench-deps.html; \
#    snyk monitor; \ 
    cd cmd/chain-bench/; \
    export GO111MODULE=on; \
    go install; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    apk del --purge .chainb-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM base

COPY --chown=chainb:chainb gitlab_security_scanner.tpl /templates
COPY --chown=chainb:chainb --from=go-builder /usr/local/bin/go/bin/ /usr/local/bin
#COPY --chown=chainb:chainb --from=go-builder /chain-bench-code-review.html /home/chain-bench
#COPY --chown=chainb:chainb --from=go-builder /chain-bench-deps.html /home/chain-bench

USER chainb
# bin check
RUN chain-bench -h
WORKDIR /home/chain-bench