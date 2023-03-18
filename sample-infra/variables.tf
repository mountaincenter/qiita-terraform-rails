variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "database_name" {
  default = "sample_app_production"
}
variable "database_username" {
  default = "root"
}
variable "database_password" {}
variable "domain_name" {}
# 作成するリソースのプレフィックス
variable "r_prefix" {
  default = "sample"
}

variable "fqdn_name" {
  default = "api.ymnk.fun"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnets" {
  type = map(any)
  default = {
    public_subnets = {
      public-1a = {
        name = "public-1a",
        cidr = "10.0.1.0/24",
        az   = "ap-northeast-1a"
      },
      public-1c = {
        name = "public-1c",
        cidr = "10.0.2.0/24",
        az   = "ap-northeast-1c"
      }
    },
    private_subnets = {
      private-1a = {
        name = "parivate-1a",
        cidr = "10.0.3.0/24",
        az   = "ap-northeast-1a"
      },
      private-1c = {
        name = "private-1c",
        cidr = "10.0.4.0/24",
        az   = "ap-northeast-1c"
      }
    }
  }
}

locals {
  secrets = {
    db_password      = "AQICAHgKkVNXG3RR2mLJJ7FKD5eNbcgtTVMV7cyF66zWXzUjagHw/X/tqat0tiVqKUFNbGkhAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMqFMQ5LfGjlcWQcpKAgEQgCOcDKqHb3IwkUp7l32v4ytpCbiuyabQIgJKobyemgIZTjG+NA=="
    rails_master_key = "AQICAHgKkVNXG3RR2mLJJ7FKD5eNbcgtTVMV7cyF66zWXzUjagHP1NQl+vZNIbcdnv0LfyQDAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMHR6HqwXaO+EnzqyyAgEQgDtb7xJdmbSOwJl2eLMAuRLnS0jZ/T75cVzqERz7RWe9LACZ9EKfiL/dOPuw4YIh7aVdMz0E4u6BILecmw=="
  }
}