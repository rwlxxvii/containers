# syntax=docker/dockerfile:1
# kafka: Apache Kafka is an open-source distributed event streaming platform used by thousands of companies for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.
ARG repo="docker.io" \
    base_image="alpine:3.18" \
    image_hash="48d9183eb12a05c99bcc0bf44a003607b8e941e1d4f41f9ad12bdcc4b5672f86"
    
FROM ${repo}/${base_image}@sha256:${image_hash}

ENV KAFKA_VERSION 3.6.0 \
    SCALA_VERSION 2.13

WORKDIR /opt

RUN apk add --no-cache bash \
                        docker \
                        coreutils \
                        openjdk17-jre \
                        su-exec; \
    apk add --no-cache -t .kafka-deps ca-certificates \
                                      curl \
                                      jq; \
    mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'); \
    curl -sSL "${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | tar -xzf - -C . ;\
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ./kafka; \
    addgroup -g 65535 kafka; \
    adduser --shell /sbin/nologin --disabled-password -h /home/kafka --uid 65535 --ingroup kafka kafka; \
    chown -R kafka:kafka /opt/kafka; \
    rm -rf /var/cache/apk/* /tmp/*; \
    apk del --purge .kafka-deps

ENV PATH="/sbin:/opt/kafka/bin/:$PATH"

WORKDIR /opt/kafka/config

VOLUME /tmp/kafka-logs

EXPOSE 9092 2181

COPY --chown=kafka:kafka config/server.properties .
COPY --chown=kafka:kafka config/zookeeper.properties .
COPY --chmod=755 kafka-entrypoint.sh /kafka-entrypoint.sh
COPY --chown=kafka:kafka scripts /

RUN find /scripts -name "*.sh" -exec chmod +x {} \;

ENTRYPOINT [ "/kafka-entrypoint.sh" ]
CMD [ "kafka-server-start.sh", "config/server.properties" ]
