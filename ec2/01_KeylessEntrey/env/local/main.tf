module "vpc" {
  source              = "../../modules/vpc"
  cidr_block          = var.cidr_block
  vpc_tags            = var.vpc_tags
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnets
  private_subnet_cidr = var.private_subnets
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

# Security Group mínimo para SSM
resource "aws_security_group" "ssm_sg" {
  name        = "ssm-sg"
  description = "Permitir salida para SSM"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use the retrieved AMI ID and SSM Profile in an EC2 instance
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ami.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.private_subnet_id

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  vpc_security_group_ids = [aws_security_group.ssm_sg.id]

  tags = {
    Name = "local_ec2-instance"
  }
}


# Interactive Shell Connection Test
# aws ssm start-session -target $(terraform output -raw ec2_instance_id)

# Execution Command test
# aws ssm send-command \
#   --instance-ids $(terraform output -raw ec2_instance_id) \
#   --document-name AWS-RunShellScript \
#   --parameters commands='["echo hello"]'

# aws ssm send-command \
#   --instance-ids i-15666fba90ae702c4 \
#   --document-name AWS-RunShellScript \
#   --parameters commands='["echo hello"]'

# Get execution command result
# aws ssm get-command-invocation \
#     --command-id "9ec6f3f3-b7a8-4347-a6dc-2b05d0753075" \
#     --instance-id "i-15666fba90ae702c4"