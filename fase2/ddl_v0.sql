-- ============================================================
-- TresD · Seminario AECBD · Equipo 07
-- DDL v0: esquema relacional de tienda en línea de productos 3D
-- Basado en el diccionario de datos de la Fase 1
-- Este script se puede correr las veces que sea necesario.
-- ============================================================

-- ============================================================
-- LIMPIEZA: borra las tablas si ya existen (CASCADE borra FKs)
-- ============================================================
DROP TABLE IF EXISTS
  envio,
  pago,
  detalle_pedido,
  pedido,
  direccion,
  variante_producto,
  producto,
  cliente,
  recuperacion_contrasena,
  usuario,
  categoria,
  rol
CASCADE;

-- ============================================================
-- TABLAS PADRE (no dependen de nadie)
-- ============================================================

CREATE TABLE rol (
    id_rol INTEGER PRIMARY KEY,
    nombre_rol VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE categoria (
    id_categoria INTEGER PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- TABLAS DEPENDIENTES
-- ============================================================

CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    telefono VARCHAR(20),
    estado VARCHAR(15) NOT NULL CHECK (estado IN ('activo','inactivo')),
    id_rol INTEGER NOT NULL REFERENCES rol(id_rol)
);

CREATE TABLE recuperacion_contrasena (
    id_recuperacion INTEGER PRIMARY KEY,
    id_usuario INTEGER NOT NULL REFERENCES usuario(id_usuario),
    token_hash TEXT NOT NULL UNIQUE,
    fecha_expiracion TIMESTAMP NOT NULL,
    fecha_uso TIMESTAMP
);

CREATE TABLE cliente (
    id_cliente INTEGER PRIMARY KEY,
    id_usuario INTEGER NOT NULL UNIQUE REFERENCES usuario(id_usuario)
);

CREATE TABLE producto (
    id_producto INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion TEXT,
    material VARCHAR(30) NOT NULL CHECK (material IN ('PLA','PETG','ABS','TPU')),
    disponible BOOLEAN NOT NULL,
    id_categoria INTEGER NOT NULL REFERENCES categoria(id_categoria)
);

CREATE TABLE variante_producto (
    id_variante INTEGER PRIMARY KEY,
    id_producto INTEGER NOT NULL REFERENCES producto(id_producto),
    color VARCHAR(50) NOT NULL,
    alto_cm NUMERIC(7,2) NOT NULL CHECK (alto_cm > 0),
    ancho_cm NUMERIC(7,2) NOT NULL CHECK (ancho_cm > 0),
    largo_cm NUMERIC(7,2) NOT NULL CHECK (largo_cm > 0),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    disponible BOOLEAN NOT NULL
);

CREATE TABLE direccion (
    id_direccion INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
    calle VARCHAR(150) NOT NULL,
    numero_exterior VARCHAR(15) NOT NULL,
    numero_interior VARCHAR(15),
    colonia VARCHAR(100) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(5) NOT NULL,
    referencias TEXT
);

CREATE TABLE pedido (
    id_pedido INTEGER PRIMARY KEY,
    fecha_pedido TIMESTAMP NOT NULL,
    estado VARCHAR(25) NOT NULL CHECK (estado IN ('pendiente_pago','confirmado','enviado','entregado','cancelado')),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    costo_envio NUMERIC(10,2) NOT NULL CHECK (costo_envio >= 0),
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
    id_direccion INTEGER NOT NULL REFERENCES direccion(id_direccion)
);

CREATE TABLE detalle_pedido (
    id_detalle INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL REFERENCES pedido(id_pedido),
    id_variante INTEGER NOT NULL REFERENCES variante_producto(id_variante),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    color_comprado VARCHAR(50) NOT NULL,
    alto_comprado_cm NUMERIC(7,2) NOT NULL CHECK (alto_comprado_cm > 0),
    ancho_comprado_cm NUMERIC(7,2) NOT NULL CHECK (ancho_comprado_cm > 0),
    largo_comprado_cm NUMERIC(7,2) NOT NULL CHECK (largo_comprado_cm > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0)
);

CREATE TABLE pago (
    id_pago INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL REFERENCES pedido(id_pedido),
    fecha_pago TIMESTAMP,
    metodo_pago VARCHAR(40) NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    referencia VARCHAR(150) UNIQUE,
    estado_pago VARCHAR(20) NOT NULL CHECK (estado_pago IN ('pendiente','aprobado','rechazado','reembolsado'))
);

CREATE TABLE envio (
    id_envio INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL UNIQUE REFERENCES pedido(id_pedido),
    paqueteria VARCHAR(100) NOT NULL,
    numero_guia VARCHAR(100) NOT NULL UNIQUE,
    fecha_envio TIMESTAMP NOT NULL,
    fecha_entrega TIMESTAMP
);