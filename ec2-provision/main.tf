
variable "public_key" {
    type = string
    default = ""
    sensitive = true
}
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = [ "amazon" ]
    filter {
      name = "name"
      values = [ "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*" ]
    }

    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
}

data "aws_vpc" "default" {
    default = true
}
resource "aws_key_pair" "vm_key" {
    key_name = "vm-key"
    public_key = var.public_key
}

resource "aws_security_group" "vm_security_group" {
    name = "vm-sg"
    description = "vm security group"
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "name" {
    count = length(var.sg_ingress_rules)

    type = "ingress"
    security_group_id = aws_security_group.vm_security_group.id
    from_port = var.sg_ingress_rules[count.index].from_port
    to_port = var.sg_ingress_rules[count.index].to_port
    protocol = var.sg_ingress_rules[count.index].protocol
    cidr_blocks = [var.sg_ingress_rules[count.index].cidr_blocks]
    description =  var.sg_ingress_rules[count.index].description
}

resource "aws_instance" "vm_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name = aws_key_pair.vm_key.key_name
    vpc_security_group_ids = [ aws_security_group.vm_security_group.id ]
    associate_public_ip_address = true
    user_data = <<EOF
#!/bin/bash

sed -i "s/^#\?Port 22$/Port 5522/g" /etc/ssh/sshd_config
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