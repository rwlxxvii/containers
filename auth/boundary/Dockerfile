# syntax=docker/dockerfile:1
# boundary: provides access to applications and critical systems with fine-grained authorizations without managing credentials or exposing your network.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    apk add --no-cache \
        dumb-init \
        su-exec \
        iputils \
        libc6-compat \
        iptables \
        tzdata \
        wget \
        clamav \
        freshclam

FROM base AS build-env

ENV PRODUCT_VERSION=0.14.2 \
    GPG_KEY=C874011F0AB405110D02105534365D9472D7468F \
    SNYK_API=
    
RUN \
    apk add --no-cache -t .boundary-deps \
        ca-certificates \
        gnupg \
        openssl \
        unzip; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in armhf) ARCH='arm' ;; \
      aarch64) ARCH='arm64' ;; \
      x86_64) ARCH='amd64' ;; \
      x86) ARCH='386' ;; \
      *) echo >&2 "error: unsupported architecture: $apkArch"; \
      exit 1 ;; \
    esac; \
    found=''; \
    for server in \
      hkps://keys.openpgp.org \
      hkps://keyserver.ubuntu.com \
      hkps://pgp.mit.edu; do \
      echo "Fetching GPG key $GPG_KEY from $server"; \
      gpg --batch --keyserver "$server" --recv-keys "$GPG_KEY"; \
      found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEY" && exit 1; \
    mkdir -p /tmp/build; \
    cd /tmp/build; \
    wget https://releases.hashicorp.com/boundary/${PRODUCT_VERSION}/boundary_${PRODUCT_VERSION}_linux_${ARCH}.zip; \
    wget https://releases.hashicorp.com/boundary/${PRODUCT_VERSION}/boundary_${PRODUCT_VERSION}_SHA256SUMS; \
    wget https://releases.hashicorp.com/boundary/${PRODUCT_VERSION}/boundary_${PRODUCT_VERSION}_SHA256SUMS.sig; \
    gpg --batch --verify boundary_${PRODUCT_VERSION}_SHA256SUMS.sig boundary_${PRODUCT_VERSION}_SHA256SUMS; \
    grep boundary_${PRODUCT_VERSION}_linux_${ARCH}.zip boundary_${PRODUCT_VERSION}_SHA256SUMS | sha256sum -c; \
    unzip -d /tmp/build boundary_${PRODUCT_VERSION}_linux_${ARCH}.zip; \
    cp /tmp/build/boundary /bin/boundary; \
    rm -rf /tmp/build; \
    gpgconf --kill dirmngr; \
    gpgconf --kill gpg-agent; \
    apk del --purge .boundary-deps; \
    rm -rf /root/.gnupg /var/cache/apk/*

#run SCA scan against source code
#WORKDIR /tmp
#RUN set -x; \
#    apk add --no-cache -t .sca-deps npm unzip wget; \
#    wget https://github.com/hashicorp/boundary/archive/refs/heads/main.zip; \
#    unzip main.zip; cd boundary-main/boundary/cmd/boundary/; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /boundary-code-review.html; \
#    snyk test --json | snyk-to-html -o /boundary-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    apk del --purge .sca-deps; \
#    rm -rf /var/cache/apk/* /tmp/*

FROM base

LABEL org.opencontainers.image.name='Hashicorp Boundary' \
    org.opencontainers.image.description='Simple and secure remote access.' \
    org.opencontainers.image.usage='https://developer.hashicorp.com/boundary/docs' \
    org.opencontainers.image.url='https://www.boundaryproject.io/' \
    org.opencontainers.image.vendor='Hashicorp' \
    org.opencontainers.image.licenses='Mozilla Public License 2.0' \
    org.opencontainers.image.schema-version='0.14.2' \
    MAINTAINER="@rw"
    
RUN \
    addgroup -g 65535 boundary; \
    adduser --shell /sbin/nologin --disabled-password -h /home/boundary --uid 65535 --ingroup boundary boundary; \
    mkdir /boundary
    
COPY --chown=boundary:boundary --from=build-env /bin/boundary /usr/local/bin/
#COPY --chown=boundary:boundary --from=build-env /boundary-deps.html /home/boundary
#COPY --chown=boundary:boundary --from=build-env /boundary-code-review.html /home/boundary
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config.hcl /boundary/config.hcl

RUN \
    freshclam; \
    clamscan -r -v -i -l /home/boundary/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown boundary:boundary /home/boundary/last_scan.log; \
    grep -Hrn FOUND /home/boundary/last_scan.log; \
    apk del --no-network clamav freshclam; \
    rm -rf /var/cache/apk/*; \
    chown -R boundary:boundary /boundary; \
    chmod -R 640 /boundary/*
    
VOLUME /boundary
EXPOSE 9200 9201 9202
USER boundary
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "bin/sh", "-c", "boundary server -config /boundary/config.hcl" ]
