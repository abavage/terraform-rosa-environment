#!/bin/bash
mkdir /home/ec2-user/bin

curl -s -O https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
tar -zxpf openshift-client-linux.tar.gz -C /home/ec2-user/bin/

curl -s -O https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
tar -zxpf rosa-linux.tar.gz -C /home/ec2-user/bin

#curl -O https://github.com/openshift-online/ocm-cli/releases/download/v1.0.2/ocm-linux-amd64
#tar -zxpf ocm-linux-amd64 -C /home/ec2-user/bin

mkdir /home/ec2-user/.aws
cat <<EOF>> /home/ec2-user/.aws/config
[default]
region=ap-southeast-2
output=json
EOF

cat <<EOF>> /home/ec2-user/.aws/credentials
[default]
aws_access_key_id = 
aws_secret_access_key = 
EOF

curl -s -O https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz
tar -zxpf helm-v3.16.3-linux-amd64.tar.gz -C /home/ec2-user/bin
mv /home/ec2-user/bin/linux-amd64/helm /home/ec2-user/bin/

chown -R ec2-user:ec2-user /home/ec2-user/bin
chown -R ec2-user:ec2-user /home/ec2-user/.aws

dnf -y install git
