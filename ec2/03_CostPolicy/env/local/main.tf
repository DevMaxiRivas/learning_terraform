# Role and Permission Definition
data "aws_iam_policy_document" "permission-policy-doc" {
  statement {
    sid       = "AllowDescribeActions"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowRunInstancesWithLimits"
    actions = [ "ec2:RunInstances" ]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test = "StringEquals"
      variable = "ec2:InstanceType"
      values = [ "t2.micro", "t3.micro" ]
      
    }

    condition {
      test = "Null"
      variable = "aws:RequestTag/Environment"
      values = ["false"]
    }
  }

}

resource "aws_iam_policy" "policy" {
  name   = "AllowRunOnlyLowCostInstancePolicy"
  policy = data.aws_iam_policy_document.permission-policy-doc.json
}

resource "aws_iam_user" "example_user" {
  name = "example-user"
}

resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.policy.arn
}