# syntax=docker/dockerfile:1
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

LABEL org.opencontainers.image.name='Yara' \
    org.opencontainers.image.description='The pattern matching swiss knife for malware researchers.' \
    org.opencontainers.image.usage='https://yara.readthedocs.io/en/stable/' \
    org.opencontainers.image.url='https://virustotal.github.io/yara/' \
    org.opencontainers.image.licenses='BSD 3-Clause "New" or "Revised" License' \
    org.opencontainers.image.vendor='VirusTotal' \
    org.opencontainers.image.schema-version='4.3.2' \
    MAINTAINER="@rw"

# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
#ENV SNYK_API=

ENV VER 4.3.2

RUN \
    apk add --no-cache \
        openssl \
        file \
        jansson \
        bison \
        su-exec \
        python3 \
        py3-pip; \
	\
    apk add --no-cache -t .yara-deps \
        gcc \
        g++ \
        musl-dev \
        linux-headers \
        python3-dev \
        openssl-dev \
        jansson-dev \
        build-base \
        npm \
        libc-dev \
        file-dev \
        automake \
        autoconf \
        libtool \
        flex \
        git; \
    cd /tmp; \
    git clone --recursive --branch v${VER} https://github.com/VirusTotal/yara.git; \
    cd yara; \
#    \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /yara-code-review.html; \
#    snyk test --json | snyk-to-html -o /yara-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    \
    ./bootstrap.sh; \
    sync; \
    ./configure \
    --with-crypto \
    --disable-shared \
    --enable-magic \
    --enable-cuckoo \
    --enable-dotnet; \
    make; \
    make install; \
    \
    git clone --recursive https://github.com/VirusTotal/yara-python; \
    cd yara-python; \
    python3 setup.py build --dynamic-linking; \
    python3 setup.py install; \
    \
    mkdir /rules; \
    rm -rf /tmp/*; \
    cd /; \
    apk del --purge .yara-deps; \
    \
    addgroup -g 65535 yara; \
    adduser --disabled-password \
    -h /home/yara --uid 65535 --ingroup yara yara

COPY --chown=yara:yara /rules /rules
COPY --chown=yara:yara include_rules.yar /rules
COPY --chown=yara:yara /iocs /iocs

WORKDIR /rules
#RUN python3 build-rules.py
VOLUME /malware
VOLUME /rules
WORKDIR /malware
USER yara
