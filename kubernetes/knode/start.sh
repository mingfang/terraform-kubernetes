#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export KMASTER="${kmaster}"
export ZONE="${zone}"

#setup fan networking

cd ~root/docker-kubernetes-node
./fan-setup.sh

#wait for dependencies

until docker info; do echo "Waiting for docker..."; sleep 10; done
until curl -s -k https://$KMASTER:6443/healthz; do echo "Waiting for kmaster..."; sleep 10; done

#setup labels

export REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -c -r .region)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
DOCKER=$(docker version --format '{{.Server.Version}}')
SHA=$(git rev-parse --short HEAD)
export LABELS="zone=$ZONE,sha=$SHA,ami=$AMI_ID,docker=$DOCKER,instance-id=$INSTANCE_ID"
export LABELS="$LABELS,failure-domain.beta.kubernetes.io/region=$REGION,failure-domain.beta.kubernetes.io/zone=$AZ,beta.kubernetes.io/instance-type=$INSTANCE_TYPE"
echo "LABELS=$LABELS"

#setup vault

export VAULT_ADDR=http://$KMASTER:8200
AUTH_RESULT=$(curl -s -X POST $VAULT_ADDR/v1/auth/aws/login -d '{"role": "knode", "pkcs7":"'"$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d \\n)"'"}')
VAULT_TOKEN=$(echo $AUTH_RESULT | jq -r .auth.client_token)

KUBELET_TOKEN_CURL=$(curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Wrap-Ttl: 1m0s" -d '{"ttl":"1m0s","explicit_max_ttl":"0s","period":"0s","no_parent":true,"display_name":"","num_uses":0,"renewable":true,"type":"service"}' $VAULT_ADDR/v1/auth/token/create/kubelet)
export KUBELET_TOKEN=$(echo $KUBELET_TOKEN_CURL | jq -r .wrap_info.token)

PROXY_TOKEN_CURL=$(curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Wrap-Ttl: 1m0s" -d '{"ttl":"1m0s","explicit_max_ttl":"0s","period":"0s","no_parent":true,"display_name":"","num_uses":0,"renewable":true,"type":"service"}' $VAULT_ADDR/v1/auth/token/create/proxy)
export PROXY_TOKEN=$(echo $PROXY_TOKEN_CURL | jq -r .wrap_info.token)

# auto attach volumes
#/attach_volume.py --tag Zone --value "$ZONE" --attach_as /dev/xvdf || true

#start
cd ~root/docker-kubernetes-node
./run $KMASTER
docker ps