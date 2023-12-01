# syntax=docker/dockerfile:1
# sonarqube: clean code for teams and enterprises.
FROM quay.io/almalinuxorg/9-minimal@sha256:b394fe1118d30b9659076dd4cf3e1bcbd144a19da5b4656e282ed605a499c4bb AS base

LABEL \
    org.opencontainers.image.name='SonarQube' \
    org.opencontainers.image.description='Clean code for teams and enterprises.' \
    org.opencontainers.image.usage='https://docs.sonarqube.org/latest/' \
    org.opencontainers.image.url='https://www.sonarsource.com/products/sonarqube/' \
    org.opencontainers.image.licenses='GNU Lesser General Public License v3.0' \
    org.opencontainers.image.vendor='Sonar' \
    org.opencontainers.image.schema-version='10.2.1.78527'
    
RUN \
    microdnf install -y bash \
                        glibc-langpack-en \
                        dejavu-sans-fonts \
                        java-17-openjdk

FROM base AS builder

ARG SONARQUBE_VERSION="10.2.1.78527"
ARG SONARQUBE_ZIP_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
    
ENV JAVA_HOME="/usr/lib/jvm/jre-17-openjdk" \
    SONARQUBE_HOME="/opt/sonarqube" \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp" \
    SNYK_API=" "
    
RUN \
    microdnf install -y yum-utils; \
    microdnf install -y epel-release; \
    dnf config-manager --set-enabled crb; \
    /usr/bin/crb enable; \
    microdnf update -y; \
    microdnf install -y java-17-openjdk \
                            bash \
                            wget \
                            clamav \
                            openscap \
                            scap-security-guide \
                            clamav-update \
                            unzip
    
#run SCA scan against source code
#WORKDIR /tmp
#RUN \
#    microdnf install -y npm; \
#    wget https://github.com/SonarSource/sonarqube/archive/refs/heads/master.zip; \
#    unzip master.zip; cd sonarqube-master; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /sonarqube-code-review.html; \
#    snyk test --all-projects --json | snyk-to-html -o /sonarqube-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    microdnf remove -y npm

WORKDIR /opt

RUN \
    for server in $(shuf -e hkps://keys.openpgp.org \
                            hkps://keyserver.ubuntu.com \
                            hkps://pgp.mit.edu) ; do \
        gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ; \
    done; \
    wget --progress=bar:force -O sonarqube.zip ${SONARQUBE_ZIP_URL}; \
    wget --progress=bar:force -O sonarqube.zip.asc ${SONARQUBE_ZIP_URL}.asc; \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip; \
    unzip -q sonarqube.zip; \
    mv sonarqube-${SONARQUBE_VERSION} sonarqube; \
    rm -f sonarqube.zip*; \
    rm -rf ${SONARQUBE_HOME}/bin/*; \
    ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar"; \
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"

WORKDIR /home/sonarqube/artifacts
ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-almalinux9-ds.xml

COPY --chmod=755 el9-container-hardening.sh .
#COPY --chmod=755 scan_jars.sh .

RUN \
    bash -c "./el9-container-hardening.sh"; \
    wget --progress=bar:force https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
    oscap oval eval --report sonarqube-alma9-cve-report.html org.almalinux.alsa-9.xml || :; \
    oscap ds sds-validate /usr/share/xml/scap/ssg/content/${BENCHMARK} \ && echo "ok" || echo "exit code = $? not ok"; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results sonarqube_alma9-${SCAP_SNAME}-scap-report.xml \
    --report sonarqube_alma9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
#    cd ${SONARQUBE_HOME}; \
#    bash -c "./scan_jars.sh"; \
#    cd /home/sonarqube/artifacts; \
    freshclam; \
    clamscan -rvi -l clamav_scan.log --exclude-dir="^/sys|^/dev" / || :; \
#    cp /tmp/*html ./; \
    grep -Hrn " FOUND" clamav_scan.log; \
    microdnf remove -y clamav clamav-update openscap scap-security-guide wget unzip epel-release yum-utils; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log

FROM base

ENV JAVA_HOME="/usr/lib/jvm/jre-17-openjdk" \
    SONARQUBE_HOME="/opt/sonarqube" \
    SONAR_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'
    
RUN \
    groupadd -g 65535 sonarqube; \
    useradd -u 65535 -r -g sonarqube sonarqube -m
       
COPY --chown=sonarqube:sonarqube --from=builder /opt/sonarqube /opt/sonarqube
COPY --chown=sonarqube:sonarqube --from=builder /usr/lib/jvm/jre-17-openjdk /usr/lib/jvm/jre-17-openjdk
COPY --chown=sonarqube:sonarqube --from=builder /home/sonarqube /home/sonarqube

RUN \
    chmod -R 555 ${SONARQUBE_HOME}; \
    chmod -R ugo+wrX ${SQ_DATA_DIR} ${SQ_EXTENSIONS_DIR} ${SQ_LOGS_DIR} ${SQ_TEMP_DIR}
    
VOLUME ${SQ_DATA_DIR}
VOLUME ${SQ_EXTENSIONS_DIR}
VOLUME ${SQ_LOGS_DIR}
VOLUME ${SQ_TEMP_DIR}
WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000
USER sonarqube
STOPSIGNAL SIGINT
ENTRYPOINT [ "/usr/lib/jvm/jre-17-openjdk/bin/java", "-jar", "lib/sonarqube.jar", "-Dsonar.log.console=true" ]
