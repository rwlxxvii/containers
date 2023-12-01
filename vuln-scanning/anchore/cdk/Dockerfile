# syntax=docker/dockerfile:1
# AWS cdk runtime
ARG repo="docker.io" \
    base_image="node:20.9.0-alpine3.18" \
    image_hash="807e66e2bee193961c9642bb1157d77a61747bf76737ca786da45b10749dcb42"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV AWSCDK_VERSION="2.103.1" \
    GLIBC_VER="2.35-r1" \
    AWS_PAGER=""

RUN \
    apk add --no-cache --update \
      python3 \
      python3-dev \
      py3-pip \
      git \
      jq \
      binutils \
      curl \
      unzip; \
    pip3 install --upgrade pip; \
    pip3 install \
      aws-cdk-lib \
      boto3 \
      constructs \
      json-spec \
      pytest \
      yamllint; \
    curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub; \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk; \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk; \
    apk add --force-overwrite --no-cache \
      glibc-${GLIBC_VER}.apk \
      glibc-bin-${GLIBC_VER}.apk; \
    curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip; \
    unzip awscliv2.zip; \
    aws/install; \
    rm -rf \
      awscliv2.zip \
      aws \
      /usr/local/aws-cli/v2/*/dist/aws_completer \
      /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
      /usr/local/aws-cli/v2/*/dist/awscli/examples; \
    apk del --no-network \
      binutils \
      curl; \
    rm glibc-${GLIBC_VER}.apk; \
    rm glibc-bin-${GLIBC_VER}.apk; \
    rm -rf /var/cache/apk/*

RUN \
    npm i --location=global npm; \
    npm i --location=global aws-cdk@${AWSCDK_VERSION}; \
    mkdir -p /aws/cdk/src; cd /aws/cdk/src

COPY ./* .

# RUN \
#     mkdir -p /aws/cdk/src/lambda; \
#     cd lambda; \
#     cdk init --language python;\
#     source .venv/bin/activate; \
#     cdk deploy

RUN \
    # AWS account info
    source .env.sh; \
    # compile typescript to js
    npm run build; \
    # watch for changes and compile
    npm run watch; \
    # deploy this stack to your default AWS account/region
    cdk deploy; \
    # compare deployed stack with current state
    cdk diff; \
    # emits the synthesized CloudFormation template
    cdk synth
