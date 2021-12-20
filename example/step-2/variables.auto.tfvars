ami_name        = "kubernetes-1.21.0-1"
cidr            = "10.248.0.0/16"
public_subnets  = ["10.248.10.0/24", "10.248.11.0/24"]
private_subnets = ["10.248.20.0/24", "10.248.21.0/24"]
public_key_path = "key.pub"

transit_gateway_destination_cidr_blocks = []

efs_provisioned_throughput_in_mibps = null
efs_transition_to_ia                = "AFTER_7_DAYS"

bastion_enable        = false
bastion_instance_type = "t3a.nano"
kmaster_instance_type = "t3a.medium"

com_size          = null
com_instance_type = "t3a.micro"
com_volume_size   = 32

green_size          = null
green_instance_type = "t3a.medium"
green_volume_size   = 32

spot_size          = null
spot_instance_type = "m5a.large"
