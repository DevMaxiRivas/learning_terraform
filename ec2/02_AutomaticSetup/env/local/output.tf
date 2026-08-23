# --- EC2 ---
output "ec2_instance_id" {
  description = "ID de la instancia para usar con aws ssm start-session"
  value       = aws_instance.instance.id
}

output "ec2_private_ip" {
  description = "IP privada de la instancia"
  value       = aws_instance.instance.private_ip
}

# --- Networking (Desde el módulo) ---
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "nat_gw_public_ip" {
  description = "IP pública del NAT Gateway (la IP de salida de la EC2)"
  value       = module.vpc.nat_public_ip
}

# --- IAM ---
output "ssm_instance_profile_name" {
  value = aws_iam_instance_profile.profile.name
}
