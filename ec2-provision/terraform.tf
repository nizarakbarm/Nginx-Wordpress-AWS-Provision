provider "aws" {
    alias = "Singapore"
    region = "ap-southeast-1"
    sts_region = "ap-southeast-1"
}

terraform {
  cloud {
    organization = "findnull"

    workspaces {
      name = "Nginx-Wordpress-AWS-Provision-CLI"
    }
  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.31.0"
    }
  }
  required_version = "~> 1.6.0"
}