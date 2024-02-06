# syntax=docker/dockerfile:1
# deeplake: Database for AI powered by a storage format optimized for deep-learning applications.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV API_KEY=" " \
    PATH="${PATH}:/deeplake/bin" \
    SNYK_API=" "

RUN \
    apk add --no-cache -t .deeplake-deps \
        ca-certificates \
        rust \
        cargo \
        gcc \
        g++ \
        musl-dev \
        linux-headers \
        python3-dev \
        npm \
        git \
        clamav \
        freshclam; \
    \
    # git clone https://github.com/activeloopai/deeplake.git; cd deeplake; \
    # npm install -g snyk; \
    # npm install -g snyk-to-html; \
    # snyk config set api=${SNYK_API}; \
    # snyk code test --json | snyk-to-html -o /deeplake-code-review.html; \
    # snyk test --all-projects --json | snyk-to-html -o /deeplake-deps.html; \
    # snyk monitor; \ 
    # cd ..; rm -rf ./deeplake; \
    # git clone https://github.com/openai/openai-python.git; cd openai-python; \
    # snyk code test --json | snyk-to-html -o /openai-code-review.html; \
    # snyk test --all-projects --json | snyk-to-html -o /openai-deps.html; \
    # snyk monitor; \ 
    # cd ..; rm -rf ./openai-python; \
    # npm uninstall -g snyk; \
    # npm uninstall -g snyk-to-html; \
    # \
    apk add --no-cache \
        bash \
        gcompat \
        python3 \
        py3-pip \
        tzdata; \
    \
    python3 -m venv deeplake; \
    . deeplake/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install --upgrade "deeplake[all]"; \
    python3 -m pip install --upgrade openai; \
    \
    addgroup -g 65535 deeplake; \
    adduser --shell /sbin/sh --disabled-password -h /home/deeplake --uid 65535 --ingroup deeplake deeplake; \
    \
    freshclam; \
    clamscan -rvi -l /home/deeplake/last_scan.log --exclude-dir="^/sys" /; \
    chown deeplake:deeplake /home/deeplake/last_scan.log; \
    grep -Hrn " FOUND" /home/deeplake/last_scan.log; \
    \
    apk del --purge .deeplake-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    \
    export OPENAI_API_KEY=${API_KEY}

USER deeplake
CMD [ "bash" ]
