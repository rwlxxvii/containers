# syntax=docker/dockerfile:1
# onedev: Self-hosted Git Server with CI/CD and Kanban.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    apk add --no-cache \
      bash \
      curl \
      fontconfig \
      font-dejavu \
      openjdk17-jre \
      git

FROM base AS download

ENV URL="https://code.onedev.io/~downloads/projects/160/builds/4343/artifacts/onedev-9.3.0.zip" \
    SHA="e76006fd624d16f758675b461b37aef3553d8cd9603c8d96f98cddbbb2d8bb18"
    
RUN \
    apk add --no-cache -t .onedev-download wget unzip; \
    wget --progress=bar:force -O /tmp/onedev.zip ${URL}; \
    echo "$SHA /tmp/onedev.zip" | sha256sum -c - ; \
    unzip /tmp/onedev.zip -d /tmp/onedev; \
    rm -f /tmp/onedev.zip; \
    apk del --no-network --purge .onedev-download

FROM base

ENV PATH="${PATH}:/usr/lib/jvm/java-17-openjdk/bin/" \
    VER="9.3.0"

LABEL org.opencontainers.image.name='OneDev' \
      org.opencontainers.image.description='Self-hosted Git Server with CI/CD and Kanban.' \
      org.opencontainers.image.usage='https://docs.onedev.io' \
      org.opencontainers.image.url='https://onedev.io' \
      org.opencontainers.image.schema-version='9.3.0'

RUN \
    addgroup -g 1001 onedev; \
    adduser --shell /sbin/nologin --disabled-password -h /home/onedev --uid 1001 --ingroup onedev onedev

COPY --chown=onedev:onedev --from=download /tmp/onedev /opt/

RUN \
    apk add --no-cache -t .clamav clamav freshclam; \
    freshclam; \
    clamscan -rvi -l /home/onedev/artifacts/clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    grep -Hrn FOUND /home/onedev/artifacts/clamav_scan.log; \ 
    apk del --no-network --purge .clamav; \
    rm -rf /var/cache/apk/*; \
    truncate -s 0 /var/log/*log; \
    sed -i "s/#RUN_AS_USER=.*/RUN_AS_USER=onedev/g" /opt/onedev/onedev-${VER}/bin/server.sh; \
    sed -i "s/wrapper.java.command=java.*/wrapper.java.command=/usr/lib/jvm/java-17-openjdk/bin/java/g" /opt/onedev/onedev-${VER}/conf/wrapper.conf; \
    sed -i "s/# server_name=.*/server_name=onedev.dev.io/g" /opt/onedev/onedev-${VER}/conf/server.properties; \
    find /opt/onedev/onedev-${VER}/bin/ -type f -name "*.sh" -exec chmod 755 {} \;

WORKDIR /opt/onedev/onedev-${VER}/bin

USER onedev

# 6610=http port, 6611=ssh port
EXPOSE 6610 6611

ENTRYPOINT [ "bin/bash", "-c", "server.sh" ]
CMD [ "installstart" ]