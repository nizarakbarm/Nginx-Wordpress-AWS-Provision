data "aws_kms_secrets" "secret_vars" {
    secret {
        name = "secret-vars"
        payload = file("${path.module}/secrets_vars.yml.encrypted")
    }
}

locals {
  secret_vars = yamldecode(data.aws_kms_secrets.secret_vars["secret-vars"])
}

resource "aws_key_pair" "vm_key" {
    key_name = "vm-key"
    public_key = TF_VAR_PUBLIC_KEY
}

resource "aws_instance" "vm_server" {
    ami = local.secret_vars.ami_id
    instance_type = "t2.micro"
    key_name = aws_key_pair.vm_key
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