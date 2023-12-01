IMG=docker.io/fluentd
docker build -t $IMG .
docker push $IMG
