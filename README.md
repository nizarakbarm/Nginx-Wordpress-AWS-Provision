# Nginx-Wordpress-AWS-Provider
Terraform code and bash script that can be used for Nginx-Wordpres-PHP provision inside ec2

The content of this repository is:
- ec2-provision
- script

ec2-provision is used for ec2 provision in AWS by using terraform.

script is used for Nginx-Wordpress-PHP-MySQL provision inside ec2 vm. Nginx-Wordpress-PHP-Mysql provision inside script is following security best practice, which is:

- CIS Benchmark for Nginx https://www.cisecurity.org/benchmark/nginx

- Drop database test, delete privilege of database test, delete anonymous user, and change root password to stronger password.

- Using wp-cli/secure-command to add security configuration for wordpress, which is:

    - disable file editor
    
    - Block access to XMLRPC

    - Block author scanning

    - Block PHP Access to plugins directory

    - Block PHP Access in uploads directory

    - Block PHP Access in wp-includes diectory

    - Block PHP Access in themes directory

    - Block Directory Browsing

- Using Nginx 1.25.3 Release which has Bug Fix for HTTP/2 Rapid Reset DDOS Attack Vulnerability

Other than security best practice, the configuration is also optimized for perfomance, which is:

- For MySQL:

    - innodb_flush_method set to O_DIRECT to avoid double write buffering

    - max_write_lock_count is decreased to 16 to reduce bottleneck of read operation caused by its excessively high value

    - join_buffer_size set to 1M to reduce join operation not buffered

    - skip-name-resolve is set to ON to prevent MySQL from resolving hostname by using DNS

    - thread_cache_size set to 55 so 55 connection can be satisfied by cache from thread

    - max_connections reduced to 50 to reduce memory consumption. You can change this if you need more connection.

- For Nginx:

    - Using static cache by using header Cached-Control with max-age and must-revalidate for static file

    - Using dynamic cache by fastcgi-cache, this can be combined with Nginx Helper plugin in Wordpress too

    - Using gzip compression

    - Using quic or http3 to reduce initial connection time because TCP 3-Way Handshake


# Table of Contents
- [Requirement](#Requirement)
- [Installation](#Installation)
- [Usage](#Usage)

# Requirement
Technology stack needed for this:
- Terraform >= 1.6.0
- Bash == 5.x


# Installation

- Download terraform script from ec2-provision
```
curl -o Nginx-Wordpress-AWS-Provision-v0.1.tar.gz https://github.com/nizarakbarm/Nginx-Wordpress-AWS-Provision/archive/refs/tags/v0.1.tar.gz
tar xvfz Nginx-Wordpress-AWS-Provision-v0.1.tar.gz
cd Nginx-Wordpress-AWS-Provision-v0.1/ec2-provision
```

- Download provision script from script by using this command:

    - First Login to your VM by using SSH

    - Then run this command:

        ```
        sudo su # if you are not in root
        cd /root
        curl -o Nginx-Wordpress-AWS-Provision-v0.1.tar.gz https://github.com/nizarakbarm/Nginx-Wordpress-AWS-Provision/archive/refs/tags/v0.1.tar.gz
        tar xvfz Nginx-Wordpress-AWS-Provision-v0.1.tar.gz
        sudo mv Nginx-Wordpress-AWS-Provision-v0.1/script /root
        sudo chown root:root script -R
        sudo find /root/script -type f -exec chmod 755 {} +
        ```

# Usage

## Provision EC2 with Terraform

- Go into ec2-provision directory by using `cd ec2-provision`

- Run `terraform init`

- Run terraform plan like this:

    ```
    terraform plan -auto-approve \
    -var public_key=[PUBLIC_KEY] \ 
    -var domain_name=[DOMAIN_NAME_FOR_CF] \ 
    -var sub_domain_name=[SUB_DOMAIN_NAME_FOR_CF] \
    -var cloudflare_token=[CLOUDFLARE_TOKEN] \
    ```
   
   Change [PUBLIC_KEY] with your SSH_PUBLIC_KEY. [DOMAIN_NAME_FOR_CF] with your root domain part in Cloudflare, [SUB_DOMAIN_NAME_FOR_CF] with your subdomain part that will be added to Cloudflare, and [CLOUDFLARE_TOKEN] with your cloudflare token.

- Run terraform apply

    ```
    terraform plan -auto-approve \
    -var public_key=[PUBLIC_KEY] \ 
    -var domain_name=[DOMAIN_NAME_FOR_CF] \ 
    -var sub_domain_name=[SUB_DOMAIN_NAME_FOR_CF] \
    -var cloudflare_token=[CLOUDFLARE_TOKEN] \
    ```

- Get your ec2 Public IP with `terraform output public_ip_ec2`

## Provision Nginx-Wordpress-PHP with Bash Script from Directory script

Run this command:

```
/root/script/main.sh \
-d [DOMAIN_NAME] -r [ROOT_PASSWORD] \
-ud [USERNAME_DB] -db "$DB_NAME" \
-t [TITLE] -u [USERNAME] \
-p [PASSWORD] -e [EMAIL]
--github-token [GITHUB_TOKEN] > /root/log_installation 2>&1
```
  with some argument:
  - [DOMAIN_NAME] : Domain Name for Wordpress
  - [ROOT_PASSWORD] : Root Password of MySQL
  - [USERNAME_DB] : Username DB for Wordpress
  - [DB_NAME] : DB Name for Wordpress
  - [TITLE]: Title for Wordpress
  - [USERNAME]: Username admin for Wordpress
  - [PASSWORD]: Admin password for Wordpress
  - [EMAIL]: Email password for Wordpress
  - [GITHUB_TOKEN]: GITHUB_TOKEN needed for wp package install

If you want to provision ec2 and Nginx-Wordpress-PHP by using github action you can check my github action inside .github/workflows/ci-provision.yml.





