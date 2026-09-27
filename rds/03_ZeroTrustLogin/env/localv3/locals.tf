locals {
  db_subnets_ids = [
    for subnet in module.vpc.private_subnets_ids : 
        subnet.id if lookup(subnet, "purpose", "None") == "db_subnet_group"
    ]

  ec2_subnets_ids = [
    for subnet in module.vpc.private_subnets_ids : 
        subnet.id if lookup(subnet, "purpose", "None") == "ec2_instances"
    ]
}