module "vpc" {
  source                      = "../../modules/vpc"
  cidr_block                  = var.cidr_block
  private_subnet_cidr_objects = var.private_subnet_cidr_objects
  public_subnet_cidr_objects  = var.public_subnet_cidr_objects
  vpc_tags = {
    "Environment" = "Local"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "main-db-subnet-group"
  description = "Database subnet group for RDS instances"
  subnet_ids  = local.db_subnets_ids

  tags = {
    Name        = "My DB Subnet Group"
    Environment = "Local"
  }
}

resource "aws_security_group" "sg_database" {
  name        = "allow_receive_request_from_apps"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow receive request from apps"
  }
}

// Ingress Rule for DB
# resource "aws_vpc_security_group_ingress_rule" "allow_db_ingress" {
#   security_group_id            = aws_security_group.sg_database.id
#   referenced_security_group_id = aws_security_group.sg_apps.id
#   ip_protocol                  = "tcp"
#   from_port                    = var.db_port
#   to_port                      = var.db_port
# }

resource "aws_security_group" "sg_apps" {
  name        = "allow_send_and_receive_request_from_ssm_and_db"
  description = "Security group for application servers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow send and receive request/response from/to SSM and DB"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_ssm_egress" {
  security_group_id = aws_security_group.sg_apps.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_db_egress" {
  security_group_id = aws_security_group.sg_apps.id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
}

// Create a random password for the RDS instance
resource "random_password" "secret" {
  length           = 32
  special          = true
  override_special = "!#$*-_"
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "database-credentials"
  description = "Database credentials for RDS instance"
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_default_username
    password = random_password.secret.result
  })
}

# data "aws_iam_policy_document" "secret_policy" {
#   statement {
#     sid    = "AllowReadDBCredentials"
#     effect = "Allow"

#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       ]
#     }

#     actions = [
#       "secretsmanager:GetSecretValue",
#       "secretsmanager:DescribeSecret"
#     ]

#     resources = [ aws_secretsmanager_secret.db_secret.arn ]
#   }
# }

# resource "aws_secretsmanager_secret_policy" "db_secret_policy_attachment" {
#   secret_arn = aws_secretsmanager_secret.db_secret.arn
#   policy     = data.aws_iam_policy_document.secret_policy.json

#   depends_on = [ aws_secretsmanager_secret.db_secret ]
# }

# Parameter group enforcing SSL (required for IAM authentication)
# resource "aws_db_parameter_group" "default" {
#   name   = "iam-auth-params"
#   family = "postgres15"

#   parameter {
#     name  = "rds.force_ssl"
#     value = "1"  # IAM authentication requires SSL
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_db_instance" "main_db" {
  identifier = "iam-auth-db-instance"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"

  db_name             = "mydb"
  port                = var.db_port
  username            = var.db_default_username
  password            = random_password.secret.result

  allocated_storage   = 10
  skip_final_snapshot = true

  # Enable IAM database authentication
  iam_database_authentication_enabled = true

  apply_immediately                   = true

  vpc_security_group_ids = [aws_security_group.sg_database.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  depends_on = [aws_db_subnet_group.rds_subnet_group]

    # Force SSL connections (required for IAM auth)
  # parameter_group_name = aws_db_parameter_group.default.name

}

# _______ IAM Policy for Database Access _______

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM policy allowing connection to the RDS instance
resource "aws_iam_policy" "rds_connect" {
  name        = "rds-iam-connect"
  description = "Allow IAM authentication to the RDS instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "rds-db:connect"
        Resource = "arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.main_db.resource_id}/${aws_iam_role.ec2_instance_role.name}"
      }
    ]
  })
}


# _______ EC2 _______

# Trust Policy
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

# Role
resource "aws_iam_role" "ec2_instance_role" {
  name               = "EC2InstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attachment Policies to Role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_connect_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.rds_connect.arn
}

# Create a profile for EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_instance_role.name
}

# Fetch the latest AMI
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instance_test" {
  ami                    = data.aws_ami.ami.id
  subnet_id              = local.ec2_subnets_ids[0]
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_apps.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting Script"

              export DB_HOST="${aws_db_instance.main_db.address}"
              export DB_PORT="${aws_db_instance.main_db.port}"
              export DB_NAME="${aws_db_instance.main_db.db_name}"
              export DB_USER="${aws_db_instance.main_db.username}"

              export SECRET_DB_PASS=${aws_secretsmanager_secret.db_secret.name}

              export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRET_DB_PASS --query SecretString --output text | jq -r .password)

              # Install necessary packages
              dnf install nc -y
              dnf install iputils -y
              dnf install awscli -y
              dnf install jq -y

              dnf install python3 -y
              dnf install python3-pip

              pip3 install boto3
              pip install psycopg2-binary

              export LOG_FILE=/tmp/check_connection_$(date +"%Y%m%d_%H%M%S").log

              nc -zv $DB_HOST $DB_PORT >> $LOG_FILE 2>&1

              # Attempt a lightweight query
              psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1

              # Check the exit status of the previous command
              if [ $? -eq 0 ]; then
                  echo "Connection successful! Credentials and database permissions are valid." | tee -a $LOG_FILE
              else
                  echo "Connection failed. Please check your credentials or network settings." | tee -a $LOG_FILE
              fi

              # Clear the password variable from memory
              unset PGPASSWORD
              EOF

}
