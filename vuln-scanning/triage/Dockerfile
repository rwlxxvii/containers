# syntax=docker/dockerfile:1
# triage: a modern malware sandbox service.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="d695c3de6fcd8cfe3a6222b0358425d40adfd129a8a47c3416faff1a8aece389"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV API_KEY= \
    PATH="${PATH}:/tmp/triage/bin" \
    SNYK_API=

RUN \
    apk add --no-cache -t .triage-deps ca-certificates \
                                        rust \
                                        cargo \
                                        gcc \
                                        g++ \
                                        musl-dev \
                                        linux-headers \
                                        python3-dev \
                                        unzip \
                                        wget \
                                        npm \
                                        clamav \
                                        freshclam; \
                        wget https://github.com/hatching/triage/archive/refs/heads/main.zip; \
                        unzip main.zip; \
                        cd triage-main/python; \                
                        # npm install -g snyk; \
                        # npm install -g snyk-to-html; \
                        # snyk config set api=${SNYK_API}; \
                        # snyk code test --json | snyk-to-html -o /triage-code-review.html; \
                        # snyk test --all-projects --json | snyk-to-html -o /triage-deps.html; \
                        # snyk monitor; \ 
                        # npm uninstall -g snyk; \
                        # npm uninstall -g snyk-to-html; \
    apk add --no-cache python3 py3-pip; \
    python3 -m venv triage; \
    . triage/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install .; \
    addgroup -g 65535 triage; \
    adduser --shell /sbin/sh --disabled-password -h /home/triage --uid 65535 --ingroup triage triage; \
    freshclam; \
    clamscan -rvi -l /home/triage/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown triage:triage /home/triage/last_scan.log; \
    grep -Hrn " FOUND" /home/triage/last_scan.log; \ 
    apk del --purge .triage-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    triage authenticate ${API_KEY}; \
    chown -R triage:triage /triage/

WORKDIR /home/triage/files
USER triage
CMD [ "sh" ]
