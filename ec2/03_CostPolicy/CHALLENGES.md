### Reto 3: El "Policía de Costos" (Restricción de Tipos de Instancia)
A veces quieres permitir que un equipo cree servidores, pero no quieres que creen máquinas carísimas por error.

*   **El Escenario:** Un usuario de IAM tiene permiso para crear instancias EC2.
*   **El Desafío:** 
    1.  Crea una política de IAM que permita `ec2:RunInstances`.
    2.  Añade una **Condition** que solo permita crear instancias de tipo `t2.micro` o `t3.micro`.
    3.  Añade otra condición que **obligue** a que la instancia tenga un Tag llamado `Environment`. Si no lo tiene, la creación debe fallar.
*   **Lo que practicarás:** 
    *   Condiciones avanzadas de EC2 (`ec2:InstanceType` y `aws:RequestTag`).
    *   Gobernanza de costos mediante IAM.

