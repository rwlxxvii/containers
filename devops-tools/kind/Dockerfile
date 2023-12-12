# syntax=docker/dockerfile:1
# kind: Kubernetes IN Docker.

ARG repo="docker.io" \
    base_image="docker:24.0.7-dind-alpine3.18" \
    image_hash="4c92bd9328191f76e8eec6592ceb2e248aa7406dfc9505870812cf8ebee9326a"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    addgroup -g 65535 kind; \
    adduser --shell /sbin/sh --disabled-password -h /home/kind --uid 65535 --ingroup kind kind; \    
    apk add --no-cache \
        bash \
        bash-completion \
        bind-tools \
        curl \
        git \
        jq \
        nano \
        py3-pip \
        python3 \
        sed \
        supervisor

FROM base as download

ARG KIND_VERSION=0.20.0
ARG KUBERNETES_VERSION=1.28.0
ARG HELM_VERSION=3.13.2

RUN \
# kind
    curl https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64 \
        -Lo /usr/local/bin/kind; \
# Kubectl
    curl https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl \
        -Lo /usr/local/bin/kubectl; \
# Helm
    curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        | tar -xz linux-amd64/helm; \
    mv linux-amd64/helm /usr/local/bin/helm; \
    rm -rf linux-amd64

FROM base

ARG KUBERNETES_VERSION="1.28.0"

# example k8s deploy
WORKDIR /deploy
COPY --chown=kind:kind ./docker/manifests ./manifests
COPY --chown=kind:kind ./docker/scripts ./usr/local/bin

RUN \
    helm plugin install https://github.com/databus23/helm-diff; \
    sed 's/@@@KUBERNETES_VERSION@@@/'${KUBERNETES_VERSION}'/g' -i ./manifests/cluster.yml

COPY --chmod=755 --from=download /usr/local/bin/kind /usr/local/bin
COPY --chmod=755 --from=download /usr/local/bin/kubectl /usr/local/bin
COPY --chmod=755 --from=download /usr/local/bin/helm /usr/local/bin

USER kind