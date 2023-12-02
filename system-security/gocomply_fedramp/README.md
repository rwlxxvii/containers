## gocomply SSP generator

This will fill some of the data as a launching point for the SSP draft.

Redhat XML's located here:  https://github.com/ComplianceAsCode/oscal/tree/master/xml

Modify XML (via vscode) with control response and load in container to generate the document in docx format.

Topologies, architecture/data flow diagram's, and supporting artifacts/attachments can be loaded into the SSP after most of it is automated.

Before building the container modify the Dockerfile with a template or modified xml

```sh
# replace source url with template or modified xml with control responses
# generate ssp docx from xml
RUN set -eux; \
    	\
     wget https://raw.githubusercontent.com/ComplianceAsCode/oscal/master/xml/rhel-8-fedramp-High.xml; \
     gocomply_fedramp convert ./rhel-8-fedramp-High.xml FedRAMP-High-rhel8.docx
```

As a user, and not root:
```sh
#build image and have image generate SSP

podman build -t gocomply_fedramp .
podman network create oscal

#run container to get .docx

podman run --rm -it --security-opt=no-new-privileges --network oscal --name oscal -d gocomply_fedramp

#get SSP draft

podman cp oscal:/home/oscal ./

#destroy build environment

podman image prune -f; podman rmi alpine:edge -f

#delete container/image

podman rmi -f gocomply_fedramp
```
