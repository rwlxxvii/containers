# syntax=docker/dockerfile:1
# open-interpreter: Generates and runs code (Python, Javascript, Shell, and more) locally, based off your prompts.
# Without openapi, default model is Code-Llama. Obtain openapi key to use GPT4.
# podman build -t interpreter .; podman run --rm -it --name interpreter interpreter

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV API_KEY=" " \
    PATH="${PATH}:/open-interpreter/bin" \
    SNYK_API=" "

RUN \
    apk add --no-cache -t .terp-deps \
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
    # git clone https://github.com/KillianLucas/open-interpreter.git; cd open-interpreter; \
    # npm install -g snyk; \
    # npm install -g snyk-to-html; \
    # snyk config set api=${SNYK_API}; \
    # snyk code test --json | snyk-to-html -o /open-interpreter-code-review.html; \
    # snyk test --json | snyk-to-html -o /open-interpreter-deps.html; \
    # snyk monitor; \ 
    # npm uninstall -g snyk; \
    # npm uninstall -g snyk-to-html; \
    # cd ..; rm -rf ./open-interpreter; \
    \
    apk add --no-cache python3 py3-pip; \
    python3 -m venv open-interpreter; \
    . open-interpreter/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install --upgrade open-interpreter; \
    python3 -m pip install --upgrade guardrails-ai; \
    \
    addgroup -g 65535 interpreter; \
    adduser --shell /sbin/sh --disabled-password -h /home/terp --uid 65535 --ingroup interpreter terp; \
    \
    freshclam; \
    clamscan -rvi -l /home/terp/last_scan.log --exclude-dir="^/sys" /; \
    chown terp:interpreter /home/terp/last_scan.log; \
    grep -Hrn " FOUND" /home/terp/last_scan.log; \
    \
    apk del --purge .terp-deps; \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    \
    export OPENAI_API_KEY=${API_KEY}; \
    chown -R terp:interpreter /open-interpreter/
    
VOLUME /data
WORKDIR /data
RUN chown -R terp:interpreter /data
USER terp
ENTRYPOINT [ "/bin/sh", "-c", "interpreter" ]
CMD [ "-y" ]
