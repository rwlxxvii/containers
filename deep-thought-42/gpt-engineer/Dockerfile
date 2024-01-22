# syntax=docker/dockerfile:1
# gpt-engineer: GPT Engineer is made to be easy to adapt, extend, and make your agent learn how you want your code to look. It generates an entire codebase based on a prompt.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV OPENAI_KEY=" " \
    PATH="${PATH}:/gpt-engineer/bin" \
    SNYK_API=" "
    
RUN \
    apk add --no-cache -t .gpt-engineer-deps \
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
    # Static code analysis and composition analysis 
    #git clone https://github.com/AntonOsika/gpt-engineer.git; cd gpt-engineer; \
    #npm install -g snyk; \
    #npm install -g snyk-to-html; \
    #snyk config set api=${SNYK_API}; \
    #snyk code test --json | snyk-to-html -o /gpt-engineer-code-review.html; \
    #snyk test --json | snyk-to-html -o /gpt-engineer-deps.html; \
    #snyk monitor; \ 
    #npm uninstall -g snyk; \
    #npm uninstall -g snyk-to-html; \
    #cd ..; rm -rf ./gpt-engineer; \
    \
    apk add --no-cache bash python3 py3-pip; \
    python3 -m venv gpt-engineer; \
    . gpt-engineer/bin/activate; \
    python3 -m pip install --no-cache-dir --upgrade pip; \
    python3 -m pip install --no-cache-dir --upgrade gpt-engineer; \
    \
    addgroup -g 65535 gpt-engineer; \
    adduser --shell /sbin/nologin --disabled-password -h /home/gpt-engineer --uid 65535 --ingroup gpt-engineer gpt-engineer; \
    \
    freshclam; \
    clamscan -rvi -l /home/gpt-engineer/clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown gpt-engineer:gpt-engineer /home/gpt-engineer/clamav_scan.log; \
    grep -Hrn " FOUND" /home/gpt-engineer/clamav_scan.log; \
    \
    apk del --no-network --purge .gpt-engineer-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    \
    export OPENAI_API_KEY=${OPENAI_KEY}; \
    chown -R gpt-engineer:gpt-engineer /gpt-engineer/

COPY --chmod=755 entrypoint.sh .
VOLUME /project
WORKDIR /project
RUN chown -R gpt-engineer:gpt-engineer /project
USER gpt-engineer
ENTRYPOINT [ "/entrypoint.sh" ]
