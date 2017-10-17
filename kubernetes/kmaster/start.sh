#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export EFS_DNS_NAME="${efs_dns_name}"
export VPC_ID="${vpc_id}"
export ALT_NAMES="${alt_names}"
export BUCKET="${bucket}"
export IAM_ROLE="${iam_role}"
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

#start
cd ~root/docker-kubernetes-master
./run

#upload kubernetes pki to s3
cd ~root/docker-kubernetes-master/pki-data
until curl localhost:8080/healthz; do echo "Waiting for kubernetes..."; sleep 10; done

KEYS=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/$IAM_ROLE)
ACCESS_KEY=$(echo $KEYS|jq -r .AccessKeyId)
SECRET_KEY=$(echo $KEYS|jq -r .SecretAccessKey)
TOKEN=$(echo $KEYS|jq -r .Token)

dateFormatted=`date -R`
fileName="cluster-admin-kubeconfig.yml"
relativePath="/$BUCKET/$fileName"
contentType="application/yml"
token="x-amz-security-token:$TOKEN"
encryption="x-amz-server-side-encryption:AES256"
stringToSign="PUT\n\n$contentType\n$dateFormatted\n$token\n$encryption\n$relativePath"
signature=`echo -en $stringToSign | openssl sha1 -hmac $SECRET_KEY -binary | base64`
curl -X PUT -T "$fileName" \
-H "Host: $BUCKET.s3.amazonaws.com" \
-H "Date: $dateFormatted" \
-H "Content-Type: $contentType" \
-H "Authorization: AWS $ACCESS_KEY:$signature" \
-H $token \
-H $encryption \
http://$BUCKET.s3.amazonaws.com/$fileName