# syntax=docker/dockerfile:1
# cloudsploit: Cloud Security Posture Management (CSPM).
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

RUN \
    addgroup -g 65535 cloudsploit; \
    adduser -h /home/cloudsploit --shell sbin/nologin --disabled-password --uid 65535 --ingroup cloudsploit --gecos '' cloudsploit; \
    \
    apk add --no-cache \
        git \
        npm; \
    \
    git clone https://github.com/aquasecurity/cloudsploit.git; \
    cd cloudsploit; \
    npm install; \
    npm audit fix --force; \
    chmod 0755 index.js; \
    # usage
    ./index.js -h; \
    \
    chown -R cloudsploit:cloudsploit /cloudsploit

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
ARG AZURE_APPLICATION_ID
ARG AZURE_KEY_VALUE
ARG AZURE_DIRECTORY_ID
ARG AZURE_SUBSCRIPTION_ID
ARG GOOGLE_PROJECT_ID
ARG GOOGLE_CLIENT_EMAIL
ARG GOOGLE_PRIVATE_KEY
ARG ORACLE_TENANCY_ID
ARG ORACLE_COMPARTMENT_ID
ARG ORACLE_USER_ID
ARG ORACLE_KEY_FINGERPRINT
ARG ORACLE_KEY_VALUE
ARG GITHUB_TOKEN
ARG GITHUB_URL
ARG GITHUB_LOGIN
ARG GITHUB_ORG
# podman run --rm -it --name cloudsploit --build-arg <options listed above> <value>

# or use config.js
COPY --chown=cloudsploit:cloudsploit config_example.js /cloudsploit/config.js
USER cloudsploit