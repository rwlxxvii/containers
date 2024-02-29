# gotestwaf: GoTestWAF is a tool for API and OWASP attack simulation that supports a wide range of API protocols including REST, GraphQL, gRPC, WebSockets, SOAP, XMLRPC, and others.
# It was designed to evaluate web application security solutions, such as API security proxies, Web Application Firewalls, IPS, API gateways, and others.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS build-env

ENV GOPATH=/usr/local/bin/go \
    SNYK_API

RUN \
    apk add --no-cache -t .gotestwaf-deps \
        gcc \
        git \
        make \
        linux-headers \
        musl-dev \
        go \
        npm; \
    mkdir -p ${GOPATH}/src/github.com/gotestwaf; \
    cd ${GOPATH}/src/github.com/gotestwaf; \
    git clone https://github.com/wallarm/gotestwaf.git; \
    cd gotestwaf; \
    cp -R testcases /; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /gotestwaf-code-review.html; \
#    snyk test --all-projects --json | snyk-to-html -o /gotestwaf-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    cd cmd; \
    export GO111MODULE=on; \
    go install; \
    apk del --purge .gotestwaf-deps; \
    rm -rf ${GOPATH}/src/github.com
    
FROM ${repo}/${base_image}@sha256:${image_hash}

RUN \
    apk add --no-cache \
        tini \
        chromium \
        font-inter \
        font-iosevka \
        fontconfig \
        clamav \
        freshclam; \
    addgroup -g 65535 gotestwaf; \
    adduser --shell /sbin/nologin --disabled-password -h /home/gotestwaf --uid 65535 --ingroup gotestwaf gotestwaf; \
    fc-cache -fv; \
    mkdir -p /home/gotestwaf/reports; \
    chown -R gotestwaf:gotestwaf /home/gotestwaf/reports

WORKDIR /home/gotestwaf

#COPY --chown=gotestwaf:gotestwaf --from=build-env /gotestwaf-code-review.html .
#COPY --chown=gotestwaf:gotestwaf --from=build-env /gotestwaf-deps.html .
COPY --chmod=755 --from=build-env /usr/local/bin/go/bin/ .
COPY --chown=gotestwaf:gotestwaf --from=build-env /testcases .
COPY --chown=gotestwaf:gotestwaf config.yaml .

RUN \
    freshclam; \
    clamscan -rvi -l last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown gotestwaf:gotestwaf last_scan.log; \
    grep -Hrn " FOUND" last_scan.log; \ 
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*
    
USER gotestwaf
VOLUME [ "/home/gotestwaf/reports" ]
ENTRYPOINT [ "/sbin/tini", "--", "/home/gotestwaf/gotestwaf" ]
