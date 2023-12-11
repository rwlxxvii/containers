# syntax=docker/dockerfile:1
# atmos: Workflow automation tool for DevOps.
# https://atmos.tools/quick-start

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

ENV AWS_SDK_LOAD_CONFIG=1
ENV AWS_DEFAULT_REGION=us-west-1

RUN \
    apk add --no-cache \
        aws-cli \
        bash \
        helm \
        terraform; \
    apk add --no-cache kubectl --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community; \
    addgroup -g 65535 atmos; \
    adduser --shell /sbin/nologin --disabled-password -h /.atmos --uid 65535 --ingroup atmos atmos; \
    mkdir -p /stacks/workflows /components/terraform /usr/local/etc/atmos /home/atmos; \
    chown -R atmos:atmos /stacks/workflows /components/terraform /usr/local/etc/atmos /home/atmos

FROM base AS go-builder

ENV GOPATH=/usr/local/bin/go \
    ATMOS_VER=1.50.0
    
#ENV SNYK_API

RUN \
    apk add --no-cache -t .build-deps \
        ca-certificates \
        go \
        git \
        make \
        npm; \
    \
    mkdir -p ${GOPATH}/src/github.com/cloudposse ${GOPATH}/src/github.com/hashicorp; \
    cd ${GOPATH}/src/github.com/cloudposse; \
    git clone --depth 1 --branch v${ATMOS_VER} https://github.com/cloudposse/atmos; \
    cd atmos/; \
    mv examples /; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /atmos-code-review.html; \
#    snyk test --json | snyk-to-html -o /atmos-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    go install golang.org/x/tools/gopls@latest; \
    go install; \
    apk del --purge .build-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM base

COPY --chown=atmos:atmos atmos.yml /usr/local/etc/atmos/atmos.yaml
COPY --chown=atmos:atmos rootfs/etc/profile.d/set-eks-cluster.sh /etc/profile.d/
COPY --chown=atmos:atmos --from=go-builder /usr/local/bin/go/bin/ /usr/local/bin
COPY --chown=atmos:atmos --from=go-builder /examples/complete /home/atmos
#COPY --chown=atmos:atmos --from=go-builder /atmos-code-review.html /home/atmos
#COPY --chown=atmos:atmos --from=go-builder /atmos-deps.html /home/atmos

VOLUME [ "/stacks", "/components" ]
USER atmos
# bin check
RUN atmos -h; terraform -help; helm -h
WORKDIR /home/atmos