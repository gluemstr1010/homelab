#!/bin/sh

name="grafana.homelab.org"
alias="graf.homelab.org"

openssl genrsa -out keys/$name.key 2048
cat << EOF >> confs/$name.conf
[ req ]
default_bits        = 2048
prompt              = no
default_md          = sha256
distinguished_name  = dn
req_extensions      = req_ext

[ dn ]
CN = $name

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $name
DNS.2 = $alias
EOF

openssl req -new -key keys/$name.key -out csr/$name.csr -config confs/$name.conf
openssl x509 -req -in csr/$name.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out crts/$name.crt -days 365 -sha256
openssl x509 -in crts/$name.crt -text -noout
