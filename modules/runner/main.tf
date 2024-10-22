provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket = "${var.base_remote_state_bucket}"
    key    = "${var.base_remote_state_key}"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "webserver" {
  backend = "s3"

  config {
    bucket = "${var.webserver_remote_state_bucket}"
    key    = "${var.webserver_remote_state_key}"
    region = "${var.region}"
  }
}

data "aws_availability_zones" "available" {}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars = {
    environment           = "${var.env}"
    alb_internal_dns_name = "${data.terraform_remote_state.base.alb_web_internal_dns_name}"
    gitlab_token          = "${var.gitlab_token}"
  }
}

resource "aws_launch_configuration" "runner" {
  name                        = "runner-${var.env}"
  image_id                    = "${var.image_id}"
  user_data                   = "${data.template_file.user_data.rendered}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${data.terraform_remote_state.base.ssh_key}"
  security_groups             = ["${data.terraform_remote_state.base.sg_runner_id}"]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "runner" {
  name                 = "asg_runner-${var.env}"
  launch_configuration = "${aws_launch_configuration.runner.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  vpc_zone_identifier  = ["${data.terraform_remote_state.base.subnet_public_a_id}", "${data.terraform_remote_state.base.subnet_public_b_id}"]
  min_size             = 1
  max_size             = 1

  tag {
    key                 = "Name"
    value               = "runner-${var.env}"
    propagate_at_launch = true
  }
}
