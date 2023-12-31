# syntax=docker/dockerfile:1
# keycloak: Add authentication to applications and secure services with minimum effort.

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL org.opencontainers.image.name='Keycloak' \
    org.opencontainers.image.description='Open Source Identity and Access Management.' \
    org.opencontainers.image.usage='https://www.keycloak.org/guides' \
    org.opencontainers.image.url='https://www.keycloak.org/' \
    org.opencontainers.image.licenses='Apache License 2.0' \
    org.opencontainers.image.schema-version='22.0.5'
    
ARG BUILD_DATE
ARG VCS_REF
# https://csrc.nist.gov/projects/cryptographic-module-validation-program/certificate/4282
# https://www.openssl.org/source/fips-doc/openssl-3.0.8-security-policy-2023-05-05.pdf
ARG OPENSSL_VERSION=3.0.8

RUN \
    apk add --no-cache \
        bash \
        curl \
        gcompat \
        openjdk17-jre \
        tar \
        which; \
    apk add --no-cache -t .fips-deps \
        make \
        gcc \
        libgcc \
        musl-dev \
        linux-headers \
        perl \
        vim \
        wget; \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz; \
    tar -zxvf openssl-${OPENSSL_VERSION}.tar.gz; \
    cd openssl-${OPENSSL_VERSION}; \
    ./Configure \
        enable-fips \
        --libdir=lib \
        --prefix=/usr; \
    make; \
    make install_fips; \
    apk del --no-network --purge .fips-deps; \
    rm -rf openssl-${OPENSSL_VERSION}.tar.gz openssl-${OPENSSL_VERSION}; \
    addgroup -g 65533 keycloak; \
    adduser --shell /sbin/nologin --disabled-password -h /home/keycloak --uid 65533 --ingroup keycloak keycloak

FROM base AS download

ARG VER=22.0.5

# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
#ENV SNYK_API=

#run SCA scan against source code
#WORKDIR /tmp
#RUN set -x; \
#    apk add --no-cache -t .sca-deps npm unzip wget; \
#    wget https://github.com/keycloak/keycloak/releases/download/${VER}/keycloak-${VER}.zip; \
#    unzip keycloak-${VER}.zip; cd keycloak-${VER}; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /keycloak-code-review.html; \
#    snyk test --json | snyk-to-html -o /keycloak-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    apk del --purge .sca-deps; \
#    rm -rf /var/cache/apk/* /tmp/*

#unpack
WORKDIR /src

RUN \
    apk add --no-cache -t .keycloak-deps ca-certificates wget; \
    apk add --no-cache -t .av-scan clamav freshclam; \
    wget -qO- https://github.com/keycloak/keycloak/releases/download/${VER}/keycloak-${VER}.tar.gz \
    | tar zx; \
    wget -qO- https://github.com/keycloak/keycloak/releases/download/${VER}/keycloak-${VER}.tar.gz.sha1; \
    grep keycloak-${VER}.tar.gz keycloak-${VER}.tar.gz.sha1 | sha1sum -c; \
    mkdir /opt/keycloak; \
    mv /src/keycloak-${VER}/* /opt/keycloak; \
    rm -rf /tmp/*; \
    apk del --purge .keycloak-deps; \
    freshclam; \
    clamscan -rvi -l av_scan.log --exclude-dir="^/sys|^/dev" /; \
    apk del --no-network --purge .av-scan; \
    rm -rf /var/cache/apk/*

FROM base

ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk"

COPY --chown=keycloak:keycloak --from=download /opt/keycloak /opt/keycloak
#COPY --chown=keycloak:keycloak --from=download /keycloak-code-review.html /home/keycloak
#COPY --chown=keycloak:keycloak --from=download /keycloak-deps.html /home/keycloak
COPY --chown=keycloak:keycloak keycloak.conf /opt/keycloak/conf
COPY --chown=keycloak:keycloak --from=download /src/av_scan.log /home/keycloak
COPY --chmod=755 generate-ssl.sh /home/keycloak

RUN \
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    echo "fips.provider.7=XMLDSig" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"; \
    bash -c "/home/keycloak/certs/generate-ssl.sh"; \
    chmod +x /opt/keycloak/bin/kc.sh; \
    rm -rf /var/cache/apk/*; \
    chown -R keycloak:keycloak /home/keycloak /opt/keycloak; \
    chmod -R 750 /opt/keycloak; \
    # ensure keycloak.conf is filled out and postgres db container is built ready to connect to...
    # fips needs to be enabled on the host machine running this container
    # el9 based distro's: fips-mode-setup --enable; reboot
    /opt/keycloak/bin/kc.sh build --features=fips --fips-mode=strict

EXPOSE 8080 8443
USER keycloak   
WORKDIR /home/keycloak
HEALTHCHECK --timeout=5m --start-period=2m --retries=3 \
   CMD curl -fs http://localhost:8080 || curl -fsk https://localhost:8443 || exit 1
ENTRYPOINT [ "/opt/keycloak/bin/kc.sh", "start", "--optimized", "--https-port=8443" ]
