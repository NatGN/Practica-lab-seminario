# Línea base de consultas

## Diagnóstico 7 oct

### C7 - Tendencia de pedidos por mes
- Execution Time: 18.230 ms.
- Nodo principal: GroupAggregate.
- Filas estimadas / reales: 20001 / 13 en GroupAggregate.
- El plan realiza Seq Scan sobre pedido y procesa las 20,002 filas.
- Fracción de la tabla utilizada: 1.0000 (100 %).
- Veredicto: un índice simple sobre fecha_pedido no se justifica para esta consulta, ya que necesita procesar prácticamente toda la tabla.
- Columna candidata: ninguna para C7.
- Hipótesis del jueves: se corrige.

### C4 - Pedidos con total mayor al promedio
- Execution Time: 13.677 ms.
- Filas estimadas / reales: 6667 / 9973.
- Rows Removed by Filter: 10029.
- Fracción de la tabla: 0.4986 (49.86 %).
- Veredicto: el filtro devuelve casi la mitad de la tabla, por lo que no es muy selectivo. Sin embargo, un índice sobre total podría ayudar principalmente al ORDER BY total DESC LIMIT 20.
- Columna candidata: total.
- Hipótesis del jueves: se mantiene parcialmente.

### C6 - Clientes con gasto superior al promedio
- Execution Time: 11.698 ms.
- Filas estimadas / reales: 167 / 239 en el CTE Scan.
- Rows Removed by Filter: 263.
- Fracción de clientes agrupados: 0.4761 (47.61 %).
- El plan realiza Seq Scan sobre pedido y procesa las 20,002 filas antes de agrupar por cliente.
- Veredicto: un índice simple sobre pedido.id_cliente probablemente no genere una mejora importante en C6 porque la consulta necesita procesar prácticamente toda la tabla.
- Columna candidata a comprobar: pedido.id_cliente.
- Hipótesis del jueves: se corrige parcialmente.
