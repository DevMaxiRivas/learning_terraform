
### Reto 3: El Login "Zero Trust" (IAM Database Authentication)
¿Sabías que puedes entrar a una base de datos de AWS sin usar un password de base de datos, usando solo tu identidad de IAM?

*   **El Escenario:** El usuario `admin-juan` debe poder entrar a la base de datos usando un **token temporal** generado por AWS.
*   **El Desafío:** 
    1.  Activa **IAM Database Authentication** en el recurso `aws_db_instance` de Terraform.
    2.  Crea una política de IAM con la acción `rds-db:connect`.
    3.  Desde la EC2, genera un token de acceso usando `aws rds generate-db-auth-token`.
    4.  Conéctate a la base de datos usando ese token como si fuera la contraseña.
*   **Conceptos Clave:** IAM Auth, Tokens temporales, `rds-db:connect`.

---