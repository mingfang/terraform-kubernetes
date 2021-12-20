#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# hack to fix DNS problems, https://github.com/coredns/coredns/blob/master/plugin/loop/README.md
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Docker Conf

mkdir -p /etc/systemd/system/docker.service.d
cat << EOF > /etc/systemd/system/docker.service.d/docker.conf
${docker_conf}
EOF
cat /etc/systemd/system/docker.service.d/docker.conf
echo "Restarting Docker..."
systemctl daemon-reload
systemctl restart docker --ignore-dependencies
systemctl status docker
until systemctl -q is-active docker; do echo "Waiting for Docker to start..."; sleep 3; done

export EFS_DNS_NAME="${efs_dns_name}"
export VPC_ID="${vpc_id}"
export ALT_NAMES="${alt_names}"
export BUCKET="${bucket}"
export AWS_PROFILE="${iam_role}"
export KUBERNETES_MASTER="${kubernetes_master}"

#mount EFS

mkdir -p /mnt/data
if [ $EFS_DNS_NAME ]; then
    until nslookup $EFS_DNS_NAME; do echo "Waiting for EFS $EFS_DNS_NAME..."; sleep 5; done
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_DNS_NAME:/ /mnt/data
fi

#persist cluster state in EFS mount

mkdir -p /mnt/data/kmaster/{etcd-data,vault-data,pki-data}
rm -r ~root/docker-kubernetes-master/{etcd-data,vault-data,pki-data}
ln -s /mnt/data/kmaster/{etcd-data,vault-data,pki-data} ~root/docker-kubernetes-master

#setup labels
cd ~root/docker-kubernetes-master

export REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -c -r .region)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
INSTANCE_LIFE_CYCLE=$(curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
DOCKER=$(docker version --format '{{.Server.Version}}')
SHA=$(git rev-parse --short HEAD)
export LABELS="sha=$SHA,ami=$AMI_ID,docker=$DOCKER,instance-id=$INSTANCE_ID"
export LABELS="$LABELS,topology.kubernetes.io/region=$REGION"
export LABELS="$LABELS,topology.kubernetes.io/zone=$AZ"
export LABELS="$LABELS,node.kubernetes.io/instance-type=$INSTANCE_TYPE"
export LABELS="$LABELS,node.kubernetes.io/lifecycle=$INSTANCE_LIFE_CYCLE"
echo "LABELS=$LABELS"

export PROVIDERID="aws:///$AZ/$INSTANCE_ID"

#start

cd ~root/docker-kubernetes-master
./run

#upload cluster-admin kubeconfig file to s3

cd ~root/docker-kubernetes-master/vault-data
until curl -s -k https://localhost:6443/healthz; do echo "Waiting for kubernetes..."; sleep 10; done

KEYS=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/$AWS_PROFILE)
ACCESS_KEY=$(echo $KEYS|jq -r .AccessKeyId)
SECRET_KEY=$(echo $KEYS|jq -r .SecretAccessKey)
TOKEN=$(echo $KEYS|jq -r .Token)

dateFormatted=`date -R`
fileName="cluster-admin-kubeconfig.yml"
relativePath="/$BUCKET/$fileName"
contentType="text/yaml"
token="x-amz-security-token:$TOKEN"
encryption="x-amz-server-side-encryption:AES256"
stringToSign="PUT\n\n$contentType\n$dateFormatted\n$token\n$encryption\n$relativePath"
signature=`echo -en $stringToSign | openssl sha1 -hmac $SECRET_KEY -binary | base64`
curl -s -X PUT --location-trusted -T "$fileName" \
-H "Host: $BUCKET.s3.amazonaws.com" \
-H "Date: $dateFormatted" \
-H "Content-Type: $contentType" \
-H "Authorization: AWS $ACCESS_KEY:$signature" \
-H $token \
-H $encryption \
http://$BUCKET.s3.amazonaws.com/$fileName