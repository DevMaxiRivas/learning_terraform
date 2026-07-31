
# Identity Policy for Account B
data "aws_iam_policy_document" "s3_read_only_policy_doc" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::",    
      "arn:aws:s3:::/*"   
    ]
    # condition {
    #   test = "StringEquals"
    #   values = "&{aws:PrincipalTag/Team}"
    #   variable = "aws:ResourceTag/Team"
    # }
  }
}

# Trust Policy for Account B
data "aws_iam_policy_document" "s3_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "AnalistaDeLogs"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}