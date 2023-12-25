terraform {
  cloud {
    organization = "findnull"

    workspaces {
      name = "Nginx-Wordpress-AWS-Provision"
    }
  }
  required_version = "~> 1.6.0"
}