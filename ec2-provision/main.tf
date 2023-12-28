data "aws_kms_secrets" "secret_vars" {
    secret {
        name = "secret-vars"
        payload = file("${path.module}/secrets_vars.yml.encrypted")
    }
}

locals {
  secret_vars = yamldecode(data.aws_kms_secrets.secret_vars["secret-vars"])
}
data "aws_vpc" "default" {
    default = true
}
resource "aws_key_pair" "vm_key" {
    key_name = "vm-key"
    public_key = TF_VAR_PUBLIC_KEY
}

resource "aws_security_group" "vm_security_group" {
    name = "vm-sg"
    description = "vm security group"
    vpc_id = data.aws_vpc.default
}

resource "aws_security_group_rule" "name" {
    count = length(var.sg_ingress_rules)

    type = "ingress"
    security_group_id = aws_security_group.vm_security_group.id
    from_port = var.sg_ingress_rules[count.index].from_port
    to_port = var.sg_ingress_rules[count.index].to_port
    protocol = var.sg_ingress_rules[count.index].protocol
    cidr_blocks = var.sg_ingress_rules[count.index].cidr_block
    description =  var.sg_ingress_rules[count.index].description
}

resource "aws_instance" "vm_server" {
    ami = local.secret_vars.ami_id
    instance_type = "t2.micro"
    key_name = aws_key_pair.vm_key
    vpc_security_group_ids = [ aws_security_group.vm_security_group.id ]
    associate_public_ip_address = true
    user_data = <<EOF
#!/bin/bash

sed "s/^#\?Port 22$/Port 5522/g" /etc/ssh/sshd_config
if [[ $? -ne 0 ]]; then
    echo "Warning: change port failed!"
    exit 1
fi

systemctl restart sshd
exit 0
EOF

    tags = {
        App = "Wordpress"
    }
    
}