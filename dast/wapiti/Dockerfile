# syntax=docker/dockerfile:1
# wapiti: Audit the security of your websites or web applications.
ARG repo="quay.io/almalinuxorg" \
    base_image="9-minimal" \
    image_hash="b394fe1118d30b9659076dd4cf3e1bcbd144a19da5b4656e282ed605a499c4bb"
    
FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='Wapiti' \
    org.opencontainers.image.description='Wapiti allows you to audit the security of your websites or web applications, built in python.' \
    org.opencontainers.image.usage='https://github.com/wapiti-scanner/wapiti/blob/master/doc/wapiti.ronn' \
    org.opencontainers.image.url='https://wapiti-scanner.github.io/' \
    org.opencontainers.image.licenses='GNU General Public License v2.0' \
    org.opencontainers.image.schema-version='3.1.7'

RUN \
    microdnf install -y yum-utils; \
    microdnf install -y epel-release; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y \
      bash \
      python3 \
      python3-setuptools \
      bzip2 \
      wget \
      openscap \
      scap-security-guide \
      clamav \
      clamav-update; \
    groupadd -g 65535 wapiti; \
    useradd -u 65535 -g wapiti wapiti -m

FROM base AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    SNYK_API=

ARG VER=3.1.7

WORKDIR /tmp

RUN \
    microdnf install -y yum-utils; \
    microdnf install -y epel-release; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y \
      python3-pip \
      python3-setuptools \
      python3-pip-wheel \
      python3-devel \
      make \
      automake \
      gcc \
      g++ \
      subversion \
      cargo \
      wget \
      unzip \
      npm; \
    wget --progress=bar:force https://github.com/wapiti-scanner/wapiti/archive/refs/tags/${VER}.zip; \
    unzip ${VER}.zip

WORKDIR /tmp/wapiti-${VER}
COPY Pipfile* setup.py pyproj* *spec ./

#install wapiti
RUN \
    python3 -m venv wapiti3; \
    . wapiti3/bin/activate; \
    python3 -m pip install --upgrade pip; \  
    python3 -m pip install .; \
#    npm install -g snyk; \
#    npm install -g snyk-to-html; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /wapiti-code-review.html; \
#    snyk test --file=setup.py --json | snyk-to-html -o /wapiti-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
    microdnf remove -y \
      make \
      automake \
      gcc \
      g++ \
      subversion \
      cargo \
      wget \
      unzip \
      npm; \
    dnf config-manager --set-disabled crb; \
    /usr/bin/crb disable; \
    microdnf remove -y yum-utils; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum; \
    truncate -s 0 /var/log/*log
    
FROM base

ENV PYTHONDONTWRITEBYTECODE=1

#copy over python lib's, wapiti binaries, and synk scan report 
COPY --chown=wapiti:wapiti --from=builder /tmp/wapiti-3.1.7/wapiti3/lib/python3.9/ /usr/lib/python3.9/
COPY --chown=wapiti:wapiti --from=builder /tmp/wapiti-3.1.7/bin/wapiti /tmp/wapiti-3.1.7/bin/wapiti-getcookie /usr/local/bin/
#COPY --chown=wapiti:wapiti --from=builder /wapiti-deps.html /home/wapiti
#COPY --chown=wapiti:wapiti --from=builder /wapiti-code-review.html /home/wapiti

# Run hardening script and collect build security artifacts, SCA/Compliance/CVE/AV
WORKDIR /home/wapiti/artifacts
ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-almalinux9-ds.xml

COPY --chmod=755 el9-container-hardening.sh .

RUN \
    bash -c "./el9-container-hardening.sh"; \
    wget --progress=bar:force https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
    oscap oval eval --report sonarqube-alma9-cve-report.html org.almalinux.alsa-9.xml || :; \
    oscap ds sds-validate /usr/share/xml/scap/ssg/content/${BENCHMARK} \ && echo "ok" || echo "exit code = $? not ok"; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results sonarqube_alma9-${SCAP_SNAME}-scap-report.xml \
    --report sonarqube_alma9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys|^/dev" /; \
    chown wapiti:wapiti clamav_scan.log; \
    grep -Hrn FOUND clamav_scan.log; \
    microdnf remove -y clamav clamav-update openscap scap-security-guide wget bzip2 epel-release; \
    dnf config-manager --set-disabled crb; \
    /usr/bin/crb disable; \
    microdnf remove -y yum-utils; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log

WORKDIR /home/wapiti
USER 65535

#app function check; test scan, generate report.
RUN \
    wapiti --update; \
#    wapiti -v2 -u http://testhtml5.vulnweb.com; \
#    ls -la /home/wapiti/.wapiti/generated_report
