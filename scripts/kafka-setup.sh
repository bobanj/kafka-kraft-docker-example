#!/bin/bash

if [ ! -f "/tmp/clusterID/clusterID" ]; then
  kafka-storage random-uuid > /tmp/clusterID/clusterID
  echo "Cluster id has been created and set..."
fi

cat /tmp/clusterID/clusterID
export CLUSTER_ID=$(cat "/tmp/clusterID/clusterID")
echo "Cluster id is ${CLUSTER_ID}"
if ! [ -f "/etc/kafka/secrets/ca.pem" ]; then
  cd /etc/kafka/secrets/
  rm -rf *.pem *.req *.jks *.pfx *.srl *-pass
  # Gen CA key
  openssl genrsa -passout "pass:confluent" -aes256 -out ca-key.pem 4096
  # Gen CA
  openssl req -new -key ca-key.pem -x509 -out ca.pem -days 3650 -subj '/CN=Local CA/OU=Dev/O=Local CA/L=Hamburg/ST=HH/C=DE' -passin pass:confluent -passout pass:confluent

  # Generate certificate request
  openssl req -passin "pass:confluent" -passout "pass:confluent" -new -nodes -newkey rsa:4096 -keyout kafka-key.pem -out kafka.req -batch -config <(printf "[req]\ndistinguished_name = req_distinguished_name\nreq_extensions = v3_req\nprompt = no\n[req_distinguished_name]\nC = US\nST = VA\nL = SomeCity\nO = LOCAL\nOU = IT\nCN = kafka\n[v3_req]\nkeyUsage = keyEncipherment, dataEncipherment\nextendedKeyUsage = serverAuth\nsubjectAltName = @alt_names\n[alt_names]\nDNS.1 = kafka\nDNS.2 = localhost\nIP.1 = 127.0.0.1\n")
  # Generate certificate
  openssl x509 -req -in kafka.req -CA ca.pem -CAkey ca-key.pem -passin "pass:confluent" -CAcreateserial -out kafka.pem -days 3650 -sha256 -extfile <(printf "subjectAltName=DNS:kafka,DNS:localhost,IP:127.0.0.1")

  cat kafka.pem ca.pem > bundle.pem

  openssl pkcs12 -export -out bundle.pfx -inkey kafka-key.pem -in bundle.pem -password pass:confluent
  keytool -importkeystore -srckeystore bundle.pfx -srcstoretype PKCS12 -deststorepass confluent -destkeypass confluent -destkeystore keystore.jks -srcstorepass confluent

  keytool -import -trustcacerts -alias ca -file ca.pem -keystore truststore.jks -deststorepass confluent -noprompt

  printf "confluent" > keystore-pass
  printf "confluent" > truststore-pass

  printf "ssl.key.password=confluent\nssl.truststore.password=confluent\nssl.keystore.password=confluent\nssl.keystore.location=/etc/kafka/secrets/keystore.jks\nssl.truststore.location=/etc/kafka/secrets/truststore.jks\nssl.endpoint.identification.algorithm=https\nsecurity.protocol=SASL_SSL\nsasl.mechanism=SCRAM-SHA-512\nsasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username=\"root\" password=\"rootpassword\";\n" > /etc/kafka/secrets/client.properties
fi

dub template "/etc/confluent/docker/kafka.properties.template" "/etc/kafka/kafka.properties"
kafka-storage format --config /etc/kafka/kafka.properties --cluster-id ${CLUSTER_ID} --add-scram SCRAM-SHA-512=[name=root,iterations=8192,password=rootpassword] --ignore-formatted