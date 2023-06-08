## Test with Localstack
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
pip install terraform-local \
[More](https://docs.localstack.cloud/integrations/terraform/)

export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

## step-0
setup Terraform backend

## step-1
setup AWS DNS and SSL certificates

## step-2
setup AWS VPC and run Kubernetes

## step-3
run system critical Kubernetes services

## step-4
run application level Kubernetes services
