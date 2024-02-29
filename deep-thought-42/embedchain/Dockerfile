# syntax=docker/dockerfile:1
# embedchain: Embedchain is a framework to easily create LLM powered bots over any dataset.
# https://embedchain.ai/
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV PATH="${PATH}:/embedchain/bin" \
    SNYK_API=" "

RUN \
    apk add --no-cache -t .embedchain-deps \
        ca-certificates \
        rust \
        cargo \
        gcc \
        g++ \
        musl-dev \
        linux-headers \
        python3-dev \
        git \
        npm \
        clamav \
        freshclam; \
    \
    # git clone https://github.com/embedchain/embedchain.git; cd embedchain; \
    # npm install -g snyk; \
    # npm install -g snyk-to-html; \
    # snyk config set api=${SNYK_API}; \
    # snyk code test --json | snyk-to-html -o /embedchain-code-review.html; \
    # snyk test --json | snyk-to-html -o /embedchain-deps.html; \
    # snyk monitor; \ 
    # npm uninstall -g snyk; \
    # npm uninstall -g snyk-to-html; \
    # cd ..; rm -rf ./embedchain; \
    \
    apk add --no-cache python3 py3-pip; \
    python3 -m venv embedchain; \
    . embedchain/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install --upgrade embedchain; \
    \
    addgroup -g 65535 embedchain; \
    adduser --shell /sbin/sh --disabled-password -h /home/embedchain --uid 65535 --ingroup embedchain embedchain; \
    \
    freshclam; \
    clamscan -rvi -l /home/embedchain/last_scan.log --exclude-dir="^/sys" /; \
    chown embedchain:embedchain /home/embedchain/last_scan.log; \
    grep -Hrn " FOUND" /home/embedchain/last_scan.log; \
    \
    apk del --purge .embedchain-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    chown -R embedchain:embedchain /embedchain

USER embedchain
CMD [ "sh" ]
