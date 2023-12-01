Generate CA, Server cert/key

```sh

# variables to pass to csr config file
# modify before executing...

COUNTRY="US"
STATE="FL"
LOCALE="Da Beach"
ORG="UMBRELLA_CORP"
ORG_UNIT="ReaperActual"
COMMON_NAME="sonarqube.io"
CA_CN="Sonarqube Root CA"
SUBJ_ALT_NAME1="sonarqube"
SUBJ_ALT_NAME2="www.sonarqube.io"
IP1=
IP2=

tee csr.conf<<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha384
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = $(echo $COUNTRY)
ST = $(echo $STATE)
L = $(echo $LOCALE)
O = $(echo $ORG)
OU = $(echo $ORG_UNIT)
CN = $(echo $COMMON_NAME)

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $(echo $SUBJ_ALT_NAME1)
DNS.2 = $(echo $SUBJ_ALT_NAME2)
IP.1 = $(echo $IP1)
IP.2 = $(echo $IP2)
EOF

#generate CA, server certificate and key

openssl genrsa -out ca.key 4096 

openssl req -new -x509 -days 730 -key ca.key \
-subj "/C=$(echo $COUNTRY)/ST=$(echo $STATE)/L=$(echo $LOCALE)/O=$(echo $ORG)/CN=$(echo $CA_CN)" -out ca.crt

openssl req -new -key sonarqube.key -out sonarqube.csr -config csr.conf

openssl x509 -req -in sonarqube.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out sonarqube.crt -days 365 \
-extfile csr.conf

```
