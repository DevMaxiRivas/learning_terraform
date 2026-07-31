### Reto 2: El "Salto" de Confianza (Acceso entre Cuentas)
Este es un clásico de arquitectura. Tienes una **Cuenta A** (Desarrollo) y una **Cuenta B** (Producción).

*   **El Escenario:** 
    1.  En la **Cuenta B**, crea un Rol llamado `AnalistaDeLogs` que permita leer un bucket de S3.
    2.  Configura la **Trust Policy** para que solo usuarios de la **Cuenta A** puedan usarlo.
    3.  En la **Cuenta A**, crea un Usuario que tenga permiso para hacer `sts:AssumeRole` hacia ese rol de la Cuenta B.
*   **Lo que practicarás:** 
    *   `Principal` con ARN de otra cuenta.
    *   Flujo de seguridad entre cuentas (Cross-account access).

