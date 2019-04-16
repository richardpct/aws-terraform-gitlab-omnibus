# Purpose
This tutorial will show you how to build a Gitlab service in AWS deployed by
Terraform.

Here are the components you will build:

* Creating a VPC with 2 publics subnets (each in different availability zone)
and a private subnet
* Creating a bastion server with autoscaling group associated to the two publics
subnets which is the only server that can be reachable from the Internet through
SSH, and it is the only that is allowed to connect to the database and the
webserver through SSH
* Creating a webserver with autoscaling group associated to the two publics
subnet
* Creating a database server in the private subnet, only the bastion is allowed
to connect to the database server
* Creating a NAT gateway associated to an Elastic IP (EIP) so that the database
can reach Internet which is in the private subnet
* Adding an IAM role that allows an EC2 instance to attach an EIP

# Requirement
* You must have an AWS account, if you don't have yet, you can subscribe to the
free tier
* You must install Terraform

# Usage
## Exporting the required variables in your terminal:
    $ export TF_VAR_region="eu-west-3"
    $ export TF_VAR_bucket="my-terraform-state"
    $ export TF_VAR_dev_base_key="terraform/dev/base/terraform.tfstate"
    $ export TF_VAR_dev_bastion_key="terraform/dev/bastion/terraform.tfstate"
    $ export TF_VAR_dev_database_key="terraform/dev/database/terraform.tfstate"
    $ export TF_VAR_dev_webserver_key="terraform/dev/webserver/terraform.tfstate"
    $ export TF_VAR_ssh_public_key="ssh-rsa ..."
    $ export TF_VAR_dev_database_pass="your_db_passwordd"
    $ export TF_VAR_my_ip_address=xx.xx.xx.xx/32

## Creating the S3 backend for storing the terraform state if it is not already done
If you have not created a S3 backend, follow my first tutorial
[https://github.com/richardpct/aws-terraform-tuto01](https://github.com/richardpct/aws-terraform-tuto01)

## Initializing Terraform
    $ cd environment/dev
    $ make init

## Creating the Gitlab service
    $ cd environment/dev
    $ make apply

## Using Gitlab
Open your web browser by using the public IP address of your webserver, then
change your password root

## Connecting to the database and the webserver through SSH
    $ ssh -J ubuntu@public_ip_bastion ubuntu@private_ip_database
    $ ssh -J ubuntu@public_ip_bastion ubuntu@private_ip_webserver

## Cleaning up
    $ cd environment/dev
    $ make destroy
