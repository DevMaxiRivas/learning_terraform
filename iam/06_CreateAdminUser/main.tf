# 2. Create the IAM User
resource "aws_iam_user" "admin_user" {
  name          = "admin-user"
  force_destroy = true
}

# 3. Create a Login Profile for Console Access
# resource "aws_iam_user_login_profile" "admin_login" {
#   user                    = aws_iam_user.admin_user.name
#   password_reset_required = true
# }

resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# output "admin_password" {
#   value     = aws_iam_user_login_profile.admin_login.password
#   sensitive = true
# }

resource "aws_iam_access_key" "new_user_key" {
  user = aws_iam_user.admin_user.name
}


output "aws_access_key_id" {
  description = "The Access Key ID for the new IAM user"
  value       = aws_iam_access_key.new_user_key.id
}

output "aws_secret_access_key" {
  description = "The Secret Access Key for the new IAM user"
  value       = aws_iam_access_key.new_user_key.secret
  sensitive   = true
}