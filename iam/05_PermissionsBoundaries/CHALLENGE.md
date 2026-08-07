### Reto 3: El Administrador "Limitado" (Permission Boundaries)
Este es uno de los conceptos más difíciles de entender pero más útiles.

*   **El Escenario:** Crea un usuario que sea un "Delegado de IAM". Este usuario debe poder crear nuevos usuarios y asignarles políticas, **PERO** no debe ser capaz de crear un usuario que tenga más permisos que él mismo (por ejemplo, no puede crear un administrador).
*   **Lo que practicarás:** 
    *   `iam_permissions_boundary`.
    *   Control de escalada de privilegios (Privilege Escalation).
*   **Por qué importa:** Evita que un empleado cree una "puerta trasera" con permisos totales.