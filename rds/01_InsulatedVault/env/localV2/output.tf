output "public_subnets" {
  value = module.vpc.public_subnets_ids
}

output "private_subnets" {
  value = module.vpc.private_subnets_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "rds_instance_port" {
  value = aws_db_instance.default.port
}

output "rds_instance_username" {
  value = aws_db_instance.default.username
}

output "rds_instance_password" {
  value = random_password.secret.result

  sensitive = true
}

output "rds_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.id
}