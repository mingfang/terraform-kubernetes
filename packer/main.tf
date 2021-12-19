
resource "null_resource" "packer" {
  triggers = {
    ami_name = var.ami_name
  }

  provisioner "local-exec" {
    environment = {
      AWS_SHARED_CREDENTIALS_FILE = var.AWS_SHARED_CREDENTIALS_FILE
    }
    command = <<-EOF
      packer build \
        -var "region=${var.region}" \
        -var "vpc_id=${var.vpc_id}" \
        -var "subnet_id=${var.subnet_id}" \
        -var "ami_name=${var.ami_name}" \
        ${path.module}/kubernetes-ami.json
      EOF
  }
}
