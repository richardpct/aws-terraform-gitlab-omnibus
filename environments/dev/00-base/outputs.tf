output "vpc_id" {
  value = "${module.base.vpc_id}"
}

output "subnet_public_a_id" {
  value = "${module.base.subnet_public_a_id}"
}

output "subnet_public_b_id" {
  value = "${module.base.subnet_public_b_id}"
}

output "subnet_private_id" {
  value = "${module.base.subnet_private_id}"
}

output "sg_bastion_id" {
  value = "${module.base.sg_bastion_id}"
}

output "sg_database_id" {
  value = "${module.base.sg_database_id}"
}

output "sg_webserver_id" {
  value = "${module.base.sg_webserver_id}"
}

output "sg_runner_id" {
  value = "${module.base.sg_runner_id}"
}

output "aws_eip_bastion_id" {
  value = "${module.base.aws_eip_bastion_id}"
}

output "alb_web_dns_name" {
  value = "${module.base.alb_web_dns_name}"
}

output "alb_web_internal_dns_name" {
  value = "${module.base.alb_web_internal_dns_name}"
}

output "alb_target_group_web_arn" {
  value = "${module.base.alb_target_group_web_arn}"
}

output "alb_target_group_web_internal_arn" {
  value = "${module.base.alb_target_group_web_internal_arn}"
}

output "iam_instance_profile_name" {
  value = "${module.base.iam_instance_profile_name}"
}

output "ssh_key" {
  value = "${module.base.ssh_key}"
}
