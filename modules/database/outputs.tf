output "database_private_ip" {
  value = "${aws_instance.database.private_ip}"
}
