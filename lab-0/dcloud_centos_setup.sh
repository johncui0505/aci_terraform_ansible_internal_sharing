#!/bin/bash

VERSION_TERRAFORM=1.0.0
VERSION_ANSIBLE=2.9.13 
VERSION_ANSIBLE_ACI=2.0.0 

echo "================= Installing Ansible -->" \
    && yes | pip uninstall ansible
    && pip install ansible==${VERSION_ANSIBLE} \
    && ansible --version

echo "================= Installing Ansible Cisco ACI Collection: ${VERSION_ANSIBLE_ACI} -->" \
    && ansible-galaxy collection install cisco.aci:==${VERSION_ANSIBLE_ACI} 

echo "================= Installing Terraform ${VERSION_TERRAFORM} -->"  \
    && curl -sSL -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${VERSION_TERRAFORM}/terraform_${VERSION_TERRAFORM}_linux_amd64.zip 2>&1 \
    && yes | unzip -d /usr/bin /tmp/terraform.zip \
    && chmod +x /usr/bin/terraform \
    && mkdir -p /root/.terraform.cache/plugin-cache \
    && rm -f /tmp/terraform.zip \
    && terraform -install-autocomplete

echo "================= Installing python packages -->"  \
    && pip install openpyxl pandas paramiko