#!/bin/bash

SONARQUBE_VERSION=10.2.0.77647
SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
SONARQUBE_HOME=/opt/sonarqube
SONAR_VERSION="${SONARQUBE_VERSION}"
SQ_DATA_DIR="/opt/sonarqube/data"
SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions"
SQ_LOGS_DIR="/opt/sonarqube/logs"
SQ_TEMP_DIR="/opt/sonarqube/temp"

apt-get update -yq
apt-get install -y openjdk-17-jre gnupg unzip curl bash sudo fonts-dejavu
groupadd --system --gid 1007 sonarqube
useradd --system --uid 1007 --gid sonarqube sonarqube
usermod --shell /bin/bash sonarqube

cd /opt
for server in $(shuf -e hkps://keys.openpgp.org
hkps://keyserver.ubuntu.com) ; do
gpg --batch --keyserver "${server}" --recv-keys 679F1EE92B19609DE816FDE81DB198F93525EC1A && break || : ;
done
curl --fail --location --output sonarqube.zip --silent --show-error "${SONARQUBE_ZIP_URL}"
curl --fail --location --output sonarqube.zip.asc --silent --show-error "${SONARQUBE_ZIP_URL}.asc"
gpg --batch --verify sonarqube.zip.asc sonarqube.zip
unzip -q sonarqube.zip
mv "sonarqube-${SONARQUBE_VERSION}" sonarqube
rm -f sonarqube.zip*
rm -rf ${SONARQUBE_HOME}/bin/*
ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar"
chmod -R 555 ${SONARQUBE_HOME}
chmod -R ugo+wrX "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}"
echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security"
sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security"

runuser -l sonarqube -c '/usr/lib/jvm/java-17-openjdk-amd64/bin/java -jar /opt/sonarqube/lib/sonarqube.jar -Dsonar.log.console=true'

