# syntax=docker/dockerfile:1
# consul: uses service identities and traditional networking practices to help organizations securely connect applications running in any environment.
ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

RUN \
    apk add --no-cache \
    	dumb-init \
	libc6-compat \
	iptables \
	tzdata \
	curl \
	ca-certificates \
	iputils \
	libcap \
	su-exec \
	jq \
	clamav \
	freshclam

FROM base as build-env

ENV CONSUL_VER=1.17.0 \
    CONSUL_GPGKEY=C874011F0AB405110D02105534365D9472D7468F \
    SNYK_API=
    
RUN \
     apk add --no-cache -t .build-deps \
	ca-certificates \
	gnupg \
	openssl \
	unzip \
	wget; \
	    apkArch="$(apk --print-arch)"; \
	    case "$apkArch" in armhf) ARCH='arm' ;; \
	      aarch64) ARCH='arm64' ;; \
	      x86_64) ARCH='amd64' ;; \
	      x86) ARCH='386' ;; \
	      *) echo >&2 "error: unsupported architecture: $apkArch"; \
	      exit 1 ;; \
	    esac; \
	    found=''; \
	    for server in \
	      hkps://keys.openpgp.org \
	      hkps://keyserver.ubuntu.com \
	      hkps://pgp.mit.edu; do \
	      echo "Fetching GPG key $CONSUL_GPGKEY from $server"; \
	      gpg --batch --keyserver "$server" --recv-keys "$CONSUL_GPGKEY"; \
	      found=yes && break; \
	    done; \
	    test -z "$found" && echo >&2 "error: failed to fetch GPG key $CONSUL_GPGKEY" && exit 1; \
	    mkdir -p /tmp/build; \
	    cd /tmp/build; \
	    wget https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_linux_${ARCH}.zip; \
	    wget https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_SHA256SUMS; \
	    wget https://releases.hashicorp.com/consul/${CONSUL_VER}/consul_${CONSUL_VER}_SHA256SUMS.sig; \
	    gpg --batch --verify consul_${CONSUL_VER}_SHA256SUMS.sig consul_${CONSUL_VER}_SHA256SUMS; \
	    grep consul_${CONSUL_VER}_linux_${ARCH}.zip consul_${CONSUL_VER}_SHA256SUMS | sha256sum -c; \
	    unzip -d /tmp/build consul_${CONSUL_VER}_linux_${ARCH}.zip; \
	    cp /tmp/build/consul /bin/consul; \
	    if [ -f /tmp/build/EULA.txt ]; then mkdir -p /usr/share/doc/consul; mv /tmp/build/EULA.txt /usr/share/doc/consul/EULA.txt; fi; \
	    if [ -f /tmp/build/TermsOfEvaluation.txt ]; then mkdir -p /usr/share/doc/consul; mv /tmp/build/TermsOfEvaluation.txt /usr/share/doc/consul/TermsOfEvaluation.txt; fi; \
	    rm -rf /tmp/build; \
	    gpgconf --kill dirmngr; \
	    gpgconf --kill gpg-agent; \
	    #smoke
	    consul version; \
	    apk del --no-network --purge .consul-deps; \
	    rm -rf /root/.gnupg /var/cache/apk/*

#run SCA scan against source code
#WORKDIR /tmp
#RUN set -x; \
#    apk add --no-cache -t .sca-deps npm unzip wget; \
#    wget https://github.com/hashicorp/consul/archive/refs/heads/main.zip; \
#    unzip main.zip; cd consul-main/; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /consul-code-review.html; \
#    snyk test --json | snyk-to-html -o /consul-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    apk del --purge .sca-deps; \
#    rm -rf /var/cache/apk/* /tmp/*

FROM base

LABEL org.opencontainers.image.name='Hashicorp Consul' \
    org.opencontainers.image.description='Automate Service Networking Across Clouds.' \
    org.opencontainers.image.usage='https://developer.hashicorp.com/consul/docs' \
    org.opencontainers.image.url='https://www.hashicorp.com/products/consul' \
    org.opencontainers.image.vendor='Hashicorp' \
    org.opencontainers.image.licenses='Mozilla Public License 2.0' \
    org.opencontainers.image.schema-version='1.17.0' \
    MAINTAINER="@rw"
    
RUN \
    addgroup -g 65535 consul; \
    adduser --shell /sbin/nologin --disabled-password -h /home/consul --uid 65535 --ingroup consul consul; \
    mkdir -p /consul/data; \
    mkdir -p /consul/config; \
    chown -R consul:consul /consul
    
COPY --chown=consul:consul --from=build-env /bin/consul /usr/local/bin/
#COPY --chown=consul:consul --from=build-env /consul-deps.html /home/consul
#COPY --chown=consul:consul --from=build-env /consul-code-review.html /home/consul
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY consul-config.json /consul/config/config.json

RUN \
    freshclam; \
    clamscan -r -v -i -l /home/consul/last_scan.log --exclude-dir="^/sys" /; \
    chown consul:consul /home/consul/last_scan.log; \
    grep -Hrn FOUND /home/consul/last_scan.log; \
    apk del --no-network clamav freshclam; \
    rm -rf /var/cache/apk/*; \
    chmod +x /usr/local/bin/entrypoint.sh; \
    test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

VOLUME /consul/data
EXPOSE 8300
EXPOSE 8301 8301/udp 8302 8302/udp
EXPOSE 8500 8600 8600/udp
USER consul
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "agent", "-dev", "-client", "0.0.0.0" ]
