## Metasploit framework

```sh
|                                                                              |
|                   METASPLOIT CYBER MISSILE COMMAND V5                        |
|______________________________________________________________________________|
      \                                  /                      /
       \     .                          /                      /            x
        \                              /                      /
         \                            /          +           /
          \            +             /                      /
           *                        /                      /
                                   /      .               /
    X                             /                      /            X
                                 /                     ###
                                /                     # % #
                               /                       ###
                      .       /
     .                       /      .            *           .
                            /
                           *
                  +                       *

                                       ^
####      __     __     __          #######         __     __     __        ####
####    /    \ /    \ /    \      ###########     /    \ /    \ /    \      ####
################################################################################
################################################################################
# WAVE 5 ######## SCORE 31337 ################################## HIGH FFFFFFFF #
################################################################################
                                                           https://metasploit.com


sudo addgroup -g 65535 metasploit
sudo adduser -h /home/metasploit --uid 65535 --ingroup metasploit metasploit
sudo passwd metasploit

modprobe tun
echo tun >>/etc/modules
echo metasploit:165536:65536 >/etc/subuid
echo metasploit:165536:65536 >/etc/subgid

sudo tee /etc/sysctl.d/99-metasploit-pod.conf<<\EOF
[main]
summary= <1024 ports for metasploit to use
[sysctl]
net.ipv4.ip_unprivileged_port_start=80
net.ipv4.ip_unprivileged_port_start=443
net.ipv4.ip_unprivileged_port_start=445
EOF

sudo sysctl -p /etc/sysctl.d/99-metasploit-pod.conf

sudo -u metasploit bash

#local build
podman build -t msf .
podman network create msf
podman run --rm -it --security-opt=no-new-privileges --network msf --name msf msf

```
