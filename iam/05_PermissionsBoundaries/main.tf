# 1. Obtenemos el ID de cuenta dinámicamente
data "aws_caller_identity" "current" {}

resource "aws_iam_user" "delegated_user" {
  name = "delegated_user"
}


data "aws_iam_policy_document" "boundary_policy_doc" {
  statement {
    sid    = "AllowEc2AndS3"
    effect = "Allow"
    actions = [
      "s3:*",
      "ec2:*"
    ]
  }
}

resource "aws_iam_policy" "boundary_policy" {
  name   = "AllowOnlyAccessToEC2andS3"
  policy = aws_iam_policy_document.boundary_policy_doc.json
}

resource "aws_iam_policy" "delegated_policy" {
  name = "IAMDelegatedPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "DenyUserAndRoleCreationWithOutPermBoundary",
        "Effect" : "Deny",
        "Action" : [
          "iam:CreateUser",
          "iam:CreateRole"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
        ],
        "Condition" : {
          "StringNotEquals" : {
            "iam:PermissionsBoundary" : "arn:aws:iam::MyAccount_ID:policy/AllowOnlyAccessToEC2andS3"
          }
        }
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.delegated_user.arn
  policy_arn = aws_iam_policy.delegated_policy.arn
}

