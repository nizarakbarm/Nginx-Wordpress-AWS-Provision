terraform {
  cloud {
    organization = "findnull"

    workspaces {
      name = "Nginx-Wordpress-AWS-Provision"
    }
  }
}