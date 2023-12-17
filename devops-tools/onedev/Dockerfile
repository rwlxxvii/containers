# syntax=docker/dockerfile:1
# onedev: Self-hosted Git Server with CI/CD and Kanban.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    apk add --no-cache \
      bash \
      curl \
      fontconfig \
      font-dejavu \
      openjdk17-jre \
      git \
      gcompat

FROM base AS download

ENV URL="https://code.onedev.io/~downloads/projects/160/builds/4442/artifacts/onedev-9.4.3.zip" \
    SHA="280ddef0d394e2ae15c10e41337646ce6d231a619d1c131f3f4a59436bc9dcc2"
    
RUN \
    apk add --no-cache -t .onedev-download wget unzip; \
    wget --progress=bar:force -O /tmp/onedev.zip ${URL}; \
    echo "$SHA /tmp/onedev.zip" | sha256sum -c - ; \
    unzip /tmp/onedev.zip -d /tmp/onedev; \
    rm -f /tmp/onedev.zip; \
    apk del --no-network --purge .onedev-download

FROM base

ENV PATH="${PATH}:/usr/lib/jvm/java-17-openjdk/bin/" \
    VER="9.4.3"

LABEL org.opencontainers.image.name='OneDev' \
      org.opencontainers.image.description='Self-hosted Git Server with CI/CD and Kanban.' \
      org.opencontainers.image.usage='https://docs.onedev.io' \
      org.opencontainers.image.url='https://onedev.io' \
      org.opencontainers.image.schema-version='9.4.3'

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
