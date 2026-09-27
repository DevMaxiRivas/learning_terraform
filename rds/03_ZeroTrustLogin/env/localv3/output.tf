output "public_subnets" {
  value = module.vpc.public_subnets_ids
}

output "private_subnets" {
  value = module.vpc.private_subnets_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "database_connection" {
  description = "Connection details for the database cluster"
  value = {
    host     = aws_db_instance.main_db.address
    port     = aws_db_instance.main_db.port
    username = aws_db_instance.main_db.username
    arn      = aws_db_instance.main_db.arn
    endpoint = aws_db_instance.main_db.endpoint
  }
}


output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.id
}
