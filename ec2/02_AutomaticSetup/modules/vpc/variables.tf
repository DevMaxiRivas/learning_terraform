variable "cidr_block" {
  type        = string
  description = "CIDR default for VPC"
}

variable "vpc_tags" {
  type = map(string)
  description = "Tags for VPC"
}


variable "availability_zone" {
  type = string
  description = "Availability Zones for Vpc"
}

variable "public_subnet_cidr" {
    type = string
    description = "Public Subnet List for VPC"
}

variable "private_subnet_cidr" {
  type = string
  description = "Private Subnets List for VPC"
}

