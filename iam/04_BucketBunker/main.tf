resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-123456"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_deny_policy_doc" {
  statement {
    sid = "DenyS3Access"
    actions   = ["s3:*"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}", 
      "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*"
    ]
    effect    = "Deny"
    condition {
      test = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Auditoria"]
    }
  }
  
}

resource "aws_iam_user" "admin_user" {
  name = "AdminUser"
}

# Attach the policy directly to the IAM User
resource "aws_iam_user_policy_attachment" "attach_to_user" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}