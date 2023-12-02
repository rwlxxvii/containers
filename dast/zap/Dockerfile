FROM docker.io/kalilinux/kali-rolling as build-env
# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
#ENV SNYK_API=
RUN set -x; \
	\
	apt-get update && apt-get install -q -y --fix-missing \
	wget \
	curl \
	openjdk-11-jdk \
	xmlstarlet \
	unzip \
	npm; \
	rm -rf /var/lib/apt/lists/*
# static analysis of zaproxy code
#    wget https://github.com/zaproxy/zaproxy/archive/refs/heads/main.zip; unzip main.zip; \
#    rm -f main.zip; \
#    cd zaproxy-main; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \    
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /owaspzap-code-review.html; \
#    snyk test --json | snyk-to-html -o /owaspzap-deps.html; \
#    snyk monitor; \
#    npm uninstall snyk; \
#    npm uninstall snyk-to-html; \
#    rm -rf ../zaproxy-main

WORKDIR /zap

RUN set -eux; \
	\
	wget -qO- https://raw.githubusercontent.com/zaproxy/zap-admin/master/ZapVersions.xml | xmlstarlet sel -t -v //url |grep -i Linux | wget --content-disposition -i - -O - | tar zxv; \
	mv ZAP*/* .; \
	rm -R ZAP*; \
	./zap.sh -cmd -silent -addonupdate; \
	cp /root/.ZAP/plugin/*.zap plugin/ || :

# Setup Webswing
ENV WEBSWING_VERSION 22.2.4
ARG WEBSWING_URL=""
RUN set -eux; \
	\
	if [ -z "$WEBSWING_URL" ] ; \
	then curl -s -L  "https://dev.webswing.org/files/public/webswing-examples-eval-${WEBSWING_VERSION}-distribution.zip" > webswing.zip; \
	else curl -s -L  "$WEBSWING_URL-${WEBSWING_VERSION}-distribution.zip" > webswing.zip; fi; \
	unzip webswing.zip; \
	rm webswing.zip; \
	mv webswing-* webswing; \
	rm -Rf webswing/apps/

FROM kalilinux/kali-rolling

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -q -y --fix-missing \
	make \
	automake \
	autoconf \
	gcc g++ \
	openjdk-11-jdk \
	wget \
	curl \
	xmlstarlet \
	unzip \
	git \
	openbox \
	xterm \
	net-tools \
	python3-pip \
	python-is-python3 \
	firefox-esr \
	xvfb \
	x11vnc \
	clamav && \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	\
    pip3 install --no-cache-dir --upgrade awscli pip python-owasp-zap-v2.4 pyyaml urllib3; \
    groupadd -g 1000 zap; \
    useradd -u 1000 -s /bin/bash -m -r -g zap zap; \
    mkdir /zap && chown zap:zap /zap; \
    mkdir /home/zap/.vnc

WORKDIR /zap
COPY --from=build-env --chown=1000:1000 /zap .
COPY --from=build-env --chown=1000:1000 /zap/webswing /zap/webswing
COPY support/zap* /zap/
COPY support/webswing* /zap/webswing/
COPY policies /home/zap/.ZAP/policies/
COPY policies /root/.ZAP/policies/
COPY scripts /home/zap/.ZAP_D/scripts/
COPY support/.xinitrc /home/zap/

#run AV scan for container
RUN set -x; \
        \
    freshclam; \
    clamscan -r -v -i -l /home/zap/last_scan.log --exclude-dir="^/sys" /; \
    grep -Hrn FOUND /home/zap/last_scan.log; \
    apt-get remove -y clamav; \
    apt-get autoremove -y; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log

#fix perms
RUN set -eux; \
	\
    chmod -R u=rwx,go=rx /zap; \
    chmod -R u=rwx,go=rx /home/zap
    
ARG TARGETARCH
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-$TARGETARCH
ENV PATH $JAVA_HOME/bin:/zap/:$PATH
ENV ZAP_PATH /zap/zap.sh

# Default port for use with health check
ENV ZAP_PORT 8080
ENV IS_CONTAINERIZED true
ENV HOME /home/zap/
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN echo "zap2docker-stable" > /zap/container && \
    chmod a+x /home/zap/.xinitrc
USER zap
