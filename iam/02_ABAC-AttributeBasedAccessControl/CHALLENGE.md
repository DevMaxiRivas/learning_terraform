
---

### Reto 1: El Proyecto "Solo mi Proyecto" (ABAC - Attribute Based Access Control)
En empresas grandes, no puedes crear una política para cada servidor. Se usan etiquetas (Tags).

*   **El Escenario:** Crea una política que permita a un usuario encender (`StartInstances`) o apagar (`StopInstances`) servidores EC2, **PERO** solo si la instancia tiene un Tag que coincida con el nombre del equipo del usuario.
*   **Lo que practicarás:** 
    *   Uso de `Condition` con `aws:ResourceTag/Project`.
    *   Concepto de ABAC (Control de acceso basado en atributos).
*   **Pista:** Usa `${aws:PrincipalTag/Team}` para comparar el tag del usuario con el tag del recurso.

---