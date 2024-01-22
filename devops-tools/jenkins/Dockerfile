FROM docker.io/oraclelinux:9 as jre-build
ARG BUILD_NUMBER=34
ARG JAVA_VERSION=21+${BUILD_NUMBER}
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x; dnf install -y jq wget; \
    JAVA_VERSION_ENCODED=$(echo "$JAVA_VERSION" | jq "@uri" -jRr); \
    CONVERTED_ARCH=$(arch | sed 's/x86_64/x64/'); \
    wget --quiet https://github.com/adoptium/temurin21-binaries/releases/download/jdk-"${JAVA_VERSION_ENCODED}"-ea-beta/OpenJDK21U-jdk_"${CONVERTED_ARCH}"_linux_hotspot_ea_21-0-"${BUILD_NUMBER}".tar.gz -O /tmp/jdk.tar.gz; \
    dnf clean all; \
    tar -xzf /tmp/jdk.tar.gz -C /opt/; \
    rm -f /tmp/jdk.tar.gz

ENV PATH=/opt/jdk-${JAVA_VERSION}/bin:$PATH

RUN jlink \
    --add-modules ALL-MODULE-PATH \
    --no-man-pages \
    --compress=zip-6 \
    --output /javaruntime

# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.
#ENV SNYK_API=

#run SCA scan against source code
#WORKDIR /tmp
#RUN set -x; \
#    dnf install -y npm; \
#    wget https://github.com/jenkinsci/jenkins/archive/refs/heads/master.zip; \
#    unzip master.zip; cd jenkins-master; \
#    npm install -g snyk; \
#    npm install snyk-to-html -g; \
#    snyk config set api=${SNYK_API}; \
#    snyk code test --json | snyk-to-html -o /jenkins-code-review.html; \
#    snyk test --json | snyk-to-html -o /jenkins-deps.html; \
#    snyk monitor; \
#    npm uninstall -g snyk; \
#    npm uninstall -g snyk-to-html; \
#    dnf remove -y npm

FROM docker.io/oraclelinux:9

ENV LANG C.UTF-8

ARG TARGETARCH
ARG COMMIT_SHA

RUN dnf install --disableplugin=subscription-manager --setopt=install_weak_deps=0 --setopt=tsflags=nodocs -y \
        fontconfig \
        freetype \
        git \
        git-lfs \
        unzip \
        which \
        tzdata; \
    dnf clean --disableplugin=subscription-manager all

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME; \
    chown ${uid}:${gid} $JENKINS_HOME; \
    groupadd -g ${gid} ${group}; \
    useradd -N -d "$JENKINS_HOME" -u ${uid} -g ${gid} -l -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.19.0
COPY tini_pub.gpg "${JENKINS_HOME}/tini_pub.gpg"
RUN curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TARGETARCH}" -o /sbin/tini; \
    curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TARGETARCH}.asc" -o /sbin/tini.asc; \
    gpg --no-tty --import "${JENKINS_HOME}/tini_pub.gpg"; \
    gpg --verify /sbin/tini.asc; \
    rm -rf /sbin/tini.asc /root/.gnupg; \
    chmod +x /sbin/tini

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.418}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=7edc92816d30f8cef0241faa60c068f75ddf824152808b347007b9072df49191

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war; \
    echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" >/tmp/jenkins_sha; \
    sha256sum -c --strict /tmp/jenkins_sha; \
    rm -f /tmp/jenkins_sha

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

ARG PLUGIN_CLI_VERSION=2.12.13
ARG PLUGIN_CLI_URL=https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PLUGIN_CLI_VERSION}/jenkins-plugin-manager-${PLUGIN_CLI_VERSION}.jar
RUN curl -fsSL ${PLUGIN_CLI_URL} -o /opt/jenkins-plugin-manager.jar

# for main web interface:
EXPOSE ${http_port}

# will be used by attached agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY jenkins-plugin-cli.sh /bin/jenkins-plugin-cli
# from a derived Dockerfile, can use `RUN install-plugins.sh active.txt` to setup $REF/plugins from a support bundle
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

# Run hardening script and collect build security artifacts, SCA/Compliance/CVE/AV
WORKDIR ${JENKINS_HOME}/artifacts
ARG SCAP_PROFILE=xccdf_org.ssgproject.content_profile_stig
ARG SCAP_SNAME=STIG
ARG BENCHMARK=ssg-ol9-ds.xml

COPY el9-container-hardening.sh .
#COPY --chown=${user}:${user} --from=jre-build /jenkins-code-review.html .
#COPY --chown=${user}:${user} --from=jre-build /jenkins-deps.html .

RUN set -x; \
    	\
    chmod +x ./el9-container-hardening.sh; \
    bash -c "./el9-container-hardening.sh"; \
    wget https://linux.oracle.com/security/oval/com.oracle.elsa-ol9.xml.bz2; \
    bzip2 -d com.oracle.elsa-ol9.xml.bz2; \
    oscap oval eval --report jenkins-ol9-cve-report.html com.oracle.elsa-ol9.xml || :; \
    oscap xccdf eval --profile ${SCAP_PROFILE} --results jenkins_ol9-${SCAP_SNAME}-scap-report.xml \
    --report jenkins_ol9-${SCAP_SNAME}-scap-report.html /usr/share/xml/scap/ssg/content/${BENCHMARK} || :; \
    freshclam; \
    clamscan -r -v -i -l ./AV_scan.log --exclude-dir="^/sys" / || :; \
    cp /tmp/*html ./; \
    chown -R ${user}:${user} ${JENKINS_HOME}; \
    grep -Hrn " FOUND" ./AV_scan.log; \
    dnf remove -y clamav clamav-update openscap scap-security-guide wget bzip2 unzip; \
    dnf clean all; \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*; \
    truncate -s 0 /var/log/*log

USER ${user}
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
