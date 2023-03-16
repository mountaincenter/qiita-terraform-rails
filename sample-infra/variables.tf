variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}
variable "domain_name" {}
# 作成するリソースのプレフィックス
variable "r_prefix" {
  default = "sample"
}

variable "fqdn_name" {
  default = "api.ymnk.fun"
}