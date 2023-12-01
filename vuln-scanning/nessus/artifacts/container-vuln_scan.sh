#!/bin/bash

mkdir -p ./scan_results/{trivy-cache,trivy-output,syft,grype}

declare -a D_IMAGE=(
"docker.io/tenableofficial/nessus:latest"
"docker.io/wallarm/api-firewall:latest"
"docker.io/traefik:latest")
declare -a R_NAME=(
"nessus"
"api-firewall"
"traefik")

for ((i=0; i<${#D_IMAGE[@]}; i++)); do
# json output
podman run --rm -v ./scan_results/trivy-cache/:/root/.cache/:z \
                -v ./scan_results/trivy-output:/output:z \
                docker.io/aquasec/trivy image \
                -f json -o /output/${R_NAME[$i]}-report.json \
                ${D_IMAGE[$i]}
done
for ((i=0; i<${#D_IMAGE[@]}; i++)); do
# html output
podman run --rm -v ./scan_results/trivy-cache/:/root/.cache/:z \
                -v ./scan_results/trivy-output:/output:z \
                docker.io/aquasec/trivy image \
                --format template --template "@contrib/html.tpl" -o /output/${R_NAME[$i]}-report.html \
                ${D_IMAGE[$i]}
done

# syft scans
# installs local syft binary, runs scans, outputs results, and bin is deleted after run
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
for ((i=0; i<${#D_IMAGE[@]}; i++)); do
/usr/local/bin/syft ${D_IMAGE[$i]} -o syft-json=./scan_results/syft/${R_NAME[$i]}_sw-list.json
done
for ((i=0; i<${#D_IMAGE[@]}; i++)); do
/usr/local/bin/syft ${D_IMAGE[$i]} -o syft-table=./scan_results/syft/${R_NAME[$i]}_sw-list.csv
done

#install and run grype to get csv vuln output
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
for ((i=0; i<${#D_IMAGE[@]}; i++)); do
/usr/local/bin/grype ${D_IMAGE[$i]} -o table --file ./scan_results/grype/${R_NAME[$i]}_vulnerabilities.csv
done

#cleanup
podman rmi aquasec/trivy -f
rm -f /usr/local/bin/syft /usr/local/bin/grype
echo "==========================================
See findings in ./scan_results/ directory.
=========================================="
