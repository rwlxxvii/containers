# syntax=docker/dockerfile:1
# qdrant: a vector similarity search engine and vector database.

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV PATH="${PATH}:/qdrant/bin" \
    TINI_VERSION "v0.19.0" \
    SNYK_API=" "

RUN \
    apk add --no-cache -t .build-deps \
      pkgconf-dev \
      libc6-compat \
      libunwind-dev \
      rust \
      cargo \
      gcc \
      g++ \
      musl-dev \
      linux-headers \
      python3-dev \
      npm \
      git; \
    # \
    # git clone https://github.com/qdrant/qdrant.git; cd qdrant; \
    # npm install -g snyk; \
    # npm install -g snyk-to-html; \
    # snyk config set api=${SNYK_API}; \
    # snyk code test --json | snyk-to-html -o /qdrant-code-review.html; \
    # snyk test --json | snyk-to-html -o /qdrant-deps.html; \
    # snyk monitor; \ 
    # npm uninstall -g snyk; \
    # npm uninstall -g snyk-to-html; \
    # cd ..; rm -rf ./qdrant; \
    \
    python3 -m venv qdrant; \
    . qdrant/bin/activate; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install --upgrade qdrant-client; \
    apk del --no-network --purge .build-deps; \
    \
    apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        gcompat \
        tzdata \
        libunwind \
        python3 \
        py3-pip \
        jq \
        wget \
        unzip; \
    \
    tini_bin="" ; \
    case "$(arch)" in \
        aarch64) tini_bin='tini-arm64' ;; \
        x86_64)  tini_bin='tini-amd64' ;; \
        *) echo >&2 ; echo >&2 "Unsupported architecture $(arch)" ; echo >&2 ; exit 1 ;; \
    esac ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${tini_bin} ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${tini_bin}.sha256sum ; \
    sha256sum -c ${tini_bin}.sha256sum ; \
    rm ${tini_bin}.sha256sum ; \
    mv ${tini_bin} /usr/bin/tini ; \
    chmod 0555 /usr/bin/tini; \
    \
    addgroup -g 65535 qdrant; \
    adduser --shell /sbin/nologin --disabled-password -h /home/qdrant --uid 65535 --ingroup qdrant qdrant; \
    \
    apk add --no-cache -t .av-scan \
      clamav \
      freshclam; \
    freshclam; \
    clamscan -rvi -l /home/qdrant/last_scan.log --exclude-dir="^/sys" /; \
    chown qdrant:qdrant /home/qdrant/last_scan.log; \
    grep -Hrn " FOUND" /home/qdrant/last_scan.log; \
    apk del --no-network --purge .av-scan; \
    \
    rm -rf /var/cache/apk/* /root/.cache/*; \
    \
    mkdir -p /qdrant/static; \
    STATIC_DIR='/qdrant/static'; \
    mkdir -p /qdrant/storage; \
    chown -R qdrant:qdrant /qdrant/ /usr/bin/tini; \
    chmod -R a+rwx,o-rwx /qdrant/

COPY --chmod=755 entrypoint.sh /usr/bin
COPY --chown=qdrant:qdrant config.yaml /qdrant/config/production.yaml
COPY --chown=qdrant:qdrant openai.json /qdrant
COPY --chmod=755 sync-web-ui.sh /qdrant

RUN bash -c "/qdrant/sync-web-ui.sh"

ENV TZ=Etc/UTC \
    RUN_MODE=production

EXPOSE 6333 6334
VOLUME /qdrant/storage
USER qdrant
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/usr/bin/entrypoint.sh" ]
