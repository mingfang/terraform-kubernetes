#!/bin/bash -x

cd ~root/docker-kubernetes-node && ./docker-setup.sh

until docker info; do echo Waiting for Docker to start...; sleep 3; done;
until curl http://kmaster.local:8080/healthz; do echo Waiting for kmaster to come online...; sleep 10; done;

AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
INSTANCE_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
AMI_ID=`curl http://169.254.169.254/latest/meta-data/ami-id`
export LABELS="zone=${zone},aws.az=$AZ,aws.instance-type=$INSTANCE_TYPE,aws.ami-id=$AMI_ID"
echo "LABELS=$LABELS"

cd ~root/docker-kubernetes-node && ./run kmaster.local

