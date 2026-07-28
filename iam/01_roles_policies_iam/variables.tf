variable aws_region {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}


variable "s3_bucket_name" {
  type = string
  default = "test_bucket"
  description = "AWS Bucket Name"
}