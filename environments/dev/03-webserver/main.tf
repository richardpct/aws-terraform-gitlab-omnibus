terraform {
  backend "s3" {}
}

module "webserver" {
  source = "../../../modules/webserver"

  region                       = "eu-west-3"
  env                          = "dev"
  base_remote_state_bucket     = "${var.bucket}"
  base_remote_state_key        = "${var.dev_base_key}"
  database_remote_state_bucket = "${var.bucket}"
  database_remote_state_key    = "${var.dev_database_key}"
  instance_type                = "t2.medium"
  image_id                     = "ami-03bca18cb3dc173c9"  //ubuntu 18.04 LTS
  database_pass                = "${var.dev_database_pass}"
  gitlab_pass                  = "${var.dev_gitlab_pass}"
}
