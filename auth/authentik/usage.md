## generate random password methods

```sh
genkey() {
    cat /dev/urandom | tr -cd 'A-Za-z0-9' | fold -w 46 | head -1
}

echo "POSTGRESQL_PASSWORD=$(genkey)" >> .env
echo "AUTHENTIK_SECRET_KEY=$(genkey)" >> .env

# using pwgen
apt|dnf install -y pwgen

echo "POSTGRESQL_PASSWORD=$(pwgen -s 40 1)" >> .env
echo "AUTHENTIK_SECRET_KEY=$(pwgen -s 50 1)" >> .env
# Because of a PostgreSQL limitation, only passwords up to 99 chars are supported
```