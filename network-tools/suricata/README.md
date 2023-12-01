## Suricata

[What is Suricata?>](https://suricata.io/)

#
```sh

podman build -t suricata .

#remove build environment and base image
podman image prune -f; podman rmi 9-minimal -f

#-i is the interface, below suricata is monitoring my external int to the internet "wlo1"

podman run --rm -it --name suricata --net=host --cap-add=net_admin --cap-add=net_raw \
           --cap-add=sys_nice -v <directory for logs to go>:/var/log/suricata:Z \
           -d suricata -i wlo1

#Optional
#disable stream alerts
#very noisy, but if you want thousands of protocol decode messages...
#helpful for L7 troubleshooting, but in this case we are worried about ET alerts

podman exec -it suricata /bin/bash
touch /etc/suricata/disable.conf
echo "group:stream-events.rules" | tee -a /etc/suricata/disable.conf
chown -R suricata:suricata /etc/suricata
suricata-update
exit

#verify events/alerts capture:

tail -f <path to directory>/fast.log
tail -f <path to directory>/eve.json | jq

```

IPS/Inline setup - https://suricata.readthedocs.io/en/latest/setting-up-ipsinline-for-linux.html#
