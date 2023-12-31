# syntax=docker/dockerfile:1
# gitlab-runner: GitLab Runner is an application that works with GitLab CI/CD to run jobs in a pipeline.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN apk add --no-cache \
      bash \
      ca-certificates \
      dumb-init \
      git \
      git-lfs \
      openssl \
      tzdata \
      wget

FROM base AS builder

ENV GITLAB_RUNNER_VERSION="16.5.0" \
    DOCKER_MACHINE_VERSION="0.16.2-gitlab.22"
    
RUN \
    wget -O /usr/bin/gitlab-runner \
    https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64; \
    wget -O /usr/bin/docker-machine \
    -q https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/releases/v${DOCKER_MACHINE_VERSION}/downloads/docker-machine-Linux-x86_64

FROM base

ARG BUILD_DATE
ARG VCS_REF

COPY --chmod=755 --from=builder /usr/bin/gitlab-runner /usr/bin/gitlab-runner
COPY --chmod=755 --from=builder /usr/bin/docker-machine /usr/bin/docker-machine
COPY --chmod=755 entrypoint.sh /

RUN \
    addgroup -g 65535 gitlab-runner; \
    adduser --shell /sbin/nologin --disabled-password -h /home/gitlab-runner --uid 65535 --ingroup gitlab-runner gitlab-runner; \
    ln -s /usr/bin/gitlab-runner /usr/bin/gitlab-ci-multi-runner; \
    mkdir -p /etc/gitlab-runner/certs; \
    chmod -R 700 /etc/gitlab-runner
   
VOLUME [ "/etc/gitlab-runner", "/home/gitlab-runner" ]
ENTRYPOINT [ "/usr/bin/dumb-init", "/entrypoint.sh" ]
CMD [ "run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner" ]
