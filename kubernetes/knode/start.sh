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

export KMASTER="${kmaster}"
export TAINTS="${taints}"

#wait for dependencies

until curl -s -k https://$KMASTER:6443/healthz; do echo "Waiting for kmaster..."; sleep 10; done

#setup labels
cd ~root/docker-kubernetes-node

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
export LABELS="$LABELS,role=${role}"
echo "LABELS=$LABELS"

export PROVIDERID="aws:///$AZ/$INSTANCE_ID"

#setup vault

export VAULT_ADDR=http://$KMASTER:8200
AUTH_RESULT=$(curl -s -X POST $VAULT_ADDR/v1/auth/aws/login -d '{"role": "knode", "pkcs7":"'"$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d \\n)"'"}')
VAULT_TOKEN=$(echo $AUTH_RESULT | jq -r .auth.client_token)

KUBELET_TOKEN_CURL=$(curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Wrap-Ttl: 1m0s" -d '{"ttl":"1m0s","explicit_max_ttl":"0s","period":"0s","no_parent":true,"display_name":"","num_uses":0,"renewable":true,"type":"service"}' $VAULT_ADDR/v1/auth/token/create/kubelet)
export KUBELET_TOKEN=$(echo $KUBELET_TOKEN_CURL | jq -r .wrap_info.token)

PROXY_TOKEN_CURL=$(curl -s -X POST -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Wrap-Ttl: 1m0s" -d '{"ttl":"1m0s","explicit_max_ttl":"0s","period":"0s","no_parent":true,"display_name":"","num_uses":0,"renewable":true,"type":"service"}' $VAULT_ADDR/v1/auth/token/create/proxy)
export PROXY_TOKEN=$(echo $PROXY_TOKEN_CURL | jq -r .wrap_info.token)

#start

cd ~root/docker-kubernetes-node
./run $KMASTER
docker ps