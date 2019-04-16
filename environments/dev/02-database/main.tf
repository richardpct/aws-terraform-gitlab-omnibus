terraform {
  backend "s3" {}
}

module "database" {
  source = "../../../modules/database"

  region                   = "eu-west-3"
  env                      = "dev"
  base_remote_state_bucket = "${var.bucket}"
  base_remote_state_key    = "${var.dev_base_key}"
  instance_type            = "t2.micro"
  image_id                 = "ami-03bca18cb3dc173c9"  //ubuntu 18.04 LTS
  database_pass            = "${var.dev_database_pass}"
}
