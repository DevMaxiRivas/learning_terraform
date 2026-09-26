output "vpc_id" {
  value = aws_vpc.main.id
  depends_on = [aws_internet_gateway.igw]
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets_ids" {
  value = {
    for key, subnet in aws_subnet.public_subnets : key => {
      id = subnet.id
      purpose = subnet.tags["Purpose"]
    }
  }
}


output "private_subnets_ids" {
  value = {
    for key, subnet in aws_subnet.private_subnets : key => {
      id = subnet.id
      purpose = subnet.tags["Purpose"]
    }
  }
}

output "nat_public_ip" {
  value = aws_nat_gateway.nat.public_ip
}