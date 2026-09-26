### Reto 1: La "Bóveda Aislada" (Conectividad Privada)
El error más común es poner una base de datos en una subred pública. El objetivo es el aislamiento total.

*   **El Escenario:** Crea una base de datos RDS (MySQL o Postgres) que sea totalmente inaccesible desde internet.
*   **El Desafío:** 
    1.  Crea un **DB Subnet Group** que solo incluya tus subredes privadas.
    2.  Configura un **Security Group** para la RDS que **solo** permita tráfico en el puerto 3306 (o 5432) si el origen es el Security Group de tu instancia EC2 (esto se llama *Security Group Referencing*).
    3.  Desde la EC2, intenta conectarte usando el cliente de base de datos (`mysql` o `psql`) sin usar llaves SSH.
*   **Conceptos Clave:** DB Subnet Groups, Security Group Ingress Rules (Source SG).

### Reto 2: "Adiós a las contraseñas en código" (Secrets Manager)
Nunca, bajo ninguna circunstancia, debes escribir el password de la base de datos en tu código de Terraform o en el `user_data`.

*   **El Escenario:** La contraseña de la base de datos debe ser generada aleatoriamente por AWS y consumida de forma segura.
*   **El Desafío:** 
    1.  Usa Terraform para generar un recurso `aws_secretsmanager_secret`.
    2.  Configura la RDS para que use la contraseña almacenada en el secreto.
    3.  Crea una política de IAM para la EC2 que permita leer ese secreto específico.
    4.  En el `user_data` de la EC2, usa la **AWS CLI** para obtener la contraseña del Secrets Manager y así conectarte a la base de datos.
*   **Conceptos Clave:** `aws_secretsmanager_secret`, IAM policy para secretos, `aws ssm get-parameter` o `secretsmanager get-secret-value`.
