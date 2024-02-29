# syntax=docker/dockerfile:1
# suricata: a high performance, open source network analysis and threat detection software.
ARG repo="quay.io/almalinuxorg" \
    base_image="9-minimal" \
    image_hash="bc83a80849984abca9a46d50cb163d2cd30255fd37485bc294bf817897ed7c26"

FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='Suricata' \
    org.opencontainers.image.description='Suricata is a high performance, open source network analysis and threat detection software.' \
    org.opencontainers.image.usage='https://suricata.readthedocs.io/en/suricata-7.0.3/' \
    org.opencontainers.image.url='https://suricata.io/' \
    org.opencontainers.image.licenses='GNU General Public License v2.0' \
    org.opencontainers.image.vendor='The Open Information Security Foundation (OISF)' \
    org.opencontainers.image.schema-version='7.0.3'
    
# base dependencies for runtime
RUN \
    microdnf install -y yum-utils epel-release; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y \
	bzip2 \
	wget \
	cronie \
	elfutils-libelf \
	file \
	findutils \
	hiredis \
	hyperscan \
	iproute \
	jansson \	
	lua-libs \
	libbpf \
	libyaml \
	libnfnetlink \
	libnetfilter_queue \
	libnet \
	libcap-ng \	
	libevent \
	libmaxminddb \
	libpcap \
	libprelude \
	logrotate \
	lz4 \
	net-tools \
	nss \
	nss-softokn \
	pcre \
	procps-ng \
	python3 \
	python3-yaml \
	tcpdump \
	which \
	zlib \
	clamav \
	openscap \
	scap-security-guide \
	clamav-update

FROM base AS build-env

ARG VERSION=7.0.3
#ENV SNYK_API=

RUN \
    microdnf install -y yum-utils epel-release; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y \
	autoconf \
	automake \
	bash \
	cargo \
	cbindgen \
	diffutils \
	elfutils-libelf-devel \
	file \
	file-devel \
	gcc \
	gcc-c++ \
	git \
	hiredis-devel \
	jansson-devel \
	jq \
	lua-devel \
	libbpf-devel \
	libtool \
	libyaml-devel \
	libnfnetlink-devel \
	libnetfilter_queue-devel \
	libnet-devel \
	libcap-ng-devel \
	libevent-devel \
	libmaxminddb-devel \
	libpcap-devel \
	libprelude-devel \
	libtool \
	lz4-devel \
	make \
	nspr-devel \
	nss-devel \
	nss-softokn-devel \
	pcre2-devel \
	pcre-devel \
	pkgconfig \
	python3-devel \
	python3-yaml \
	rust \
	which \
	zlib-devel \
	hyperscan-devel \
	npm \
	gnupg
   
WORKDIR /src/

RUN \
    for server in $(shuf -e hkps://keys.openpgp.org \
                            hkps://keyserver.ubuntu.com \
	    		    hkps://pgp.mit.edu) ; do \
    gpg --batch --keyserver "${server}" --recv-keys b36fdaf2607e10e8ffa89e5e2ba9c98ccdf1e93a && break || : ; \
    done; \
    curl -OL https://www.openinfosecfoundation.org/download/suricata-${VERSION}.tar.gz.sig; \
    curl -OL https://www.openinfosecfoundation.org/download/suricata-${VERSION}.tar.gz; \
    gpg --batch --verify suricata-${VERSION}.tar.gz.sig suricata-${VERSION}.tar.gz; \
    tar zxvf suricata-${VERSION}.tar.gz
	
WORKDIR /src/suricata-${VERSION}
#run SCA scan
#RUN set -eux; \
#    \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /suricata-code-review.html; \
#    snyk test --json | snyk-to-html -o /suricata-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html 

RUN \
    ./configure \
    --prefix=/usr \
    --disable-shared \
    --disable-gccmarch-native \
    --enable-lua \
    --enable-nfqueue \
    --enable-hiredis \
    --enable-geoip \
    --enable-ebpf; \
    make -j 2; \
    make install install-conf DESTDIR=/fakeroot; \
    rm -rf /fakeroot/var /root/.gnupg
    
FROM base

RUN \
    find /etc/logrotate.d -type f -not -name suricata -delete; \
    mkdir -p /var/log/suricata /var/run/suricata /var/lib/suricata
    
COPY --from=build-env /fakeroot /
COPY logrotate /etc/logrotate.d/suricata
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# bin smoke tests
RUN \
    suricata-update update-sources; \
    suricata-update enable-source oisf/trafficid; \
    suricata-update --no-test --no-reload; \
    /usr/bin/suricata -V
 
RUN \
    groupadd -g 1001 suricata; \
    useradd -u 1001 -g suricata suricata -m; \
    chown -R suricata:suricata /etc/suricata; \
    chown -R suricata:suricata /var/log/suricata; \
    chown -R suricata:suricata /var/lib/suricata; \
    chown -R suricata:suricata /var/run/suricata; \
    cp -a /etc/suricata /etc/suricata.dist; \
    chmod 600 /etc/logrotate.d/suricata

# Run hardening script and collect build security artifacts, SCA/Compliance/CVE/AV
WORKDIR /home/suricata/artifacts

ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig \
    SCAP_SNAME=STIG \
    BENCHMARK=ssg-almalinux9-ds.xml

COPY --chmod=755 el9-container-hardening.sh .

RUN \
    bash -c "./el9-container-hardening.sh"; \
    wget https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
    oscap oval eval --report suricata-alma9-cve-report.html org.almalinux.alsa-9.xml || :; \
    oscap ds sds-validate /usr/share/xml/scap/ssg/content/${BENCHMARK} \ && echo "ok" || echo "exit code = $? not ok"; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results suricata_alma9-${SCAP_SNAME}-scap-report.xml \
    --report suricata_alma9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys" / || :; \
    chown -R suricata:suricata /home/suricata; \
    grep -Hrn FOUND clamav_scan.log; \
    microdnf remove -y clamav clamav-update openscap scap-security-guide wget bzip2; \
    dnf config-manager --set-disabled crb; /usr/bin/crb disable; \
    microdnf remove -y epel-release yum-utils

#COPY --chown=suricata:suricata --from=build-env /suricata-code-review.html /home/suricata/artifacts
#COPY --chown=suricata:suricata --from=build-env /suricata-deps.html /home/suricata/artifacts
#ENV A_KEY
#ENV S_KEY
#ENV REGION

RUN \
#    microdnf install -y awscli; \
#    echo -ne "${A_KEY}\n${S_KEY}\n${REGION}\n\ny" | aws configure; \
#    aws s3 sync /home/suricata/artifacts s3://security-artifacts/suricata-build_7.0.1-ol9/
#    rm -rf /home/suricata/artifacts
#    microdnf remove -y awscli; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log; \
    chmod +x /usr/local/bin/entrypoint.sh

VOLUME /var/log/suricata
VOLUME /var/lib/suricata
VOLUME /etc/suricata
ENTRYPOINT ["entrypoint.sh"]
