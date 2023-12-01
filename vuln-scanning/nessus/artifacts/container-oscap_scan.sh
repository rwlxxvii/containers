#!/bin/bash

<<comment
==========================================================================
Summary:  This shell script will scan a container image with the scap
          content set in ${XCCDF} and output the following profiles:
          STIG
          CUI Non-Federal (NIST 800-171)
          HIPAA
          PCI-DSS
          - Outputs stig viewer xml importable into a ckl and html reports.
==========================================================================
comment

# set variable list for oscap scan profiles and report names
declare -a PROFILE=(
"xccdf_org.ssgproject.content_profile_stig"
"xccdf_org.ssgproject.content_profile_cui"
"xccdf_org.ssgproject.content_profile_hipaa"
"xccdf_org.ssgproject.content_profile_pci-dss")
declare -a REPORT_NAME=(
"stig"
"cui"
"hipaa"
"pci-dss")
#Set image name to scan, and report name
NAME=nessus:latest
IMAGE_NAME=docker.io/tenableofficial/nessus:latest
#Set the scap content
#View available scap content
#$ ls /usr/share/xml/scap/ssg/content/
XCCDF=ssg-ol8-ds.xml

#install oscap
dnf update -y && dnf install openscap openscap-utils scap-security-guide -y

mkdir -p ./scan_results/oscap

#Generate STIGViewer xml to import into checklist
oscap-podman ${IMAGE_NAME} xccdf eval --profile xccdf_org.ssgproject.content_profile_stig \
--stig-viewer ./scan_results/oscap/${NAME}-stig-viewer.xml /usr/share/xml/scap/ssg/content/${XCCDF}

#Generate HTML summary report of findings for all profiles declared
for ((i=0; i<${#PROFILE[@]}; i++)); do
oscap-podman ${IMAGE_NAME} xccdf eval --profile ${PROFILE[$i]} \
--report ./scan_results/oscap/${NAME}-${REPORT_NAME[$i]}-scap-report.html /usr/share/xml/scap/ssg/content/${XCCDF}
done

#cleanup
dnf remove openscap openscap-utils scap-security-guide -y
