module "vpc" {
  source              = "./../../modules/vpc"
  cidr_block          = var.cidr_block
  public_subnet_cidr  = var.public_subnets
  private_subnet_cidr = var.private_subnets
  availability_zone   = var.availability_zone
  vpc_tags            = var.vpc_tags
}

# Bucket Creation
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name
  tags = {
    Name        = "Configuration File Bucket"
    Environment = "Test"
  }
}

resource "aws_s3_object" "script-file" {
  bucket     = var.bucket-name
  key        = var.script-path
  source     = "./script.sh"
  depends_on = [aws_s3_bucket.bucket]
}

# Trust Policy
data "aws_iam_policy_document" "trust-policy-doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role and Permission Definition
data "aws_iam_policy_document" "permission-policy-doc" {
  statement {
    sid = "AllowGetInitInstanceScript"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_object.script-file.arn}"
    ]
  }

    # Opcional: Ayuda a la CLI a localizar el bucket rápidamente
  statement {
    actions = ["s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${var.bucket-name}"]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "AllowGetInitInstanceScriptPolicy"
  policy = data.aws_iam_policy_document.permission-policy-doc.json
}

resource "aws_iam_role" "role" {
  name               = "AccessToInitScriptRole"
  assume_role_policy = data.aws_iam_policy_document.trust-policy-doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

# To verify the downloaded script using a command via SSM
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Profile Definition
resource "aws_iam_instance_profile" "profile" {
  name = "InstanceInitProfile"
  role = aws_iam_role.role.name
}

# Fech AMI amazon
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


resource "aws_instance" "instance" {
  ami                  = data.aws_ami.ami.id
  subnet_id            = module.vpc.private_subnet_id
  iam_instance_profile = aws_iam_instance_profile.profile.name
  instance_type        = "t3.micro"
  tags = {
    Name = "local_ec2-instance"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo "Running Script"

              # Instalando AWS CLI
              dnf install awscli -y

              mkdir -p /tmp/scripts

              # Comando que permite registrar lo que a partir de este punto
              # se muestre en consola.
              # exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              aws s3 cp s3://${format("%s%s", var.bucket-name, var.script-path)} /tmp/scripts/init.sh
              chmod +x /tmp/scripts/init.sh
              
              source /tmp/scripts/init.sh
              EOF
}


# aws ssm send-command \
#   --instance-ids i-cdce2e9215e6140fb \
#   --document-name AWS-RunShellScript \
#   --parameters commands='["cat /tmp/scripts/init.sh"]'
#   --parameters commands='["cat /var/log/user-data.log"]'

# aws ssm get-command-invocation \
#     --command-id d874ba74-051f-4cfb-a534-925c8fdedcad \
#     --instance-id i-cdce2e9215e6140fb