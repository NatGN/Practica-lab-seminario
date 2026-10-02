-- C2 · autor: NatGN · ¿Qué clientes no han hecho ningún pedido?
SELECT c.id_cliente, u.nombre, u.apellidos, u.correo
FROM cliente c
JOIN usuario u ON u.id_usuario = c.id_usuario
LEFT JOIN pedido p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, u.nombre, u.apellidos, u.correo
HAVING count(p.id_pedido) = 0
ORDER BY c.id_cliente;

-- C5 · autor: NatGN · ¿Qué variantes de producto nunca se han vendido?
SELECT vp.id_variante, pr.nombre_producto, vp.color
FROM variante_producto vp
JOIN producto pr ON pr.id_producto = vp.id_producto
WHERE NOT EXISTS (
  SELECT 1 FROM detalle_pedido dp
  WHERE dp.id_variante = vp.id_variante
);
-- C3 · autor: Pau24711
-- ¿Qué estados de pedido tienen más de 4,000 pedidos
-- y cuánto dinero representan en ventas?

SELECT
    estado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(SUM(total), 2) AS ingreso_total,
    ROUND(AVG(total), 2) AS promedio_pedido
FROM pedido
GROUP BY estado
HAVING COUNT(*) > 4000
ORDER BY cantidad_pedidos DESC;


-- C6 · autor: Pau24711
-- ¿Qué clientes han gastado más que el promedio
-- de gasto de todos los clientes?

WITH gasto_cliente AS (
    SELECT
        id_cliente,
        COUNT(*) AS cantidad_pedidos,
        SUM(total) AS total_gastado
    FROM pedido
    GROUP BY id_cliente
)

SELECT
    c.id_cliente,
    u.nombre,
    u.apellidos,
    g.cantidad_pedidos,
    ROUND(g.total_gastado, 2) AS total_gastado
FROM gasto_cliente g
JOIN cliente c
    ON c.id_cliente = g.id_cliente
JOIN usuario u
    ON u.id_usuario = c.id_usuario
WHERE g.total_gastado > (
    SELECT AVG(total_gastado)
    FROM gasto_cliente
)
ORDER BY g.total_gastado DESC;
