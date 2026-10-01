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