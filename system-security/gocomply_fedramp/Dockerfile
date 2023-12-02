FROM docker.io/alpine:edge as build-env

ENV GOPATH=/usr/local/bin/go
# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
ENV SNYK_API=

RUN set -x; \
    	\
    apk add --no-cache -t .oscal-deps go git libxml2-dev npm; \
    mkdir -p ${GOPATH}/src/github.com/gocomply_fedramp; \
    cd ${GOPATH}/src/github.com/gocomply_fedramp; \
    git clone https://github.com/GoComply/fedramp.git; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
    cd fedramp/; \
#    snyk code test --json | snyk-to-html -o /gocomply_fedramp-code-review.html; \
#    snyk test --json | snyk-to-html -o /gocomply_fedramp-deps.html; \
#    snyk monitor; \
    cd cli/gocomply_fedramp/; \
#    && go env -w GOPRIVATE=https://my.gitlab.com/oscal/gocomply
#    && git config --global url."https://<yourname>:<personal access token from gitlab>@gitlab.com".insteadOf "https://gitlab.com"
#    && go install -v gitlab.com/oscal/gocomply/fedramp/cli/gocomply_fedramp@latest
    export GO111MODULE=on; \
    go install; \
#    npm uninstall -g snyk snyk-to-html; \
    apk del --purge .oscal-deps; \
    rm -rf ${GOPATH}/src/github.com

FROM alpine:edge

LABEL org.opencontainers.image.name='GoComply FedRAMP SSP Generator' \
    org.opencontainers.image.description='Automated System Security Plan generation from XML' \
    org.opencontainers.image.usage='https://csrc.nist.gov/Projects/Open-Security-Controls-Assessment-Language' \
    org.opencontainers.image.url='https://github.com/usnistgov/OSCAL' \
    org.opencontainers.image.vendor='National Institute of Standards and Technology (NIST)' \
    org.opencontainers.image.licenses='Fair Use of NIST Data/Works' \
    org.opencontainers.image.schema-version='0.1.4' \
    MAINTAINER="@rw"
    
RUN set -eux; \
    	\
    apk add --no-cache clamav freshclam wget libxml2; \
    addgroup -g 65535 oscal; \
    adduser --shell /sbin/nologin --disabled-password -h /home/oscal --uid 65535 --ingroup oscal oscal
    
COPY --chown=oscal:oscal --from=build-env /usr/local/bin/go/bin /usr/local/bin
#COPY --chown=oscal:oscal --from=build-env /gocomply_fedramp-code-review.html /home/oscal
#COPY --chown=oscal:oscal --from=build-env /gocomply_fedramp-deps.html /home/oscal

#run AV scan
RUN set -x; \
    	\
    freshclam; \
    clamscan -r -v -i -l /home/oscal/last_scan.log --exclude-dir="^/sys" /; \
    chown oscal:oscal /home/oscal/last_scan.log; \
    grep -Hrn FOUND /home/oscal/last_scan.log; \
    sleep 10s; \
    apk del clamav freshclam; \
    rm -rf /var/cache/apk/*
# example pull down of modified xml with control responses
#
# Assumption is this container is within the same vpc and has access to it
#    && wget --no-check-certificate --no-proxy 'http://your_bucket.s3.amazonaws.com/my-modified-level.xml'
#
# github or gitlab pulldown
#    && git config --global url."https://<yourname>:<personal access token from gitlab>@gitlab.com".insteadOf "https://gitlab.com"
#    && wget https://raw.githubusercontent.com/My_Repo/oscal/master/xml/my-modified-level.xml
#    && wget --header="JOB-TOKEN: $CI_JOB_TOKEN" "https://git.my-company.com/projects/oscal_project/repository/files/my-modified-level.xml?ref=master"
#
# example just pulling from github with template and converting to docx
WORKDIR /home/oscal
# app function check
# generate ssp docx from xml
RUN set -eux; \
    	\
     wget https://raw.githubusercontent.com/ComplianceAsCode/oscal/master/xml/rhel-8-fedramp-High.xml; \
     gocomply_fedramp convert ./rhel-8-fedramp-High.xml FedRAMP-High-rhel8.docx
