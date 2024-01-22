# syntax=docker/dockerfile:1
# nessus: The Global Gold Standard in Vulnerability Assessment Built for the Modern Attack Surface
ARG repo="docker.io" \
    base_image="oraclelinux:8-slim-fips" \
    image_hash="045f649d06d5c8461362af8b9cdec1256fa8761aacd9eecb6cf4b84d0b3013e2"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL org.opencontainers.image.name='Nessus' \
    org.opencontainers.image.description='The Global Gold Standard in Vulnerability Assessment Built for the Modern Attack Surface.' \
    org.opencontainers.image.usage='https://docs.tenable.com/Nessus.htm' \
    org.opencontainers.image.url='https://www.tenable.com/products/nessus' \
    org.opencontainers.image.licenses='Tenable' \
    org.opencontainers.image.vendor='Tenable' \
    org.opencontainers.image.schema-version='10.6.4' \
    MAINTAINER="@rw"
    
RUN \
    microdnf install -y epel-release; \
    microdnf update -y; \
    microdnf install -y java-17-openjdk
    
FROM base AS download

ARG VER=10.6.4

RUN \
    curl --request GET \
    --url "https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-${VER}-es8.x86_64.rpm" \
    --output "Nessus-${VER}-es8.x86_64.rpm"; \
    rpm -ivh Nessus-${VER}-es8.x86_64.rpm

FROM base

COPY --from=download /opt/nessus /opt/nessus

# it is required to obtain an activation code for installation to proceed
# modify cert parameters here:
ARG ACTIVATE_CODE=
ARG CA_LIFE=730
ARG CERT_LIFE=365
ARG COUNTRY=US
ARG STATE=XX
ARG CITY=XXXX
ARG ORG=Testing
ARG HOSTNAME=nessus.testing.io
    
RUN \
    microdnf install -y \
        clamav \
        clamav-update \
        openscap \
        scap-security-guide \
        wget \
        bzip2; \
    echo "${HOSTNAME}" > /etc/hostname; \
    /opt/nessus/sbin/nessus-service -q -D; \
    groupadd -r nessus; \
    useradd -r -g nessus nessus -m; \ 
    /opt/nessus/sbin/nessuscli fetch --register ${ACTIVATE_CODE}; \
    /opt/nessus/sbin/nessuscli update --all; \
    echo -ne "${CA_LIFE}\n${CERT_LIFE}\n${COUNTRY}\n${STATE}\n${CITY}\n${ORG}\n${HOSTNAME}\ny" | /opt/nessus/sbin/nessuscli mkcert; \
    chown -R nessus:nessus /opt/nessus

WORKDIR /home/nessus/artifacts
ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-ol8-ds.xml

COPY el8-container-hardening.sh .

RUN \
    chmod +x ./el8-container-hardening.sh; \
    bash -c "./el8-container-hardening.sh"; \
    wget https://linux.oracle.com/security/oval/com.oracle.elsa-ol8.xml.bz2; \
    bzip2 -d com.oracle.elsa-ol8.xml.bz2; \
    oscap oval eval --report nessus-ol9-cve-report.html com.oracle.elsa-ol8.xml || :; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results nessus-ol8-${SCAP_SNAME}-scap-report.xml \
    --report nessus-ol8-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys|^/dev" / || :; \
    chown -R nessus:nessus /home/nessus; \
    # incase something is found it's in the build logs
    grep -Hrn FOUND clamav_scan.log; \   
    microdnf remove -y clamav clamav-update openscap scap-security-guide wget bzip2 epel-release; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log
    
WORKDIR /home/nessus
USER nessus
STOPSIGNAL SIGINT
ENTRYPOINT [ "/bin/bash", "-c", "/opt/nessus/sbin/nessus-service --no-root -p 8834 -D" ]
