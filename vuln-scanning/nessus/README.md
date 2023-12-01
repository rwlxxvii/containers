
#

> **Note**
>
> installing podman-compose -
>
> sudo curl -o /usr/local/bin/podman-compose \
>
> https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py
>
> sudo chmod +x /usr/local/bin/podman-compose
>
> alias podman-compose=/usr/local/bin/podman-compose
>
> [What is Podman?>](https://www.redhat.com/en/topics/containers/what-is-podman)
>
> [Installing Podman>](https://podman.io/getting-started/installation)
>
> [What is Nessus?>](https://www.tenable.com/products/nessus)
>
> [Activation Code>](https://www.tenable.com/products/nessus/activation-code)
>


#


```sh
# Create .env file for build:

sudo tee ./.env<< EOF
# Credentials setup
NESSUS_USERNAME=
NESSUS_PASSWORD='   '
ACTIVATION_CODE=
EOF

#firewall ports
firewall-cmd --permanent --new-policy nessus
firewall-cmd --permanent --policy nessus --set-target DROP
firewall-cmd --permanent --policy nessus --add-ingress-zone public
firewall-cmd --permanent --policy nessus --add-egress-zone internal
firewall-cmd --permanent --policy nessus --add-port=443/tcp
firewall-cmd --permanent --policy nessus --add-port=8834/tcp
firewall-cmd --reload

podman-compose up -d

echo "localhost   nessus.testing.io" | tee -a /etc/hosts
```

Login to https://nessus.testing.io:8834 with username/password set in .env

```sh
# To create a new custom CA and server certificate:
podman exec -it nessus /bin/bash
echo -ne "<CA Days>\n<Cert Days>\n<Country>\n<State>\n<Locale>\n<OrgName>\nnessus.testing.io\ny" | /opt/nessus/sbin/nessuscli mkcert
```
