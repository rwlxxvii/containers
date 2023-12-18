# syntax=docker/dockerfile:1
# artifactory-oss: JFrog Artifactory is the single solution for housing and managing all the artifacts,
# binaries, packages, files, containers, and components for use throughout your software supply chain.
ARG repo="quay.io/almalinuxorg" \
    base_image="9-minimal" \
    image_hash="dbe9e629bda941bbc557666cb8fcc184b0ce40e92eaff66eaca2aefde9e5ac35"

FROM ${repo}/${base_image}@sha256:${image_hash}

ENV TINI_VERSION v0.19.0
ENV JAVA_HOME "/usr/lib/jvm/jre-17-openjdk"
ENV JFROG_HOME "/opt/jfrog"

RUN \
    microdnf install -y \
        bash \
        java-17-openjdk \
        wget; \
    \
    echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"; \
    sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"; \
    \
    wget https://releases.jfrog.io/artifactory/artifactory-rpms/artifactory-rpms.repo -O jfrog-artifactory-rpms.repo; \
    mv jfrog-artifactory-rpms.repo /etc/yum.repos.d/; \
    microdnf install -y jfrog-artifactory-oss; \
    \
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
    chown -R artifactory:artifactory "${JFROG_HOME}"; \
    export JFROG_HOME=${JFROG_HOME}; \
    find /opt/jfrog/artifactory/app/bin/ -name "*sh" -exec chmod 0755 {} \;

COPY system.yaml /opt/jfrog/artifactory/var/etc/system.yaml

ENTRYPOINT [ "/usr/bin/tini", "--", \
             "/opt/jfrog/artifactory/app/bin/artifactoryctl" ]
# NOTE: It is highly recommended to use Artifactory with an external database (MySQL, Oracle, Microsoft SQL Server, PostgreSQL, MariaDB).
# standup an external DB and modify "system.yaml" with configs to connect to the running DB.
