# syntax=docker/dockerfile:1
# kube-bench: Checks whether Kubernetes is deployed according to security best practices as defined in the CIS Kubernetes Benchmark.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS build-env

ENV GOPATH=/usr/local/bin/go \
    KBENCH_VER=0.6.19 \
    SNYK_API=

RUN \
    apk add --no-cache -t .kbench-deps ca-certificates \
                                        go \
                                        git \
                                        npm; \
    mkdir -p ${GOPATH}/src/github.com/kube-bench; \
    cd ${GOPATH}/src/github.com/kube-bench; \
    git clone --depth 1 --branch v${KBENCH_VER} https://github.com/aquasecurity/kube-bench; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
    cd kube-bench/; \
#    snyk code test --json | snyk-to-html -o /kbench-code-review.html; \
#    snyk test --all-projects --json | snyk-to-html -o /kbench-deps.html; \
#    snyk monitor; \ 
    go install; \
    rm -rf ${GOPATH}/src/github.com

FROM ${base_image}

ENV PATH=$PATH:/usr/local/mount-from-host/bin \
    RUNNING_IN_A_CONTAINER=true
    
RUN \
    apk add --no-cache -t .av-scan clamav freshclam wget; \
    addgroup -g 65535 kbench; \
    adduser -h /home/kbench --shell /bin/true --disabled-password --uid 65535 --ingroup kbench --gecos '' kbench; \
    sed -i -r "/^(kbench|root)/!d" /etc/group /etc/passwd; \
    sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd; \
    mkdir -p /host/cfg/; \
    apk --no-cache upgrade apk-tools; \
    apk --no-cache add procps \
                        openssl \
                        jq; \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    apk add --no-cache gcompat
    
COPY --chmod=755 --from=build-env /usr/local/bin/go/bin/ /usr/local/bin
#COPY --chown=kbench:kbench --from=build-env /kbench-code-review.html /home/kbench
#COPY --chown=kbench:kbench --from=build-env /kbench-deps.html /home/kbench
COPY --chown=kbench:kbench cfg/ /host/cfg

WORKDIR /home/kbench/

RUN \
    freshclam; \
    clamscan -rvi -l last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown kbench:kbench last_scan.log; \
    grep -Hrn " FOUND" last_scan.log; \ 
    apk del --purge .av-scan; \
    rm -rf /var/cache/apk/*; \
    cp -rf /usr/local/bin/kube-bench /host/

VOLUME /usr/local/mount-from-host/bin
RUN chown -R kbench:kbench /host
USER 65535
RUN kube-bench version
CMD [ "sh" ]
