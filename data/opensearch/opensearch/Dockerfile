ARG OPENSEARCH_VERSION

FROM docker.io/opensearchproject/opensearch:${OPENSEARCH_VERSION}

RUN \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-alerting; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-anomaly-detection; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-asynchronous-search; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-geospatial; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-index-management; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-job-scheduler; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-ml; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-performance-analyzer; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-security; \
    /usr/share/opensearch/bin/opensearch-plugin install --batch opensearch-reports-scheduler
