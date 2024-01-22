# syntax=docker/dockerfile:1
ARG repo="quay.io/almalinuxorg" \
    base_image="almalinux" \
    image_hash="65706a20f38a7338bb4ce2618b4e619a9ee5affbe4597b9c7d54a7c7cf4139b2"

FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='Arkime' \
    org.opencontainers.image.description='Arkime (formerly Moloch) is a large-scale, open-source, indexed packet capture and search tool.' \
    org.opencontainers.image.usage='https://arkime.com/learn' \
    org.opencontainers.image.url='https://arkime.com' \
    org.opencontainers.image.vendor='Arkime' \
    org.opencontainers.image.licenses='Apache License, Version 2.0' \
    org.opencontainers.image.schema-version='4.6.0' \
    MAINTAINER="@rw"

# add scripts
ADD /scripts /data/
ADD /patch/* /opt/patches/
ADD /etc $ARKIME_DIR/etc/
RUN find /data -name "*.sh" -exec chmod +x {} \;

ENV TINI_VERSION "v0.19.0"

RUN \
    groupadd -g 65535 arkime; \
    useradd -u 65535 -g arkime arkime -m; \
    mkdir -p /home/arkime/artifacts; \
    dnf install -y epel-release dnf-plugins-core; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    dnf update -y; \
    dnf install -y \
      curl \
      file \
      geoip \
      gettext \
      inotify-tools \
      jq \
      libcap \
      json-glib \
      krb5 \
      libmaxminddb \
      libpcap \
      pcre \
      openssl-libs \
      libtool \
      perl-libwww-perl \
      libyaml \
      czmq \
      procps \
      psmisc \
      python3.11 \
      python3.11-pip \
      python3.11-setuptools \
      python3.11-wheel \
      rename \
      rsync \
      sudo \
      supervisor \
      tini \
      vim \
      wget \
      tar \
      gzip \
      unzip \
      cpio \
      bzip2 \
      xz-libs \
      xz-utils \
      p7zip \
      unrar \
      zlib \
      openscap \
      scap-security-guide \
      clamav \
      clamav-update; \
    tini_bin="" ; \
    case "$(arch)" in \
        aarch64) tini_bin='tini-arm64' ;; \
        x86_64)  tini_bin='tini-amd64' ;; \
        *) echo >&2 ; echo >&2 "Unsupported architecture $(arch)" ; echo >&2 ; exit 1 ;; \
    esac ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${tini_bin} ; \
    curl --retry 10 -S -L -O https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${tini_bin}.sha256sum ; \
    sha256sum -c ${tini_bin}.sha256sum ; \
    rm ${tini_bin}.sha256sum ; \
    mv ${tini_bin} /usr/bin/tini ; \
    chmod 0555 /usr/bin/tini
    
ARG ARKIME_VERSION=4.6.0

ENV ARKIME_VERSION "$ARKIME_VERSION" \
    OS_HOST "opensearch" \
    OS_PORT "9200" \
    ARKIME_INTERFACE "wlo1" \
    ARKIME_ADMIN_PASSWORD "admin" \
    ARKIME_HOSTNAME "localhost" \
    ARKIME_DIR "/opt/arkime" \
    CAPTURE "off" \
    VIEWER "on" \
    ARKIME_LOCALELASTICSEARCH "no" \
    ARKIME_INET "yes"

ENV PYTHONDONTWRITEBYTECODE "1" \
    PYTHONUNBUFFERED "1" \
    PATH="$ARKIME_DIR/bin:${PATH}"

FROM base AS install

# arkime install from source deps
RUN \
    dnf install -y \
#        binutils \
#        bison \
#        cmake \
#        file \
#        flex \
#        g++ \
#        gcc \
#        gettext \
#        git-core \
#        groff \
#        groff-base \
#        libcap-devel \
#        json-glib-devel \
#        krb5-devel \
#        libmaxminddb-devel \
#        libpcap-devel \
#        pcre-devel \
#        openssl-libs \
#        libtool \
#        perl-libwww-perl \
#        libyaml-devel \
#        make \
#        meson \
#        ninja-build \
#        patch \
        python3.11-devel \
        python3.11-pip \
        python3.11-setuptools \
        python3.11-wheel \
#        sudo \
#        swig \
#        zlib-devel \
        wget \
        logrotate \
        file-libs; \
#    python3 -m pip install --break-system-packages --no-compile --no-cache-dir beautifulsoup4 meson; \
#    cd /opt; \
#    git clone --recurse-submodules --branch="$ARKIME_VERSION" "$ARKIME_URL" "./arkime-"$ARKIME_VERSION; \
#    cd "./arkime-"$ARKIME_VERSION; \
#    bash -c 'for i in /opt/patches/*; do patch -p 1 -r - --no-backup-if-mismatch < $i || true; done'; \
#    ln -sfr $ARKIME_DIR/bin/npm /usr/local/bin/npm; \
#    ln -sfr $ARKIME_DIR/bin/node /usr/local/bin/node; \
#    ln -sfr $ARKIME_DIR/bin/npx /usr/local/bin/npx; \
#    python3 /opt/bs4_remove_div.py -i ./viewer/vueapp/src/components/users/Users.vue -o ./viewer/vueapp/src/components/users/Users.new -c "new-user-form"; \
#    mv -vf ./viewer/vueapp/src/components/users/Users.new ./viewer/vueapp/src/components/users/Users.vue; \
#    sed -i 's/v-if.*password.*"/v-if="false"/g' ./viewer/vueapp/src/components/settings/Settings.vue; \
#    rm -rf ./capture/plugins/suricata*; \
#    sed -i "s/^\(ARKIME_LOCALELASTICSEARCH=\).*/\1"$ARKIME_LOCALELASTICSEARCH"/" ./release/Configure; \
#    sed -i "s/^\(ARKIME_INET=\).*/\1"$ARKIME_INET"/" ./release/Configure; \
#    ./easybutton-build.sh; \
#    npm -g config set user root; \
#    make install; \
#    npm cache clean --force; \
#    rm -f ${ARKIME_DIR}/wiseService/source.* ${ARKIME_DIR}/etc/*.systemd.service; \
#    bash -c "file ${ARKIME_DIR}/bin/* ${ARKIME_DIR}/node-v*/bin/* | grep 'ELF 64-bit' | sed 's/:.*//' | xargs -l -r strip -v --strip-unneeded"
    mkdir -p /data; \
    cd /data; \
    wget https://s3.amazonaws.com/files.molo.ch/builds/el-9/arkime-${ARKIME_VERSION}-1.x86_64.rpm; \
    dnf install -y ./*.rpm
    
# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
#ENV SNYK_API=

#ENV ARKIME_URL "https://github.com/arkime/arkime.git"

#source code review
#RUN \
#    dnf install -y \
#    git \
#    npm; \
#    cd /tmp; \
#    git clone ${ARKIME_URL}; \
#    cd ./arkime; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /arkime-code-review.html; \
#    snyk test --all-projects --json | snyk-to-html -o /arkime-deps.html; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    rm -rf /tmp/*; \
#    dnf remove -y npm git

FROM base

COPY --chown=arkime:arkime --from=install /opt/arkime /opt/arkime

ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-almalinux9-ds.xml
ARG DATE=$(date +"%Y%m%d")

# run cve, scap benchmark, malware scans of container
RUN \
    mv $ARKIMEDIR/etc /data/config;  \
    ln -s /data/config $ARKIMEDIR/etc;  \
    ln -s /data/logs $ARKIMEDIR/logs;  \
    ln -s /data/pcap $ARKIMEDIR/raw; \
    bash -c "/data/el9-container-hardening.sh"; \
    mkdir -p /home/arkime/artifacts /var/run/arkime; \
    cd /home/arkime/artifacts; \
    wget https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
    oscap oval eval --report arkime-alma9-cve-report.html org.almalinux.alsa-9.xml || :; \
    oscap ds sds-validate /usr/share/xml/scap/ssg/content/${BENCHMARK} \; echo "ok" || echo "exit code = $? not ok"; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results arkime_alma9-${SCAP_SNAME}-scap-report.xml \
    --report arkime_alma9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    freshclam; \
    clamscan -rvi -l clamav_scan_${DATE}.log --exclude-dir="^/sys|^/dev" / || :; \
    chown -R arkime:arkime ../; \
    grep -Hrn " FOUND" clamav_scan_${DATE}.log; \
    dnf remove -y \
    clamav \
    clamav-update \
    openscap \
    scap-security-guide \
    wget; \
    dnf clean all; \
    chown -R arkime:arkime /data /opt/arkime /var/run/arkime; \
    chmod -R a+rwx,o-rwx /data /opt/arkime /var/run/arkime; \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log

VOLUME ["/data/pcap", "/data/config", "/data/logs"]
EXPOSE 8000 8005 8081
WORKDIR $ARKIMEDIR
USER arkime
ENTRYPOINT [ "/usr/bin/tini", "--", "/data/startarkime.sh" ]
