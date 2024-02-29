# syntax=docker/dockerfile:1
# caido: A lightweight web security auditing toolkit.

ARG repo="quay.io/almalinuxorg" \
    base_image="9-minimal" \
    image_hash="bc83a80849984abca9a46d50cb163d2cd30255fd37485bc294bf817897ed7c26"

FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL org.opencontainers.image.name='Caido' \
      org.opencontainers.image.description='A lightweight web security auditing toolkit.' \
      org.opencontainers.image.usage='https://docs.caido.io/user_guide' \
      org.opencontainers.image.url='https://caido.io/' \
      org.opencontainers.image.vendor='Caido' \
      org.opencontainers.image.schema-version='0.30.4' \
      MAINTAINER="@rw"
      
RUN \
    microdnf install -y yum-utils epel-release shadow-utils; \
    groupadd -g 1007 caido; \
    useradd -u 1007 -r -g caido caido -m; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y \
        bash \
        bzip2 \
        ca-certificates \
        openscap \
        scap-security-guide \
        wget

# download and unpack caido bin
FROM base AS download

RUN \
    microdnf install -y \
        clamav \
        clamav-update \
        findutils \
        jq \
        tar; \
    curl -s https://api.caido.io/releases/latest \
    | jq '.links[] | select(.display == "Linux") | .link' \
    | xargs curl -s --output caido.tar.gz; \
    tar -xf caido.tar.gz; \
    rm -f caido.tar.gz; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys|^/dev" / || :

FROM base

COPY --chown=caido:caido --from=download caido /usr/bin/caido

WORKDIR /home/caido/artifacts

COPY --chmod=755 el9-container-hardening.sh .
COPY --chown=caido:caido --from=download clamav_scan.log .

ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-almalinux9-ds.xml

RUN \
    bash -c "./el9-container-hardening.sh"; \
    wget https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
    oscap oval eval --report caido-alma9-cve-report.html org.almalinux.alsa-9.xml || :; \
    oscap ds sds-validate /usr/share/xml/scap/ssg/content/${BENCHMARK} \ && echo "ok" || echo "exit code = $? not ok"; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results caido_alma9-${SCAP_SNAME}-scap-report.xml \
    --report caido_alma9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    chown -R caido:caido /home/caido; \    
    dnf config-manager --set-disabled crb; \
    /usr/bin/crb disable; \
    microdnf remove -y \
        bzip2 \
        epel-release \
        openscap \
        scap-security-guide \
        wget \
        yum-utils; \  
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log; \
    # validate bin working
    caido --version

USER caido
EXPOSE 8080
ENTRYPOINT [ "caido" ]
CMD [ "--listen", "0.0.0.0:8080" ] 
