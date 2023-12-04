ARG DASHBOARDS_VERSION

FROM docker.io/opensearchproject/opensearch-dashboards:${DASHBOARDS_VERSION}

RUN \
    declare -a PLUGIN=( \
    "alerting-dashboards-plugin" \
    "anomaly-detection-dashboards-plugin" \
    "dashboards-search-relevance" \
    "index-management-dashboards-plugin" \
    "dashboards-notifications" \
    "dashboards-observability" \
    "query-workbench" \
    "dashboards-reporting" \
    "security-analytics-dashboards-plugin" \
    "security-dashboards-plugin"); \
    for ((i=0; i<${#PLUGIN[@]}; i++)); do /usr/share/opensearch/bin/opensearch-plugin install ${PLUGIN[$i]} done
