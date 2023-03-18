resource "aws_ssm_parameter" "rails_master_key" {
  name        = "/${var.r_prefix}/rails_master_key"
  description = "Rails Master Key"
  type        = "SecureString"
  value       = data.aws_kms_secrets.secrets.plaintext["rails_master_key"]
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/${var.r_prefix}/database_password"
  description = "DATABASE_PASSWORD"
  type        = "SecureString"
  value       = data.aws_kms_secrets.secrets.plaintext["db_password"]
}