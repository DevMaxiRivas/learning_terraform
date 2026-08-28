### Reto 4: Rotación de Logs (EC2 → CloudWatch)
Los logs de una aplicación no deben morir si el servidor se borra.

*   **El Escenario:** Tienes una aplicación en EC2 que genera un archivo de texto en `/var/log/myapp.log`.
*   **El Desafío:** 
    1.  Crea un Rol que permita crear grupos de logs y enviar flujos de logs a **Amazon CloudWatch**.
    2.  Configura la EC2 para que envíe sus logs en tiempo real a la consola de CloudWatch.
    3.  Asegúrate de que la política del Rol solo permita escribir logs, pero no borrarlos.
*   **Lo que practicarás:** 
    *   Integración de monitoreo.
    *   Permisos granulares sobre acciones de escritura de logs (`logs:CreateLogStream`, `logs:PutLogEvents`).
