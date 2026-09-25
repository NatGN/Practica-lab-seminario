-- PRACTICA 5 - EQUIPO TRESD
-- Nuevo esquema relacional

-- 1. ROL

CREATE TABLE rol (
    id_rol INTEGER PRIMARY KEY,
    nombre_rol VARCHAR(40) NOT NULL UNIQUE
);

-- 2. CATEGORIA

CREATE TABLE categoria (
    id_categoria INTEGER PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE
);

-- 3. USUARIO

CREATE TABLE usuario (
    id_usuario INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    telefono VARCHAR(20),
    estado VARCHAR(15) NOT NULL,
    id_rol INTEGER NOT NULL REFERENCES rol(id_rol)
);

-- 4. RECUPERACION DE CONTRASENA

CREATE TABLE recuperacion_contrasena (
    id_recuperacion INTEGER PRIMARY KEY,
    id_usuario INTEGER NOT NULL
        REFERENCES usuario(id_usuario),
    token_hash TEXT NOT NULL,
    fecha_expiracion TIMESTAMP NOT NULL,
    fecha_uso TIMESTAMP
);

-- 5. CLIENTE

CREATE TABLE cliente (
    id_cliente INTEGER PRIMARY KEY,
    id_usuario INTEGER NOT NULL UNIQUE
        REFERENCES usuario(id_usuario)
);

-- 6. PRODUCTO

CREATE TABLE producto (
    id_producto INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion TEXT,
    material VARCHAR(30) NOT NULL,
    disponible BOOLEAN NOT NULL,
    id_categoria INTEGER NOT NULL
        REFERENCES categoria(id_categoria)
);

-- 7. VARIANTE DE PRODUCTO

CREATE TABLE variante_producto (
    id_variante INTEGER PRIMARY KEY,
    id_producto INTEGER NOT NULL
        REFERENCES producto(id_producto),
    color VARCHAR(50) NOT NULL,
    alto_cm NUMERIC(7,2) NOT NULL,
    ancho_cm NUMERIC(7,2) NOT NULL,
    largo_cm NUMERIC(7,2) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    disponible BOOLEAN NOT NULL
);

-- 8. DIRECCION

CREATE TABLE direccion (
    id_direccion INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL
        REFERENCES cliente(id_cliente),
    calle VARCHAR(150) NOT NULL,
    numero_exterior VARCHAR(15) NOT NULL,
    numero_interior VARCHAR(15),
    colonia VARCHAR(100) NOT NULL,
    municipio VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(5) NOT NULL,
    referencias TEXT
);

-- 9. PEDIDO

CREATE TABLE pedido (
    id_pedido INTEGER PRIMARY KEY,
    fecha_pedido TIMESTAMP NOT NULL,
    estado VARCHAR(25) NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL,
    costo_envio NUMERIC(10,2) NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    id_cliente INTEGER NOT NULL
        REFERENCES cliente(id_cliente),
    id_direccion INTEGER NOT NULL
        REFERENCES direccion(id_direccion)
);

-- 10. DETALLE DE PEDIDO

CREATE TABLE detalle_pedido (
    id_detalle INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL
        REFERENCES pedido(id_pedido),
    id_variante INTEGER NOT NULL
        REFERENCES variante_producto(id_variante),
    cantidad INTEGER NOT NULL,
    color_comprado VARCHAR(50) NOT NULL,
    alto_comprado_cm NUMERIC(7,2) NOT NULL,
    ancho_comprado_cm NUMERIC(7,2) NOT NULL,
    largo_comprado_cm NUMERIC(7,2) NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL
);

-- 11. PAGO

CREATE TABLE pago (
    id_pago INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL
        REFERENCES pedido(id_pedido),
    fecha_pago TIMESTAMP NOT NULL,
    metodo_pago VARCHAR(40) NOT NULL,
    monto NUMERIC(10,2) NOT NULL,
    referencia VARCHAR(150),
    estado_pago VARCHAR(20) NOT NULL
);

-- 12. ENVIO

CREATE TABLE envio (
    id_envio INTEGER PRIMARY KEY,
    id_pedido INTEGER NOT NULL UNIQUE
        REFERENCES pedido(id_pedido),
    paqueteria VARCHAR(100) NOT NULL,
    numero_guia VARCHAR(100),
    fecha_envio TIMESTAMP,
    fecha_entrega TIMESTAMP
);