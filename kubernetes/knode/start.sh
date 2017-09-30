#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export KMASTER="${kmaster}"

cd ~root/docker-kubernetes-node && ./fan-setup.sh

until docker info; do
    echo "Waiting for Docker to start..."
    sleep 3
done

until curl http://$KMASTER:8080/healthz; do
    echo "Waiting for kmaster to come online..."
    sleep 3;
done

AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
INSTANCE_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
AMI_ID=`curl http://169.254.169.254/latest/meta-data/ami-id`
DOCKER=`docker version --format '{{.Server.Version}}'`
export LABELS="zone=${zone},aws.az=$AZ,aws.instance-type=$INSTANCE_TYPE,aws.ami-id=$AMI_ID,docker=$DOCKER"
echo "LABELS=$LABELS"

cd ~root/docker-kubernetes-node
./run $KMASTER
docker ps