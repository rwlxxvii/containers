# syntax=docker/dockerfile:1
# zeek: A powerful network analysis framework that is much different from the typical IDS you may know. 
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS build-env

ENV VER=6.0.1 \
    AF_PACKET_VERSION=4.0.0 \
    BUILD_PROCS=2

RUN \
    apk add --no-cache -t .build-deps \
        bsd-compat-headers \
        libmaxminddb-dev \
        linux-headers \
        openssl-dev \
        libpcap-dev \
        python3-dev \
        zlib-dev \
        binutils \
        cmake \
        clang \
        bison \
        bash \
        swig \
        perl \
        make \
        flex \
        git \
        g++ \
        fts \
        libpcap \
        libgcc \
        libstdc++ \
        openssl \
        zlib; \
    cd /tmp; \
    git clone --recursive --branch v${VER} https://github.com/zeek/zeek.git; \
    cd /tmp/zeek; \
    CC=clang ./configure --prefix=/usr/local/zeek \
    --build-type=MinSizeRel \
    --disable-auxtools \
    --disable-broker-tests \
    make; \
    make install; \
    git clone https://github.com/corelight/zeek-community-id.git; \
    cd /tmp/zeek-community-id; \
    CC=clang ./configure --zeek-dist=/tmp/zeek; \
    cd /tmp/zeek-community-id/build; \
    make; \
    make install; \
    /usr/local/zeek/bin/zeek -NN Corelight::CommunityID; \
    git clone --recursive --branch ${AF_PACKET_VERSION} \
    https://github.com/zeek/zeek-af_packet-plugin.git /tmp/zeek-af_packet-plugin; \
    cd /tmp/zeek-af_packet-plugin; \
    CC=clang ./configure --with-kernel=/usr --zeek-dist=/tmp/zeek; \
    make -j $BUILD_PROCS; \
    make install; \
    /usr/local/zeek/bin/zeek -NN Zeek::AF_Packet; \
    strip -s /usr/local/zeek/bin/zeek; \
    apk del --purge .build-deps; \
    rm -rf /var/cache/apk/*

FROM ${base_image}

LABEL org.opencontainers.image.name='Zeek' \
    org.opencontainers.image.description='Zeek (formerly Bro) is the worlds leading platform for network security monitoring.' \
    org.opencontainers.image.usage='https://docs.zeek.org/en/master/' \
    org.opencontainers.image.url='https://zeek.org/' \
    org.opencontainers.image.licenses='The Regents of the University of California' \
    org.opencontainers.image.vendor='The Zeek Project' \
    org.opencontainers.image.schema-version='6.0.1' \
    MAINTAINER="@rw"

RUN apk --no-cache add \
        ca-certificates \
        bash \
        zlib \
        openssl \
        libstdc++ \
        libpcap \
        libmaxminddb \
        libgcc \
        fts \
        git \
        python3 \
        py3-pip \
        py3-semantic-version \
        py3-gitpython \
        py3-websockets \
        clamav \
        freshclam \
        krb5-libs \
        ethtool \
        util-linux \
        wget

COPY --from=build-env /usr/local/zeek /usr/local/zeek
COPY local.zeek /usr/local/zeek/share/zeek/site/local.zeek
COPY --chmod=755 entrypoint.sh .

ENV ZEEKPATH=".:/data/config:/usr/local/zeek/share/zeek:/usr/local/zeek/share/zeek/policy:/usr/local/zeek/share/zeek/site" \
    PATH="/usr/local/zeek/bin:${PATH}" \
    PYTHONPATH="/usr/local/zeek/lib/zeek/python:${PYTHONPATH}" \
    ZKG_VERSION="2.14.0" \
    ZEEKCFG_VERSION="0.0.5" \
    ZEEK_DEFAULT_PACKAGES="bro-interface-setup \
    bro-doctor \
    ja3 \
    hassh \
    bzar \
    dovehawk \
    icsnpp-bacnet \
    icsnpp-bsap \
    icsnpp-dnp3 \
    icsnpp-enip \
    icsnpp-ethercat \
    icsnpp-genisys \
    icsnpp-modbus \
    icsnpp-opcua-binary \
    icsnpp-s7comm \
    icsnpp-synchrophasor" 

RUN \
    ln -s $(which ethtool) /sbin/ethtool; \
    pip install zkg==$ZKG_VERSION; \
    zkg autoconfig; \
    zkg refresh; \
    zkg install --force $ZEEK_DEFAULT_PACKAGES; \
    case `uname -m` in \
    x86_64) \
        TARGET_ARCH="amd64" \
        ;; \
    aarch64) \
        TARGET_ARCH="arm64" \ 
        ;; \
    arm|armv7l) \
        TARGET_ARCH="arm" \
        ;; \
    esac; \
    TARGET_ARCH=${TARGETARCH:-$TARGET_ARCH}; \
    echo https://github.com/activecm/zeekcfg/releases/download/v${ZEEKCFG_VERSION}/zeekcfg_${ZEEKCFG_VERSION}_linux_${TARGET_ARCH}; \
    wget -qO /usr/local/zeek/bin/zeekcfg https://github.com/activecm/zeekcfg/releases/download/v${ZEEKCFG_VERSION}/zeekcfg_${ZEEKCFG_VERSION}_linux_${TARGET_ARCH}; \
    chmod +x /usr/local/zeek/bin/zeekcfg; \
    echo "*/5       *       *       *       *       /usr/local/zeek/bin/zeekctl cron" >> /etc/crontabs/root

RUN \
    addgroup -g 65535 zeek; \
    adduser --shell /sbin/nologin --disabled-password -h /home/zeek --uid 65535 --ingroup zeek zeek; \
    freshclam; \
    clamscan -rvi -l /home/zeek/last_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown zeek:zeek /home/zeek/last_scan.log; \
    grep -Hrn " FOUND" /home/zeek/last_scan.log; \
    apk del clamav freshclam; \
    chown -R zeek:zeek /usr/local/zeek
    
WORKDIR /home/zeek
USER zeek
ENTRYPOINT [ "/entrypoint.sh" ]
