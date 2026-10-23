-- ============================================================
-- TresD · Carga de datos
-- ============================================================

-- 1. ROL
INSERT INTO rol (id_rol, nombre_rol) VALUES
(1, 'administrador'), (2, 'cliente'), (3, 'encargado_pedidos'), (4, 'encargado_envios');

-- 2. CATEGORIA
INSERT INTO categoria (id_categoria, nombre_categoria) VALUES
(1, 'Figuras decorativas'), (2, 'Juguetes'), (3, 'Prototipos'), (4, 'Accesorios');

-- 3. USUARIO
INSERT INTO usuario (id_usuario, nombre, apellidos, correo, password_hash, telefono, estado, id_rol) VALUES
(1, 'Jesus', 'Diaz Hernandez', 'jesus@tresd.com', 'hash1', '5512345678', 'activo', 2),
(2, 'Natalia', 'Godinez Alavez', 'natalia@tresd.com', 'hash2', '5512345679', 'activo', 2),
(3, 'Paulina', 'Meraz Alcantara', 'paulina@tresd.com', 'hash3', '5512345670', 'activo', 1),
(4, 'Admin', 'TresD', 'admin@tresd.com', 'hash4', '5512345671', 'activo', 1);

-- 4. RECUPERACION_CONTRASENA
INSERT INTO recuperacion_contrasena (id_recuperacion, id_usuario, token_hash, fecha_expiracion) VALUES
(1, 1, 'token_hash_1', now() + interval '1 day');

-- 5. CLIENTE
INSERT INTO cliente (id_cliente, id_usuario) VALUES (1, 1), (2, 2);

-- 6. PRODUCTO
INSERT INTO producto (id_producto, nombre_producto, descripcion, material, disponible, id_categoria) VALUES
(1, 'Figura dragón', 'Dragón articulado impreso en 3D', 'PLA', true, 1),
(2, 'Maceta geométrica', 'Maceta low poly', 'PLA', true, 1),
(3, 'Robot articulado', 'Robot de 30 cm', 'PLA', true, 2),
(4, 'Llavero personalizado', 'Llavero con nombre', 'PLA', true, 4);

-- 7. VARIANTE_PRODUCTO
INSERT INTO variante_producto (id_variante, id_producto, color, alto_cm, ancho_cm, largo_cm, precio, disponible) VALUES
(1, 1, 'Rojo', 15.00, 10.00, 8.00, 250.00, true),
(2, 1, 'Azul', 15.00, 10.00, 8.00, 250.00, true),
(3, 2, 'Blanco', 12.00, 12.00, 12.00, 180.00, true),
(4, 3, 'Verde', 30.00, 15.00, 10.00, 450.00, true),
(5, 4, 'Negro', 5.00, 3.00, 0.50, 50.00, true);

-- 8. DIRECCION
INSERT INTO direccion (id_direccion, id_cliente, calle, numero_exterior, colonia, municipio, estado, codigo_postal) VALUES
(1, 1, 'Av. Reforma', '123', 'Centro', 'Cuautitlán', 'México', '54800'),
(2, 2, 'Calle 5', '456', 'San Juan', 'Cuautitlán', 'México', '54801');

-- 9. PEDIDO
INSERT INTO pedido (id_pedido, fecha_pedido, estado, subtotal, costo_envio, total, id_cliente, id_direccion) VALUES
(1, now(), 'pendiente_pago', 250.00, 50.00, 300.00, 1, 1),
(2, now(), 'enviado', 430.00, 50.00, 480.00, 2, 2);

-- 10. DETALLE_PEDIDO
INSERT INTO detalle_pedido (id_detalle, id_pedido, id_variante, cantidad, color_comprado, alto_comprado_cm, ancho_comprado_cm, largo_comprado_cm, precio_unitario, subtotal) VALUES
(1, 1, 1, 1, 'Rojo', 15.00, 10.00, 8.00, 250.00, 250.00),
(2, 2, 3, 1, 'Blanco', 12.00, 12.00, 12.00, 180.00, 180.00),
(3, 2, 5, 1, 'Negro', 5.00, 3.00, 0.50, 250.00, 250.00);

-- 11. PAGO
INSERT INTO pago (id_pago, id_pedido, fecha_pago, metodo_pago, monto, referencia, estado_pago) VALUES
(1, 1, now(), 'Tarjeta', 300.00, 'REF001', 'aprobado'),
(2, 2, now(), 'Efectivo', 480.00, 'REF002', 'aprobado');

-- 12. ENVIO
INSERT INTO envio (id_envio, id_pedido, paqueteria, numero_guia, fecha_envio, fecha_entrega) VALUES
(1, 2, 'DHL', 'GUIA123', now(), now() + interval '3 days');

-- ============================================================
-- CARGA CON VOLUMEN
-- ============================================================

-- 500 usuarios cliente
INSERT INTO usuario (id_usuario, nombre, apellidos, correo, password_hash, telefono, estado, id_rol)
SELECT g, 'Cliente' || g, 'Apellido' || g,
       'cliente' || g || '@tresd.com', 'hash' || g,
       '55' || lpad(g::text, 8, '0'), 'activo', 2
FROM generate_series(10, 509) g;

-- 500 clientes
INSERT INTO cliente (id_cliente, id_usuario)
SELECT g, g FROM generate_series(10, 509) g;

-- 500 direcciones
INSERT INTO direccion (id_direccion, id_cliente, calle, numero_exterior, colonia, municipio, estado, codigo_postal)
SELECT g, g, 'Calle ' || g, g::text, 'Colonia ' || g,
       'Cuautitlán', 'México', lpad((54800 + g)::text, 5, '0')
FROM generate_series(10, 509) g;

-- 20,000 pedidos
INSERT INTO pedido (id_pedido, fecha_pedido, estado, subtotal, costo_envio, total, id_cliente, id_direccion)
SELECT
  g,
  now() - (random() * interval '365 days'),
  (ARRAY['pendiente_pago','confirmado','enviado','entregado','cancelado'])[floor(random()*5+1)],
  round((random() * 5000)::numeric, 2),
  50.00,
  round((random() * 5000 + 50)::numeric, 2),
  (random() * 499 + 10)::int,
  (random() * 499 + 10)::int
FROM generate_series(100, 20099) g;