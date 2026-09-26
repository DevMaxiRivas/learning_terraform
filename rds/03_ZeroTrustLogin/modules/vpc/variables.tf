variable "cidr_block" {
  type        = string
  description = "CIDR default for VPC"
}

variable "vpc_tags" {
  type        = map(string)
  description = "Tags for VPC"
}

variable "private_subnet_cidr_objects" {
  description = "Private Subnets Objects"
  type = list(
    object({
      id                      = string
      cidr                    = string
      availability_zone       = string
      purpose                 = string
      map_public_ip_on_launch = bool
    })
  )
}

variable "public_subnet_cidr_objects" {
  description = "Private Subnets Objects"
  type = list(
    object({
      id                      = string
      cidr                    = string
      availability_zone       = string
      purpose                 = string
      map_public_ip_on_launch = bool
    })
  )
}
