#!/bin/bash

set -e
source ./env

mkdir -p /home/keycloak/certs
cd /home/keycloak/certs

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

openssl req -new -key keycloak.key.pem -out keycloak.csr -config csr.conf

openssl x509 -req -in keycloak.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out keycloak.crt.pem -days 365 \
-extfile csr.conf
