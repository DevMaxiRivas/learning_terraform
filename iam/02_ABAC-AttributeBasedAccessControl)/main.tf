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
      values = "&{aws:PrincipalTag/Team}"
      variable = "aws:ResourceTag/Team"
    }
  }
}