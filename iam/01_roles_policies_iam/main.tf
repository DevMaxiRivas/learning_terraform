resource "aws_s3_bucket" "test_bucket" {
    bucket = var.s3_bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Reto 1: Crea un usuario que solo pueda ver (Read-Only) los buckets de S3, pero que no pueda crear uno nuevo
resource "aws_iam_user" "user" {
    name = "read_only_s3_user"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

# With AmazonS3ReadOnlyAccess for all buckets
resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# With custom policies for s3_bucket_name
data "aws_iam_policy_document" "policy_object" {
    statement {
        actions   = [
            "s3:Get*",
            "s3:List*",
            "s3:Describe*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
        ]
        resources = [ "arn:aws:s3:::${var.s3_bucket_name}/*",]
    }
}

resource "aws_iam_policy" "policy" {
  name   = "read-only_${var.s3_bucket_name}"
  description = "Policy read only for ${var.s3_bucket_name}"
  policy = data.aws_iam_policy_document.policy_object.json
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

# Reto 2: Crea un Rol y asígnalo a una instancia de EC2 para que el servidor pueda listar archivos de S3 sin que tú tengas que configurar credenciales manualmente dentro del servidor.

resource "aws_iam_role" "test_role" {
  name = "read-only_${var.s3_bucket_name}_role"
  assume_role_policy = data.aws_iam_policy_document.policy_object.json
}