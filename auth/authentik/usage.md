## generate password

```sh
apt|dnf install -y pwgen

echo "PG_PASS=$(pwgen -s 40 1)" >> .env
echo "AUTHENTIK_SECRET_KEY=$(pwgen -s 50 1)" >> .env
# Because of a PostgreSQL limitation, only passwords up to 99 chars are supported
```