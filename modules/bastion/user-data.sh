#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
apt-get -y install awscli
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
aws --region eu-west-3 ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${eip_bastion_id}
