# Reto 2: El "Salto" de Confianza (Acceso entre Cuentas)
# Este es un clásico de arquitectura. Tienes una Cuenta A (Desarrollo) y una Cuenta B (Producción).

# El Escenario:
# En la Cuenta B, crea un Rol llamado AnalistaDeLogs que permita leer un bucket de S3.
# Configura la Trust Policy para que solo usuarios de la Cuenta A puedan usarlo.
# En la Cuenta A, crea un Usuario que tenga permiso para hacer sts:AssumeRole hacia ese rol de la Cuenta B.
# Lo que practicarás:
# Principal con ARN de otra cuenta.
# Flujo de seguridad entre cuentas (Cross-account access).

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "logs-bucket"
}

# Identity Policy for Account B accountIdB = 1111111111111111 (I am B account)
data "aws_iam_policy_document" "s3_identity_policy_doc" {
  statement {
    sid = "AllowS3ReadAccessToLogsBucket"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3::${aws_s3_bucket.logs_bucket.id}:",    
      "arn:aws:s3::${aws_s3_bucket.logs_bucket.id}:/*"   
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "PolicyAllowS3ReadAccessToLogsBucket"
  description = "Policy that allows S3 read access to the logs bucket"
  policy      = data.aws_iam_policy_document.s3_identity_policy_doc.json
}


# Trust Policy for Account A's users accountIdA = 2222222222222222
data "aws_iam_policy_document" "s3_trust_policy_doc" {
  statement {
    sid = "AllowAssumeRoleUsersFromAccountA"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::2222222222222222:user/*"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "AnalistaDeLogs"
  assume_role_policy = data.aws_iam_policy_document.s3_trust_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "s3_user" {
  name = "UserAnalistaDeLogs"
}

# Define the inline permission policy document
data "aws_iam_policy_document" "assume_role_policy_doc" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.role.arn]
  }
}

# Create the Managed IAM Policy
resource "aws_iam_policy" "user_assume_role_policy" {
  name        = "allow-assume-AnalistaDeLogs-role"
  description = "Allows the user to assume the AnalistaDeLogs role"
  policy      = data.aws_iam_policy_document.assume_role_policy_doc.json
}

# Attach the policy directly to the IAM User
resource "aws_iam_user_policy_attachment" "attach_to_user" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.user_assume_role_policy.arn
}