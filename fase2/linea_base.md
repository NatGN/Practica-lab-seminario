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

## Resultados 8 oct

### Índice 2 - C6: Clientes con gasto superior al promedio

- **Autor:** jesusdz15
- **Índice probado:** `pedido_id_cliente_idx`
- **Consulta:** C6
- **Código utilizado:** `CREATE INDEX pedido_id_cliente_idx ON pedido (id_cliente);`

**Justificación:**

Se probó un índice sobre `pedido.id_cliente` porque es una llave foránea que no tenía índice. En el diagnóstico anterior se observó que C6 utilizaba un Seq Scan y leía los 20,002 registros de pedido.

**Resultados obtenidos:**

| Medición | Antes (ms) | Después (ms) |
|---|---:|---:|
| 1 | 16.934 | 11.937 |
| 2 | 12.813 | 11.958 |
| 3 | 11.899 | 12.236 |
| Tiempo intermedio | 12.813 | 11.958 |

- **Antes:** Seq Scan on pedido, 211 Buffers (shared hit), 12.813 ms.
- **Después:** Seq Scan on pedido, 211 Buffers (shared hit), 11.958 ms.

**Veredicto:**

Se decidió eliminar el índice porque PostgreSQL continuó utilizando Seq Scan y los Buffers no disminuyeron. Aunque el tiempo intermedio bajó ligeramente, no se pudo demostrar que esa diferencia fuera consecuencia del índice.

Esto ocurre porque C6 necesita leer todos los pedidos para calcular el gasto total de cada cliente, por lo que el índice sobre `id_cliente` no resultó útil para esta consulta.

Se eliminó con `DROP INDEX IF EXISTS public.pedido_id_cliente_idx;`.
