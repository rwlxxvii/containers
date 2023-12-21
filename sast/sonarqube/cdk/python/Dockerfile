# syntax=docker/dockerfile:1
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ARG AWS_DEFAULT_REGION
ARG AWS_REGION
ARG AWS_ACCOUNT_ID

COPY cdk/ .

# Install prerequisite packages
RUN \
    apk add --no-cache .t .siege-deps \
        curl \
        g++ \
        make; \
    curl http://download.joedog.org/siege/siege-3.1.4.tar.gz > siege-3.1.4.tar.gz; \
    tar -xf siege-3.1.4.tar.gz \
    cd siege-3.1.4; \
    ./configure; \
    make install; \
    rm -rf siege-3.1.4; \
    rm -f siege-3.1.4.tar.gz; \
    apk del --no-network .siege-deps; \
    \
    apk add --no-cache \
        aws-cli \
        bash \
        python3 \
        py3-pip \
        jq \
        nodejs \
        npm; \
    \
    # Install cdk packages
    pip3 install --user --upgrade awslogs; \
    \
    #  Verify environment variables required to communicate with AWS API's via the cli tools
    export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}; \
    export AWS_REGION=${AWS_REGION}; \
    export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}; \
    \
    aws iam get-role --role-name "AWSServiceRoleForElasticLoadBalancing" || aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"; \
    \
    aws iam get-role --role-name "AWSServiceRoleForECS" || aws iam create-service-linked-role --aws-service-name "ecs.amazonaws.com"; \
    \
    npm install -g aws-cdk; \
    pip install -r requirements.txt; \
    \
    cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_DEFAULT_REGION; \
    cdk synth; \
    cdk diff; \
    cdk deploy --require-approval never

