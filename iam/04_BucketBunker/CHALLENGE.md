### Reto 4: El Bucket "Búnker" (IAM Policy vs S3 Bucket Policy)
A veces, los permisos del usuario no son suficientes; el recurso mismo debe protegerse.

*   **El Escenario:** 
    1.  Crea un usuario con `AdministratorAccess` (permisos totales).
    2.  Crea un Bucket de S3.
    3.  Crea una **Bucket Policy** (política de recurso) que deniegue explícitamente (`Deny`) el acceso a ese bucket a todo el mundo, **excepto** si la petición viene de un Rol específico de "Auditoría".
*   **El Desafío:** Comprobar que el Administrador **no puede** ver los archivos del bucket a pesar de tener permisos totales, porque el `Deny` en la política del bucket manda.
*   **Lo que practicarás:** 
    *   La precedencia de políticas (IAM vs Resource-based).
    *   El poder del `Explicit Deny`.
