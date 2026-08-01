# Reto 1: El Proyecto "Solo mi Proyecto" (ABAC - Attribute Based Access Control)

data "aws_iam_policy_document" "s3_read_only_policy_doc" {
  statement {
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
    condition {
      test = "StringEquals"
      variable = "aws:ResourceTag/Team"
      values = "$${aws:PrincipalTag/Team}"
    }
  }
}