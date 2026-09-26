variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
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

  default = [
    {
      id = "db_subnet_group-1"
      availability_zone       = "us-east-1a"
      cidr                    = "10.0.1.0/24"
      map_public_ip_on_launch = false
      purpose                 = "db_subnet_group"
    },
    {
      id = "db_subnet_group-2"
      availability_zone       = "us-east-1a"
      cidr                    = "10.0.2.0/24"
      map_public_ip_on_launch = false
      purpose                 = "db_subnet_group"
    },
    {
      id = "ec2_instances_subnet-1"
      availability_zone       = "us-east-1a"
      cidr                    = "10.0.3.0/24"
      map_public_ip_on_launch = false
      purpose                 = "ec2_instances"
    }
  ]
}

variable "public_subnet_cidr_objects" {
  description = "Public Subnets Objects"
  type = list(
    object({
      id                      = string
      cidr                    = string
      availability_zone       = string
      purpose                 = string
      map_public_ip_on_launch = bool
    })
  )

  default = [
    {
      id = "general_subnet-1"
      availability_zone       = "us-east-1a"
      cidr                    = "10.0.1.0/24"
      map_public_ip_on_launch = true
      purpose                 = "general"
    }
  ]
}

variable "vpc_tags" {
  type = map(string)
  default = {
    "Environment" = "Local"
  }
}


variable "db_default_username" {
  default = "admin"
  type    = string
}

variable "db_port" {
  default = 5432
  type = number
}