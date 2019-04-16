variable "region" {
  description = "region"
}

variable "env" {
  description = "environment"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "subnet_public_a" {
  description = "public subnet A"
}

variable "subnet_public_b" {
  description = "public subnet B"
}

variable "subnet_private" {
  description = "private subnet"
}

variable "cidr_allowed_ssh" {
  description = "cidr block allowed to connect through SSH"
}

variable "ssh_public_key" {
  description = "ssh public key"
}
