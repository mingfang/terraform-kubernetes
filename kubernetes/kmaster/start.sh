#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

mkdir -p /mnt/data
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_dns_name}:/ /mnt/data
mount
mkdir -p /mnt/data/kmaster/etcd-data
cd ~root/docker-kubernetes-master
docker run --name kmaster -v /mnt/data/kmaster/etcd-data:/var/lib/etcd-data --net=host -p 4001:4001 -p 8080:8080 -v /var/log:/var/log -d kubernetes-master
docker ps

date '+%Y-%m-%d %H:%M:%S'
echo END
