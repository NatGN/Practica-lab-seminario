
# Fase 4 - Propuesta de distribución

## Proyecto: TresD

**Materia:** Seminario de Análisis y Extracción de Conocimientos de Bases de Datos

**Grupo:** 1002A

**Equipo:** TresD

**Integrantes:**
- Natalia Godinez Alavez
- Paulina Monserrat Meraz Alcantara
- Jesus Diaz Hernandez

**Dominio de negocio:** Tienda en línea de productos fabricados mediante impresión 3D.

## Objetivo

El objetivo de esta práctica fue distribuir los datos de nuestro proyecto TresD utilizando diferentes nodos en Supabase.

Para esto utilizamos fragmentación horizontal, separando los pedidos de nuestra tienda según la fecha en la que fueron realizados.

También comprobamos que no se perdieran registros, que no existieran pedidos repetidos y que las restricciones funcionaran correctamente.

## Parte 1. Criterio de distribución

### Tabla seleccionada

Elegimos la tabla `public.pedido`, porque almacena los pedidos realizados en nuestra tienda.

Esta tabla contiene 20,002 registros.

### Tipo de fragmentación

Horizontal.

### Columna utilizada

`fecha_pedido`

### Consulta frecuente

```sql
SELECT
    id_pedido,
    fecha_pedido,
    estado,
    total
FROM public.pedido
WHERE fecha_pedido >= '2026-01-01'
ORDER BY fecha_pedido DESC;
```

### Justificación

Decidimos separar los pedidos por fecha porque así podemos consultar los pedidos actuales sin tener que revisar todo el historial de ventas.

Los pedidos anteriores a 2026 quedan en un nodo y los pedidos desde 2026 en otro.

Consideramos que esta distribución es útil para nuestro negocio porque podemos organizar mejor los pedidos recientes y los históricos.

## Parte 2. Definición de predicados

Utilizamos dos nodos para distribuir los pedidos.

### Nodo histórico

**Nombre:** `nodo_historico`

**Predicado:**

```sql
fecha_pedido < '2026-01-01'
```

**Registros:** 5,029

### Nodo actual

**Nombre:** `nodo_actual`

**Predicado:**

```sql
fecha_pedido >= '2026-01-01'
```

**Registros:** 14,973

### Consulta utilizada

```sql
SELECT
    COUNT(*) AS total_pedidos,

    COUNT(*) FILTER (
        WHERE fecha_pedido < '2026-01-01'
    ) AS nodo_historico,

    COUNT(*) FILTER (
        WHERE fecha_pedido >= '2026-01-01'
    ) AS nodo_actual,

    COUNT(*) FILTER (
        WHERE fecha_pedido IS NULL
    ) AS filas_huerfanas,

    MIN(fecha_pedido) AS fecha_mas_antigua,

    MAX(fecha_pedido) AS fecha_mas_reciente

FROM public.pedido;
```

### Resultados

| Dato | Resultado |
|---|---:|
| Total de pedidos | 20,002 |
| Pedidos históricos | 5,029 |
| Pedidos actuales | 14,973 |
| Filas huérfanas | 0 |

### Filas huérfanas

No encontramos filas huérfanas.

Todos los pedidos tienen una fecha y cumplen alguna de las dos condiciones que utilizamos.

Por esta razón no fue necesario corregir registros.

Revisión de los predicados: Los pedidos se dividieron según su fecha. En el nodo histórico quedaron 5,029 y en el actual 14,973. La suma corresponde a los 20,002 pedidos originales, sin filas huérfanas.

## Parte 3. Creación de nodos en Supabase

Creamos dos esquemas nuevos llamados `nodo_historico` y `nodo_actual`.

Cada esquema representa un nodo de nuestra base de datos distribuida.

No modificamos las tablas originales de `public`, ya que solamente copiamos los registros.

### Script SQL utilizado

```sql
-- Crear los esquemas
CREATE SCHEMA IF NOT EXISTS nodo_historico;
CREATE SCHEMA IF NOT EXISTS nodo_actual;

-- Crear las tablas
CREATE TABLE nodo_historico.pedido (
    LIKE public.pedido
    INCLUDING CONSTRAINTS
);

CREATE TABLE nodo_actual.pedido (
    LIKE public.pedido
    INCLUDING CONSTRAINTS
);

-- Agregar llave primaria y restricciones
ALTER TABLE nodo_historico.pedido
    ADD CONSTRAINT pk_pedido_historico
        PRIMARY KEY (id_pedido),
    ADD CONSTRAINT frag_historico
        CHECK (
            fecha_pedido IS NOT NULL
            AND fecha_pedido < '2026-01-01'
        );

ALTER TABLE nodo_actual.pedido
    ADD CONSTRAINT pk_pedido_actual
        PRIMARY KEY (id_pedido),
    ADD CONSTRAINT frag_actual
        CHECK (
            fecha_pedido IS NOT NULL
            AND fecha_pedido >= '2026-01-01'
        );

-- Copiar los pedidos históricos
INSERT INTO nodo_historico.pedido
SELECT *
FROM public.pedido
WHERE fecha_pedido < '2026-01-01';

-- Copiar los pedidos actuales
INSERT INTO nodo_actual.pedido
SELECT *
FROM public.pedido
WHERE fecha_pedido >= '2026-01-01';

-- Crear vista global
CREATE VIEW nodo_actual.pedido_global AS
SELECT * FROM nodo_historico.pedido
UNION ALL
SELECT * FROM nodo_actual.pedido;
```

### Resultado

La creación de los nodos se realizó correctamente.

Se copiaron 5,029 pedidos al nodo histórico y 14,973 al nodo actual.

La tabla original conservó sus 20,002 registros.

## Parte 4. Comprobación de las reglas

Después de crear los nodos realizamos las comprobaciones para verificar que la distribución fuera correcta.

Revisión de resultados: La reconstrucción devolvió los 20,002 pedidos originales, no encontramos registros repetidos y la prueba del CHECK rechazó correctamente un pedido que no correspondía al nodo.


### 1. Completitud

Esta regla significa que ningún registro debe perderse al distribuir los datos.

**Consulta:**

```sql
SELECT
    (SELECT COUNT(*) FROM public.pedido)
        AS total_original,

    (SELECT COUNT(*) FROM nodo_historico.pedido)
        AS historicos,

    (SELECT COUNT(*) FROM nodo_actual.pedido)
        AS actuales;
```

**Resultado:**

- Total original: 20,002
- Nodo histórico: 5,029
- Nodo actual: 14,973

La suma de ambos nodos es 20,002.

Por lo tanto, se cumple la completitud.

### 2. Reconstrucción

Esta regla consiste en poder recuperar todos los registros utilizando los fragmentos.

**Consulta:**

```sql
SELECT COUNT(*)
FROM nodo_actual.pedido_global;
```

**Resultado:** 20,002 registros.

Se recuperó la misma cantidad que tiene la tabla original.

### 3. Disyunción

Esta regla indica que no debe existir el mismo pedido en ambos nodos.

**Consulta:**

```sql
SELECT COUNT(*) AS repetidos
FROM nodo_historico.pedido h
JOIN nodo_actual.pedido a
    ON h.id_pedido = a.id_pedido;
```

**Resultado:** 0 registros repetidos.

Esto confirma que ningún pedido está duplicado entre los nodos.

### 4. Comparación con la tabla original

También comprobamos que los datos distribuidos fueran iguales a los originales.

La consulta de comparación devolvió:

**Diferencias: 0**

Por lo tanto, los datos se copiaron correctamente.

### 5. Protección mediante CHECK

Agregamos restricciones para evitar que se guarden pedidos en el nodo equivocado.

Por ejemplo, un pedido de 2026 no debe poder insertarse en `nodo_historico`.

Para comprobarlo realizamos una prueba de inserción controlada.

**Resultado obtenido:**

`CORRECTO: CHECK RECHAZO EL PEDIDO`

Esto confirma que la restricción funciona.

### Resumen de comprobaciones

| Regla | Resultado | Estado |
|---|---|---|
| Completitud | 20,002 registros | Correcto |
| Reconstrucción | 20,002 registros | Correcto |
| Disyunción | 0 repetidos | Correcto |
| Comparación | 0 diferencias | Correcto |
| Protección CHECK | Pedido rechazado | Correcto |

## Parte 5. Replicación de tablas

Revisamos las demás tablas de nuestra base de datos para decidir cuáles conviene replicar, fragmentar o mantener en un solo nodo.

| Tabla | Decisión | Justificación |
|---|---|---|
| pedido | Fragmentar | Tiene los registros de ventas y los separamos por fecha. |
| categoria | Replicar | Es un catálogo pequeño que puede utilizarse en ambos nodos. |
| rol | Replicar | Contiene información general sobre los tipos de usuario. |
| producto | Replicar | Es información que pueden necesitar los distintos nodos. |
| detalle_pedido | Fragmentar después | Sus registros deben relacionarse con el pedido correspondiente. |
| pago | Mantener central por ahora | Permite conservar el control de los pagos asociados a pedidos. |

Estas decisiones son nuestra propuesta para una distribución posterior; en esta práctica solamente fragmentamos `pedido`.

### ¿Cómo mantenemos iguales las copias?

Cuando se modifique una tabla replicada, debemos actualizar las demás copias para que tengan la misma información.

Podemos utilizar un proceso de sincronización y realizar consultas de comparación para comprobar que los datos sean iguales.

### ¿Cómo evitamos IDs duplicados?

Podemos utilizar identificadores UUID o asignar rangos de números distintos a cada nodo.

En esta práctica conservamos los identificadores originales de los pedidos.

### ¿A qué tablas apuntan las llaves foráneas?

Las llaves foráneas deben apuntar a tablas físicas.

Por ejemplo, los pedidos se relacionan con `cliente` y `direccion`.

En nuestra simulación no copiamos automáticamente esas relaciones a los fragmentos. Si se necesitan después, deberán configurarse hacia tablas físicas existentes o sus réplicas.

No podemos utilizar una vista global como destino de una llave foránea.

## Parte 6. Operación entre nodos

### Operación propuesta

Una operación que podría involucrar nuestros dos nodos es corregir la fecha de un pedido.

Por ejemplo, si un pedido fue registrado con fecha de 2025, pero en realidad corresponde a 2026, debemos moverlo del nodo histórico al nodo actual.

### Sentencias SQL

El siguiente código es una propuesta para el laboratorio de transacciones. 
```sql
BEGIN;

-- Insertar el pedido en el nodo actual
INSERT INTO nodo_actual.pedido (
    id_pedido,
    fecha_pedido,
    estado,
    subtotal,
    costo_envio,
    total,
    id_cliente,
    id_direccion
)
SELECT
    id_pedido,
    '2026-01-01 10:00:00',
    estado,
    subtotal,
    costo_envio,
    total,
    id_cliente,
    id_direccion
FROM nodo_historico.pedido
WHERE id_pedido = 123;

-- Eliminar el registro del nodo histórico
DELETE FROM nodo_historico.pedido
WHERE id_pedido = 123;

-- Revertir la prueba sin guardar cambios
ROLLBACK;
```
