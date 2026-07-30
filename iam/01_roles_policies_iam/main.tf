resource "aws_s3_bucket" "test_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Challenge 1: Create a user who can only view (Read-Only) S3 buckets, but cannot create a new one
resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

## With AmazonS3ReadOnlyAccess for all buckets
resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


## With custom policies for s3_bucket_name
data "aws_iam_policy_document" "policy_object" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*", ]

  }
}

resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = "Policy read only for ${var.s3_bucket_name}"
  policy      = data.aws_iam_policy_document.policy_object.json
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

## Validation
# aws iam list-attached-user-policies --user-name read_only_s3_user

# Challenge 2: Create a role and assign it to an EC2 instance so that the server can list files from S3 without you having to manually configure credentials on the server.

## Only for bucket test_role
resource "aws_iam_role" "role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.policy_object.json
}

## Creating Profile to attach to new EC2 instance
resource "aws_iam_instance_profile" "profile" {
  name = var.profile_name
  role = var.role_name
}

## Fetch the latest official Amazon AMI
data "aws_ami" "ami_amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## Creating an EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                  = data.aws_ami.ami_amazon.id
  instance_type        = "t3.micro"
  iam_instance_profile = var.profile_name


  tags = {
    Name = "EC2Instance"
  }
}

## Validation
### Check attachment profile
# aws ec2 describe-instances \
#     --instance-ids [instanceID] \
#     --query "Reservations[*].Instances[*].IamInstanceProfile"

### Check roles attachment to profile
# aws iam get-instance-profile --instance-profile-name read-only_test_bucket_role


# Challenge 3: Configure a policy that only allows access to the AWS console if the request comes from a specific IP address (your home).
data "aws_iam_policy_document" "policy_data_access_by_ip" {
  statement {
    actions   = ["*"]
    effect    = "Deny"
    resources = ["*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["102.222.12.123/32"]
    }
  }
}

resource "aws_iam_policy" "policy_access_by_ip" {
  name        = "policy_access_by_ip"
  description = "Ip access Policy"
  policy      = data.aws_iam_policy_document.policy_data_access_by_ip.json
}