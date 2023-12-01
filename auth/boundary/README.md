## Hashicorp Boundary

<p align="center">
  <img src="https://developer.hashicorp.com/_next/image?url=https%3A%2F%2Fcontent.hashicorp.com%2Fapi%2Fassets%3Fproduct%3Dboundary%26version%3Drefs%252Fheads%252Fstable-website%26asset%3Dwebsite%252Fpublic%252Fimg%252Fboundary-core-workflow.png%26width%3D763%26height%3D696&w=828&q=75" />
</p>

AWS Example:
<p align="center">
  <img src="https://raw.githubusercontent.com/hashicorp/boundary-reference-architecture/main/arch.png" />
</p>

Requirements:

There are a few requirements for running dev mode:

- Docker/Podman is installed

- A route to download the Postgres Docker image is available or a local image cache is available

- A Boundary binary in your $PATH

```sh
sudo tee ./.env<< EOF
POSTGRES_PASS=< ....... >
EOF
```

```sh
podman-compose up -d
podman exec -it postgres-boundary /bin/bash
```

```sh
1001@704fa0524868:/$ psql -U postgres -W
Password: 
#enter password for postgres user

    create user boundary with encrypted password '_enter a password here_';
    create database boundary with owner boundary encoding 'UTF8';
    \q

exit
```

```sh
podman inspect postgres-boundary | grep IPAddress
```

```sh
PSQL_IP=
DB_PASS=

podman build -t boundary .
podman network create boundary
podman run --rm -it --name boundary --network boundary --cap-add IPC_LOCK \
-e 'BOUNDARY_POSTGRES_URL=postgresql://boundary:${DB_PASS}@${PSQL_IP}:5432/boundary?sslmode=disable' \
-p 9200:9200 -p 9201:9201 -p 9202:9202 boundary

```

```sh
boundary authenticate
```

http://127.0.0.1:9200/
