#!/bin/sh -e

# Install prerequisites.
apt update -y

apt install -y \
  curl ca-certificates make g++ sudo bash git

# Install Fluentd.
/usr/bin/curl -sSL https://toolbelt.treasuredata.com/sh/install-ubuntu-xenial-td-agent4.sh | sh

# Change the default user and group to root.
# Needed to allow access to /var/log/docker/... files.
sed -i -e "s/USER=td-agent/USER=root/" -e "s/GROUP=td-agent/GROUP=root/" /etc/init.d/td-agent

# Install the Elasticsearch Fluentd plug-in.
td-agent-gem install --no-document fluent-plugin-kubernetes_metadata_filter_v0.14 -v 0.24.1
td-agent-gem install --no-document fluent-plugin-elasticsearch -v 5.2.4

