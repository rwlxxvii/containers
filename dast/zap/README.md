## <img src="https://res.cloudinary.com/practicaldev/image/fetch/s--r24tUVpQ--/c_imagga_scale,f_auto,fl_progressive,h_900,q_auto,w_1600/https://dev-to-uploads.s3.amazonaws.com/i/8uadzrkmk3n3tige1kgx.png" width=40% height=40%>

```sh
#make this into a script
tee ./zap-scan.sh<<\EOF
#!/bin/bash
#set -x

DATE=$(date +"%Y%m%d")
MODE=http
TARGET=testhtml5.vulnweb.com
ZAP_API_ALLOW_IP=127.0.0.1
RESULT_DIR=./

mkdir -p ${RESULT_DIR}owasp-zap

#generate random 24 char api key
genkey() {
    cat /dev/urandom | tr -cd 'A-Za-z0-9' | fold -w 24 | head -1
}

#run zap
podman run --rm -v $(pwd):/zap/wrk/:rw -v /etc/localtime:/etc/localtime:ro -u zap -p 8080:8080 -it --name owasp-zap \
-d docker.io/softwaresecurityproject/zap-stable zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.addrs.addr.name=$ZAP_API_ALLOW_IP \
-config api.addrs.addr.regex=true -config api.key=$(genkey)
  
#create result directory
podman exec owasp-zap mkdir -p /zap/results

#execute scan
podman exec owasp-zap zap-full-scan.py -a -j -t ${MODE}://${TARGET} -r /zap/results/zap-report-${MODE}-${TARGET}-${DATE}.html

#get results
podman cp owasp-zap:/zap/results/ $RESULT_DIR/owasp-zap
EOF

chmod +x ./zap-scan.sh; ./zap-scan.sh

#save container as OCI image; NOTE: automate this buy building in CI pipe, saving OCI tar, push image to repository
podman save -o oci-owasp-zap.tar --format oci-archive owasp-zap

#load to repository
podman load -q -i oci-owasp-zap.tar
```

Dockerfile and ansible playbooks.

To-do's: 

         k8s yaml's

         nomad with podman automation
