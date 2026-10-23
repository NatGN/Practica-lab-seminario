# Equipo XX — Esquema relacional del proyecto

**Dominio de negocio:**

**Integrantes:**
-Natalia Godinez Alavez
-Paulina Monserrat Meraz Alcantara
-Jesus Diaz Hernandez

**Enlace al diagrama E/R del jueves 17** (dbdiagram.io, Mermaid o archivo en el repositorio del proyecto):

---

## 1. Esquema relacional

<!-- Transformen su E/R completo con la notación de guias/notacion.md.
     Todas las tablas, todas las PK, todas las FK y el ? donde corresponda. -->

```
ROL(**id_rol**, nombre, descripcion?)

USUARIO(**id_usuario**, nombre, apellidos, correo UNIQUE, contrasena_hash, telefono, id_rol → ROL, fecha_registro, estatus, fecha_ultimo_login?)

RECUPERACION_CONTRASENA(**id_recuperacion**, id_usuario → USUARIO, token UNIQUE, fecha_solicitud, fecha_expiracion, usado)

DIRECCION(**id_direccion**, id_usuario → USUARIO, calle, numero_exterior, numero_interior?, colonia, ciudad, estado, codigo_postal, pais, referencias?)

CATEGORIA(**id_categoria**, nombre, descripcion?)

PRODUCTO(**id_producto**, nombre, descripcion, precio, stock, material, color, tiempo_impresion_horas, dimensiones, id_categoria → CATEGORIA, personalizable, activo)

PEDIDO(**id_pedido**, id_usuario → USUARIO, id_direccion_envio → DIRECCION, fecha_pedido, subtotal, costo_envio, total, estado, metodo_envio)

DETALLE_PEDIDO(**id_pedido** → PEDIDO, **id_producto** → PRODUCTO, cantidad, precio_unitario, personalizacion?, subtotal)

PAGO(**id_pago**, id_pedido → PEDIDO, fecha_pago, monto, metodo_pago, estatus_pago, referencia_pago?, ultimos_digitos_tarjeta?, banco?)

ENVIO(**id_envio**, id_pedido → PEDIDO, id_direccion → DIRECCION, paqueteria, numero_guia, fecha_envio, fecha_estimada_entrega, fecha_entrega_real?, estatus_envio, costo_envio)

```

## 2. Relaciones N:M y cómo las resolvieron

| Relación en el E/R | Tabla intermedia | Llave primaria de la tabla intermedia | ¿Se puede repetir la misma pareja? ¿Por qué? |
|---|---|---|---|
| Pedido — Producto | `DETALLE_PEDIDO` | `(id_pedido, id_producto)` | No, porque un mismo producto no debería aparecer dos veces en el mismo pedido. Si el cliente quiere 3 figuras iguales, se pone `cantidad = 3`. |

## 3. Relaciones 1:1, recursivas, débiles y multivaluados

<!-- Si su E/R no tiene alguno de estos casos, escriban "No aplica". -->


| Caso | Dónde aparece en su E/R | Cómo lo resolvieron |
|---|---|---|
| Relación 1:1 | No aplica | No tienen ninguna relación 1:1 en su E/R. |
| Relación recursiva | No aplica | No hay jerarquías dentro de las entidades. |
| Entidad débil | `Detalle_Pedido` depende de `Pedido` | Se creó la tabla `DETALLE_PEDIDO` con PK compuesta `(id_pedido, id_producto)`. |
| Atributo multivaluado | No aplica | No tienen atributos que se repitan. |


## 4. Llaves foráneas que admiten NULL

<!-- Toda FK con ? necesita una razón de negocio. -->

| Tabla.columna | Por qué puede quedar vacía |
|---|---|
| `USUARIO.fecha_ultimo_login?` | Un usuario recién registrado nunca ha iniciado sesión. |
| `DIRECCION.numero_interior?` | No todas las casas tienen número interior. |
| `DIRECCION.referencias?` | No todos ponen referencias para encontrar el domicilio. |
| `DETALLE_PEDIDO.personalizacion?` | No todos los productos son personalizados. |
| `PAGO.referencia_pago?` | No todos los métodos de pago generan una referencia. |
| `PAGO.ultimos_digitos_tarjeta?` | Solo aplica si el cliente pagó con tarjeta. |
| `PAGO.banco?` | Solo aplica si pagó con tarjeta o transferencia. |
| `ENVIO.fecha_entrega_real?` | El paquete puede no haber llegado todavía. |
| `PRODUCTO.descripcion?` | Un producto puede no tener descripción larga. |
| `CATEGORIA.descripcion?` | Una categoría puede no tener descripción. |
| `ROL.descripcion?` | Un rol puede no tener descripción. |

## 5. Cambios respecto del E/R del jueves

<!-- Al pasar a tablas casi siempre aparece algo que el E/R no dejaba ver.
     Si cambiaron algo del diagrama, díganlo aquí. Si no cambiaron nada, escriban "Ninguno". -->

- Se agregó la tabla `DETALLE_PEDIDO` (la que faltaba).
- Se agregó la tabla `DIRECCION` desglosada (calle, número, colonia, etc.) para envíos a domicilio.
- Se agregó la tabla `ENVIO` para el seguimiento de paquetes (paquetería, número de guía, fechas).
- Se agregó la tabla `ROL` y se unificó `CLIENTE` y `EMPLEADO` en una sola tabla `USUARIO` con roles (administrador y cliente).
- Se agregó la tabla `RECUPERACION_CONTRASENA` para el reenvío de contraseña.
- Se enriqueció `PRODUCTO` con atributos propios de impresión 3D: `material`, `color`, `tiempo_impresion_horas`, `dimensiones`, `personalizable`.
- Se formalizó `PEDIDO.estado` con valores definidos (pendiente, en producción, enviado, entregado, cancelado).
- Se agregó `contrasena_hash` a `USUARIO` para el login seguro.
- Se agregaron `apellidos`, `telefono`, `fecha_registro`, `estatus` a `USUARIO`.
- Se agregó `PAGO.referencia_pago`, `ultimos_digitos_tarjeta` y `banco` para pagos con tarjeta o transferencia.
