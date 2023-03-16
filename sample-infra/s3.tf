resource "aws_s3_bucket" "sample_alb_logs" {
  bucket = "${var.r_prefix}-alb-logs-yam" # S3バケット名はグローバルで一意である必要があるので、適当に日付などを付けて差別化を図ると良いかも。
}