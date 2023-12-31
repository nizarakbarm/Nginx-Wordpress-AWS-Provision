
variable "public_key" {
    type = string
    default = ""
    sensitive = true
}
variable "domain_name" {
    type = string
    default = ""
    sensitive = true
}
variable "sub_domain_name" {
    type = string
    default = ""
    sensitive = true
}
variable "cloudflare_token" {
    type = string
    default = ""
    sensitive = true
}

provider "cloudflare" {
    api_token = var.cloudflare_token
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

resource "aws_security_group_rule" "ingress" {
    count = length(var.sg_ingress_rules)

    type = "ingress"
    security_group_id = aws_security_group.vm_security_group.id
    from_port = var.sg_ingress_rules[count.index].from_port
    to_port = var.sg_ingress_rules[count.index].to_port
    protocol = var.sg_ingress_rules[count.index].protocol
    cidr_blocks = [var.sg_ingress_rules[count.index].cidr_blocks]
    description =  var.sg_ingress_rules[count.index].description
}

resource "aws_security_group_rule" "engress" {
    count = length(var.sg_engress_rules)

    type = "egress"
    security_group_id = aws_security_group.vm_security_group.id
    from_port = var.sg_engress_rules[count.index].from_port
    to_port = var.sg_engress_rules[count.index].to_port
    protocol = var.sg_engress_rules[count.index].protocol
    cidr_blocks = [var.sg_engress_rules[count.index].cidr_blocks]
    description =  var.sg_engress_rules[count.index].description
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

#get zone id
data "cloudflare_zone" "get_zone_info" {
    name = var.domain_name
}

# #check if record exist
# data "cloudflare_record" "domain_name" {
#     hostname = "${var.sub_domain_name}.${var.domain_name}"
#     zone_id = data.cloudflare_zone.get_zone_info.zone_id
# }

resource "cloudflare_record" "domain_name" {
    name = var.sub_domain_name
    zone_id = data.cloudflare_zone.get_zone_info.zone_id
    value = aws_instance.vm_server.public_ip
    type = "A"
    allow_overwrite = true

    depends_on = [ aws_instance.vm_server ]
}

output "public_ip_ec2" {
  value = aws_instance.vm_server.public_ip
}