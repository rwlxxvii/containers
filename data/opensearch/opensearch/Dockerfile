ARG OPENSEARCH_VERSION

FROM docker.io/opensearchproject/opensearch:${OPENSEARCH_VERSION}

RUN \
    declare -a PLUGIN=( \
    "opensearch-alerting" \
    "opensearch-anomaly-detection" \
    "opensearch-asynchronous-search" \
    "opensearch-geospatial" \
    "opensearch-index-management" \
    "opensearch-job-scheduler" \
    "opensearch-ml" \
    "opensearch-performance-analyzer" \
    "opensearch-security" \
    "opensearch-reports-scheduler"); \
    for ((i=0; i<${#PLUGIN[@]}; i++)); do /usr/share/opensearch/bin/opensearch-plugin install --batch ${PLUGIN[$i]} done
