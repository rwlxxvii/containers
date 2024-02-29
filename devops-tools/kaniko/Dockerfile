# syntax=docker/dockerfile:1
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"

FROM ${repo}/${base_image}@sha256:${image_hash}

ENV KANIKO_VPC="<YOUR VPC ID e.g., vpc-055e876skjwshr1dca1>" \
    KANIKO_SUBNET="<SUBNET ID e.g., subnet-09a9a548da32bbbbe>" \
    DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034"

RUN \
    apk add --no-cache \
      aws-cli \
      bash \
      btrfs-progs \
      docker \
      e2fsprogs \
      e2fsprogs-extra \
      git \
      iptables \
      wget \
      xfsprogs \
      xz; \
    addgroup -S kaniko; \
    adduser -S -G kaniko kaniko; \
      echo 'kaniko:165536:65536' >> /etc/subuid; \
      echo 'kaniko:165536:65536' >> /etc/subgid; \
    wget --progress=bar:force -O /usr/local/bin/dind \
      https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind; \
        chmod 755 /usr/local/bin/dind; \
    export KANIKO_VPC=${KANIKO_VPC}; \
    export KANIKO_SUBNET=${KANIKO_SUBNET}
    
WORKDIR /src
COPY --chmod=755 *sh .
RUN bash -c "variables.sh"; bash -c "create_configs.sh"
VOLUME /var/lib/docker
EXPOSE 2375
ENTRYPOINT [ "build.sh" ]
