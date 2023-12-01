# syntax=docker/dockerfile:1
# vault: Secure, store, and tightly control access to tokens, passwords, certificates, and encryption keys for protecting secrets and other sensitive data using a UI, CLI, or HTTP API.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    apk add --no-cache \
        libcap \
        su-exec \
        dumb-init \
        procps \
        tzdata \
        clamav \
        freshclam

FROM base AS build-env

ENV VAULT_VER=1.15.2 \
    VAULT_GPGKEY=C874011F0AB405110D02105534365D9472D7468F \
    SNYK_API=
    
RUN \
    apk add --no-cache -t .vault-deps \
        ca-certificates \
        gnupg \
        openssl \
        unzip \
        wget; \
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
      echo "Fetching GPG key $VAULT_GPGKEY from $server"; \
      gpg --batch --keyserver "$server" --recv-keys "$VAULT_GPGKEY"; \
      found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $VAULT_GPGKEY" && exit 1; \
    mkdir -p /tmp/build; \
    cd /tmp/build; \
    wget https://releases.hashicorp.com/vault/${VAULT_VER}/vault_${VAULT_VER}_linux_${ARCH}.zip; \
    wget https://releases.hashicorp.com/vault/${VAULT_VER}/vault_${VAULT_VER}_SHA256SUMS; \
    wget https://releases.hashicorp.com/vault/${VAULT_VER}/vault_${VAULT_VER}_SHA256SUMS.sig; \
    gpg --batch --verify vault_${VAULT_VER}_SHA256SUMS.sig vault_${VAULT_VER}_SHA256SUMS; \
    grep vault_${VAULT_VER}_linux_${ARCH}.zip vault_${VAULT_VER}_SHA256SUMS | sha256sum -c; \
    unzip -d /tmp/build vault_${VAULT_VER}_linux_${ARCH}.zip; \
    cp /tmp/build/vault /bin/vault; \
    rm -rf /tmp/build; \
    gpgconf --kill dirmngr; \
    gpgconf --kill gpg-agent; \
    apk del --no-network --purge .vault-deps; \
    rm -rf /root/.gnupg /var/cache/apk/*

#run SCA scan against source code
#WORKDIR /tmp
#RUN set -x; \
#    apk add --no-cache -t .sca-deps npm unzip wget; \
#    wget https://github.com/hashicorp/vault/archive/refs/heads/main.zip; \
#    unzip main.zip; cd vault-main/command; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /vault-code-review.html; \
#    snyk test --json | snyk-to-html -o /vault-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    apk del --purge .sca-deps; \
#    rm -rf /var/cache/apk/* /tmp/*

FROM base

LABEL org.opencontainers.image.name='Hashicorp Vault' \
    org.opencontainers.image.description='Vault is an identity-based secret and encryption management system.' \
    org.opencontainers.image.usage='https://developer.hashicorp.com/vault/docs' \
    org.opencontainers.image.url='https://www.hashicorp.com/products/vault' \
    org.opencontainers.image.vendor='Hashicorp' \
    org.opencontainers.image.licenses='Mozilla Public License 2.0' \
    org.opencontainers.image.schema-version='1.15.2' \
    MAINTAINER="@rw"
    
RUN \
    addgroup -g 65535 vault; \
    adduser --shell /sbin/nologin --disabled-password -h /home/vault --uid 65535 --ingroup vault vault; \
    mkdir -p /vault/logs; \
    mkdir -p /vault/file; \
    mkdir -p /vault/config; \
    chown -R vault:vault /vault; \
    chgrp -R 0 /vault; \
    chmod -R g+rwX /vault
    
COPY --chown=vault:vault --from=build-env /bin/vault /usr/local/bin/
#COPY --chown=vault:vault --from=build-env /vault-deps.html /home/vault
#COPY --chown=vault:vault --from=build-env /vault-code-review.html /home/vault
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN \
    freshclam; \
    clamscan -rvi -l /home/vault/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown vault:vault /home/vault/last_scan.log; \
    grep -Hrn " FOUND" /home/vault/last_scan.log; \
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*
    
VOLUME /vault/logs
VOLUME /vault/file
EXPOSE 8200
USER vault
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "bin/sh", "-c", "vault server -dev" ]
