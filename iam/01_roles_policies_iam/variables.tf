variable aws_region {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "user_name" {
  type = string
  default = "read_only_s3_user"
  description = "AWS New User"
}

variable "s3_bucket_name" {
  type = string
  default = "test_bucket"
  description = "AWS Bucket Name"
}

variable "policy_name" {
  type = string
  default = "read-only_test_bucket"
  description = "AWS Policy Name"
}

variable "role_name" {
  type = string
  default = "read-only_test_bucket_role"
  description = "AWS Role Name"
}

variable "profile_name" {
  type = string
  default = "read-only_test_bucket_role_profile"
  description = "AWS Profile Name"
}