variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR default for VPC"
}

variable "vpc_tags" {
  type = map(string)
  default = {
    Name = "main-vpc"
  }
  description = "Tags for VPC"
}


variable "availability_zone" {
  type        = string
  default     = "us-east-1"
  description = "Availability Zones for Vpc"
}

variable "public_subnets" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public Subnet List for VPC"
}

variable "private_subnets" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Private Subnets List for VPC"
}



variable "bucket-name" {
  type    = string
  default = "ec2-deploy-config"
}

variable "script-path" {
  type    = string
  default = "scripts/ec2-bootstrap-script.sh"
}

variable "region" {
  type    = string
  default = "us-east-1"
}