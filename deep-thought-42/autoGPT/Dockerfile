# syntax=docker/dockerfile:1
# autogpt: An experimental open-source attempt to make GPT-4 fully autonomous.
# https://docs.agpt.co
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV OPENAI_KEY=" " \
    PATH="${PATH}:/AutoGPT/autogpt/bin" \
    SNYK_API=" "

RUN \
    apk add --no-cache \
       bash \
       curl \
       git \
       python3 \
       py3-pip; \
    \
    apk add --no-cache -t .extra-things \
       npm \
       clamav \
       freshclam; \
    \
    apk add --no-cache -t .commonlib-deps \
       ca-certificates \
       rust \
       cargo \
       gcc \
       g++ \
       musl-dev \
       linux-headers \
       python3-dev; \
    \
    git clone https://github.com/Significant-Gravitas/AutoGPT.git; cd AutoGPT; \
    #npm install -g snyk; \
    #npm install -g snyk-to-html; \
    #snyk config set api=${SNYK_API}; \
    #snyk code test --json | snyk-to-html -o /autogpt-code-review.html; \
    #snyk test --all-projects --json | snyk-to-html -o /autogpt-deps.html; \
    #snyk monitor; \
    #npm uninstall -g snyk; \
    #npm uninstall -g snyk-to-html; \
    python3 -m venv autogpt; \
    . autogpt/bin/activate; \
    python3 -m pip --no-cache-dir install --upgrade pip; \
    python3 -m pip --no-cache-dir install --upgrade openai; \
    \
    export OPENAI_API_KEY=${OPENAI_KEY}; \
    chmod 755 setup.sh; ./setup.sh; \
    chmod 755 run; ./run; \
    \
    apk del --no-network --purge .commonlib-deps; \
    \
    addgroup -g 65535 autogpt; \
    adduser --shell /sbin/nologin --disabled-password -h /home/autogpt --uid 65535 --ingroup autogpt autogpt; \
    \
    freshclam; \
    clamscan -rvi -l /home/autogpt/clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown autogpt:autogpt /home/autogpt/clamav_scan.log; \
    grep -Hrn " FOUND" /home/autogpt/clamav_scan.log; \
    \
    apk del --no-network --purge .extra-things; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    chown -R autogpt:autogpt /AutoGPT

WORKDIR /AutoGPT/
USER autogpt
CMD [ "bash" ]
