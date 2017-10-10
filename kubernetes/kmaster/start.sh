#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export EFS_DNS_NAME="${efs_dns_name}"
export VPC_ID="${vpc_id}"
export ALT_NAMES="${alt_names}"

mkdir -p /mnt/data

if [ $EFS_DNS_NAME ]; then
    until nslookup $EFS_DNS_NAME; do
        echo "Waiting for EFS $EFS_DNS_NAME..."
        sleep 3
    done

    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_DNS_NAME:/ /mnt/data
    mount
fi

mkdir -p /mnt/data/kmaster/etcd-data
cd ~root/docker-kubernetes-master
./run
docker ps