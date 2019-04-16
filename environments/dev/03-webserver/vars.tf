variable "bucket" {
  description = "bucket where terraform states are stored"
}

variable "dev_base_key" {
  description = "terraform state for dev environment"
}

variable "dev_database_key" {
  description = "terraform state for dev environment"
}

variable "dev_database_pass" {
  description = "database password"
}

variable "dev_gitlab_pass" {
  description = "gitlab password"
}
