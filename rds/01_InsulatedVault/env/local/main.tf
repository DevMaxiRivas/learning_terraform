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
resource "aws_vpc_security_group_ingress_rule" "allow_db_ingress" {
  security_group_id = aws_security_group.sg_database.id
  referenced_security_group_id = aws_security_group.sg_apps.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
}

resource "aws_security_group" "sg_apps" {
  name        = "allow_send_and_receive_request_from_ssm_and_db"
  description = "Security group for application servers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow send and receive request/response from/to SSM and DB"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssm_egress" {
  security_group_id = aws_security_group.sg_apps.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "random_password" "secret" {
  length           = 32
  special          = true
  override_special = "!#$*-_"
}

resource "aws_db_instance" "default" {
  allocated_storage   = 10
  db_name             = "mydb"
  port = 3306
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = random_password.secret.result
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.sg_database.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  depends_on = [aws_db_subnet_group.rds_subnet_group]
}


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
resource "aws_iam_role" "ssm_role" {
  name               = "SSMClient"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attachment Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create a profile for EC2 instance
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMClientProfile"
  role = aws_iam_role.ssm_role.name
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
  ami                  = data.aws_ami.ami.id
  subnet_id            = local.ec2_subnets_ids[0]
  instance_type        = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_apps.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting Script"

              export DB_HOST="${aws_db_instance.default.address}"
              export DB_PORT="${aws_db_instance.default.port}"
              export DB_USER="${aws_db_instance.default.username}"
              export DB_PASS="${random_password.secret.result}"

              echo "Checking TCP connection..."
              dnf install nc -y
              dnf install iputils -y

              export LOG_FILE=/tmp/check_connection_$(date +"%Y%m%d_%H%M%S").log

              nc -zv $DB_HOST $DB_PORT >> $LOG_FILE 2>&1

              # Install MariaDB client
              dnf install mariadb105-server-utils.x86_64 -y

              # Check connection
              if mysqladmin --user="$DB_USER" --password="$DB_PASS" --host="$DB_HOST" --port="$DB_PORT" ping &>/dev/null; then
                  echo "MySQL connection successful!" | tee -a $LOG_FILE
              else
                  echo "MySQL connection failed!" | tee -a $LOG_FILE
                  exit 1
              fi
              EOF

}
