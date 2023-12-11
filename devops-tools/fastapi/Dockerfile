# syntax=docker/dockerfile:1
# fastapi: a modern, fast (high-performance), web framework for building APIs with Python 3.8+ based on standard Python type hints.

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV PATH="${PATH}:/fastapi/bin"
#ENV SNYK_API=" "

RUN \
    apk add --no-cache -t .fastapi-deps \
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
  # snyk souce code/deps scans
  # mkdir /src; cd /src; \
  # git clone https://github.com/rwlxxvii/fastapi.git; cd fastapi; \
  # npm install -g snyk; \
  # npm install -g snyk-to-html; \
  # snyk config set api=${SNYK_API}; \
  # snyk code test --json | snyk-to-html -o /fastapi-code-review.html; \
  # snyk test --json | snyk-to-html -o /fastapi-deps.html; \
  # snyk monitor; \ 
  # npm uninstall -g snyk; \
  # npm uninstall -g snyk-to-html; \
  # cd ../..; rm -rf /src/fastapi; \
  # fastapi/uvicorn install via pip
  apk add --no-cache python3 py3-pip; \
  python3 -m venv fastapi; \
  . fastapi/bin/activate; \
  python3 -m pip install --upgrade pip; \
  python3 -m pip install --upgrade fastapi; \
  python3 -m pip install --upgrade "uvicorn[standard]"; \
  # fastapi user
  addgroup -g 65535 fastapi; \
  adduser --shell /sbin/sh --disabled-password -h /home/fastapi --uid 65535 --ingroup fastapi fastapi; \
  # anti-malware scan
  freshclam; \
  clamscan -rvi -l /home/fastapi/last_scan.log --exclude-dir="^/sys" /; \
  chown fastapi:fastapi /home/fastapi/last_scan.log; \
  grep -Hrn " FOUND" /home/fastapi/last_scan.log; \
  # cleanup
  apk del --no-network --purge .fastapi-deps; \
  rm -rf /var/cache/apk/* /root/.cache/*

# load api service for uvicorn to start, following api is an example
ADD /api-example/ /fastapi/
RUN chown -R fastapi:fastapi /fastapi

WORKDIR /fastapi/api-example
RUN python3 -m pip install -r requirements.txt
USER fastapi
EXPOSE 8000
ENTRYPOINT [ "/bin/sh", "-c", "uvicorn" ]
CMD [ "main:app, --reload" ]
