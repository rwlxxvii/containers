# syntax=docker/dockerfile:1
# litellm: Call all LLM APIs using the OpenAI format [Anthropic, Huggingface, Cohere, TogetherAI, Azure, OpenAI, etc.]
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV OPENAPI_KEY=" " \
    COHEREAPI_KEY=" " \
    PATH="${PATH}:/litellm/bin" \
    SNYK_API= " "

RUN \
    apk add --no-cache -t .litellm-deps \
        ca-certificates \
        rust \
        cargo \
        gcc \
        g++ \
        musl-dev \
        linux-headers \
        python3-dev \
        clamav \
        freshclam \
        git \
        npm; \
    \
    # git clone https://github.com/BerriAI/litellm.git; cd litellm; \
    # npm install -g snyk; \
    # npm install -g snyk-to-html; \
    # snyk config set api=${SNYK_API}; \
    # snyk code test --json | snyk-to-html -o /litellm-code-review.html; \
    # snyk test --all-projects --json | snyk-to-html -o /litellm-deps.html; \
    # snyk monitor; \ 
    # npm uninstall -g snyk; \
    # npm uninstall -g snyk-to-html; \
    # cd ..; rm -rf ./litellm; \
    \
    apk add --no-cache python3 py3-pip; \      
    python3 -m venv litellm; \
    . litellm/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install --upgrade litellm; \
    \
    addgroup -g 65535 litellm; \
    adduser --shell /sbin/sh --disabled-password -h /home/litellm --uid 65535 --ingroup litellm litellm; \
    \
    freshclam; \
    clamscan -rvi -l /home/litellm/last_scan.log --exclude-dir="^/sys" /; \
    chown litellm:litellm /home/litellm/last_scan.log; \
    grep -Hrn " FOUND" /home/litellm/last_scan.log; \
    \
    apk del --purge .litellm-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    \
    export OPENAI_API_KEY=${OPENAPI_KEY}; \
    export COHERE_API_KEY=${COHEREAPI_KEY}; \
    chown -R litellm:litellm /litellm

USER litellm
CMD [ "sh" ]
