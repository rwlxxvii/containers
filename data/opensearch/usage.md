## usage

NOTE: WIP

System requirements:

```sh

sudo sysctl -w vm.max_map_count=262144
reboot

```

Configure env variables:

```sh
tee ./.env<<EOF
OPENSEARCH_VERSION=2.11.1
OPENSEARCH_PASSWORD='changeme'
DATAPREPPER_INTERNAL_PASSWORD='changeme'
DASHBOARDS_SYSTEM_PASSWORD='changeme'
LOGSTASH_INTERNAL_PASSWORD='changeme'
EOF
```
Build:

```sh
podman-compose up -d
```
