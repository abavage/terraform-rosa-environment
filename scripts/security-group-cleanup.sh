#!/bin/bash

export SG=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*vpce-private-router" | jq -r '.SecurityGroups[].GroupId')

if [ -z $SG ]; then
  echo "SG not found"
  exit 0
else
  aws ec2 delete-security-group --group-id $SG
fi
