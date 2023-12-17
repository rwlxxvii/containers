# syntax=docker/dockerfile:1
# nuclei: Fast and customizable vulnerability scanner based on simple YAML based DSL.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='Nuclei' \
    org.opencontainers.image.description='Fast and extensible vulnerability scanner in golang' \
    org.opencontainers.image.usage='https://github.com/projectdiscovery/nuclei/blob/main/README.md' \
    org.opencontainers.image.url='https://projectdiscovery.io/#/' \
    org.opencontainers.image.vendor='Project Discovery' \
    org.opencontainers.image.licenses='MIT' \
    org.opencontainers.image.schema-version='3.1.1'
    
RUN \
    apk add --no-cache \
        bash \
        bind-tools \
        ca-certificates \
        chromium

FROM base AS go-builder

ENV GOPATH=/usr/local/bin/go \
    VER=3.1.1 \
    SNYK_API=

RUN \
    apk add --no-cache -t .nuclei-deps \
        build-base \
        ca-certificates \
        go \
        git \
        npm; \
    apk add --no-cache -t .av-scan \
        clamav \
        freshclam; \
    mkdir -p ${GOPATH}/src/github.com/nuclei; \
    cd ${GOPATH}/src/github.com/nuclei; \
    git clone --depth 1 --branch v${VER} https://github.com/projectdiscovery/nuclei; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
    cd nuclei/; \
#    snyk code test --json | snyk-to-html -o /nuclei-code-review.html; \
#    snyk test --json | snyk-to-html -o /nuclei-deps.html; \
#    snyk monitor; \ 
    cd cmd/nuclei/; \      
    export GO111MODULE=on; \
    go install; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    apk del --no-network --purge .nuclei-deps; \
    freshclam; \
    clamscan -rvi -l /clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    grep -Hrn FOUND /clamav_scan.log; \
    apk del --no-network --purge .av-scan; \
    rm -rf /var/cache/apk/*; \
    rm -rf ${GOPATH}/src/
    
FROM base

RUN \
    addgroup -g 65535 nuclei; \
    adduser --shell /sbin/nologin --disabled-password -h /home/nuclei --uid 65535 --ingroup nuclei nuclei

COPY --chown=nuclei:nuclei --from=go-builder /usr/local/bin/go/bin/nuclei /usr/local/bin/
COPY --chown=nuclei:nuclei --from=go-builder /clamav_scan.log /home/nuclei
#COPY --chown=nuclei:nuclei --from=go-builder /nuclei-code-review.html /home/nuclei
#COPY --chown=nuclei:nuclei --from=go-builder /nuclei-deps.html /home/nuclei

# example scan to run for function check, updating the templates will increase image size...
#RUN \
#    DATE=$(date +"%Y%m%d"); \
#    MODE=http; \
#    TARGET=testhtml5.vulnweb.com; \
#    THREADS=35; \
#    nuclei -ut; \
#    nuclei -c $THREADS -ni -u ${MODE}://${TARGET} -o /home/nuclei/nuclei-${MODE}-${TARGET}-${DATE}.log; \
#    cat /home/nuclei/nuclei-${MODE}-${TARGET}-${DATE}.log

# podman exec nuclei nuclei -ut to update templates.
WORKDIR /home/nuclei
USER nuclei
CMD [ "bash" ]
