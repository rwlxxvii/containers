# syntax=docker/dockerfile:1
# sonarqube: clean code for teams and enterprises.
ARG repo="quay.io/almalinuxorg" \
    base_image="9-minimal" \
    image_hash="bc83a80849984abca9a46d50cb163d2cd30255fd37485bc294bf817897ed7c26"

FROM ${repo}/${base_image}@sha256:${image_hash} AS base

LABEL \
    org.opencontainers.image.name='SonarQube' \
    org.opencontainers.image.description='Clean code for teams and enterprises.' \
    org.opencontainers.image.usage='https://docs.sonarqube.org/latest/' \
    org.opencontainers.image.url='https://www.sonarsource.com/products/sonarqube/' \
    org.opencontainers.image.licenses='GNU Lesser General Public License v3.0' \
    org.opencontainers.image.vendor='Sonar' \
    org.opencontainers.image.schema-version='10.4.1.88267'

COPY --chmod=755 el9-container-hardening.sh .
    
RUN \
    microdnf install -y bash \
                        glibc-langpack-en \
                        dejavu-sans-fonts \
                        java-17-openjdk \
                        wget; \
    bash -c "./el9-container-hardening.sh" || :

FROM base AS builder

ARG SONARQUBE_VERSION="10.4.1.88267"
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
    wget -O sonarqube.zip ${SONARQUBE_ZIP_URL}; \
    wget -O sonarqube.zip.asc ${SONARQUBE_ZIP_URL}.asc; \
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

#COPY --chmod=755 scan_jars.sh .

RUN \
    wget https://security.almalinux.org/oval/org.almalinux.alsa-9.xml; \
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
    LC_ALL='en_US.UTF-8' \
    TINI_VERSION="v0.19.0"
    
RUN \
    groupadd -g 65535 sonarqube; \
    useradd -u 65535 -g sonarqube sonarqube -m
       
COPY --chown=sonarqube:sonarqube --from=builder ${SONARQUBE_HOME} ${SONARQUBE_HOME}
COPY --chown=sonarqube:sonarqube --from=builder ${JAVA_HOME} ${JAVA_HOME}
COPY --chown=sonarqube:sonarqube --from=builder /home/sonarqube /home/sonarqube
#COPY --chown=sonarqube:sonarqube trendmicro/trend_app_protect-4.4.6.jar ${SONARQUBE_HOME}/lib
#ARG TMICRO_KEY=
#ARG TMICO_SECRET=

RUN \
# trendmicro app protect properties
#    echo -e $'key = ${TMICRO_KEY} \n\
#    secret = ${TMICO_SECRET}' | tee ${SONARQUBE_HOME}/lib/trend_app_protect.properties; \
# datadog java trace monitoring
#    wget https://dtdg.co/latest-java-tracer -O ${SONARQUBE_HOME}/lib/dd-java-agent.jar; \
# elastic APM
#    wget https://oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=co.elastic.apm&a=elastic-apm-agent&v=LATEST \
#    -O ${SONARQUBE_HOME}/lib/elastic-apm-agent.jar; \
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
    chmod 0555 /usr/bin/tini; \
    chmod -R 555 ${SONARQUBE_HOME}; \
    chmod -R ugo+wrX ${SQ_DATA_DIR} ${SQ_EXTENSIONS_DIR} ${SQ_LOGS_DIR} ${SQ_TEMP_DIR}

#ARG APM_SERVER_URL=
VOLUME ${SQ_DATA_DIR}
VOLUME ${SQ_EXTENSIONS_DIR}
VOLUME ${SQ_LOGS_DIR}
VOLUME ${SQ_TEMP_DIR}
WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000
USER sonarqube
STOPSIGNAL SIGINT
# trendmicro app protect
#ENTRYPOINT [ "/usr/lib/jvm/jre-17-openjdk/bin/java", \
#                "-javaagent:lib/trend_app_protect-4.4.6.jar", \
#                "-Dcom.trend.app_protect.config.file=lib/trend_app_protect.properties", \
#                "-jar", \
#                "lib/sonarqube.jar", \
#                "-Dsonar.log.console=true" ]
# elastic APM init
#ENTRYPOINT [ "/usr/lib/jvm/jre-17-openjdk/bin/java", \
#                "-javaagent:lib/elastic-apm-agent.jar", \
#                "-Delastic.apm.service_name=sonarqube-service", \
#                "-Delastic.apm.application_packages=org.sonar.server.app.WebServer,org.sonar.process.PluginSecurityManager,org.sonar.server.platform.web,\
#                org.sonar.server.authentication,org.sonar.server.saml,org.sonar.server.plugins,org.sonar.ce.app.CeServer", \
#                "-Delastic.apm.server_url=${APM_SERVER_URL}:8200", \
#                "-jar", \
#                "lib/sonarqube.jar", \
#                "-Dsonar.log.console=true" ]
# datadog init
#ENTRYPOINT [ "/usr/lib/jvm/jre-17-openjdk/bin/java", \
#                "-javaagent:lib/dd-java-agent.jar", \
#                "-Ddd.profiling.enabled=true", \
#                "-XX:FlightRecorderOptions=stackdepth=256", \
#                "-Ddd.logs.injection=true", \
#                "-Ddd.service=sonarqube", \
#                "-Ddd.env=development", \
#                "-Ddd.version=1.0", \
#                "-jar", \
#                "lib/sonarqube.jar", \
#                "-Dsonar.log.console=true" ]
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/usr/lib/jvm/jre-17-openjdk/bin/java", "-jar", "lib/sonarqube.jar", "-Dsonar.log.console=true" ]
