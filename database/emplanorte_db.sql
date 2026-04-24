-- ============================================================
--  SCRIPT DE BASE DE DATOS - EMPLANORTE S.A.S.
--  Sistema Web de Gestión Comercial, Inventario y Reportes
--  Motor: PostgreSQL
--  Versión: 1.0
--  Descripción: Script completo con tablas, restricciones,
--               índices, vistas y datos iniciales
-- ============================================================

-- Crear y seleccionar el esquema
\c postgres
drop database if EXISTS emplanorte; 
create database emplanorte; 
\c emplanorte

SET client_encoding = 'UTF8';

/*CREATE SCHEMA IF NOT EXISTS emplanorte;
SET search_path TO emplanorte;*/

-- ============================================================
--  EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================
--  TABLA: usuarios
--  RNF05 - Control de acceso con autenticación
-- ============================================================
CREATE TABLE usuarios (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    correo          VARCHAR(150)    NOT NULL UNIQUE,
    contrasena_hash TEXT            NOT NULL,
    rol             VARCHAR(30)     NOT NULL DEFAULT 'administrador'
                                    CHECK (rol IN ('administrador', 'superadmin')),
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    ultimo_acceso   TIMESTAMP,
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  usuarios                IS 'Usuarios con acceso al sistema (RF: RNF05)';
COMMENT ON COLUMN usuarios.contrasena_hash IS 'Contraseña almacenada con bcrypt';
COMMENT ON COLUMN usuarios.rol             IS 'Rol del usuario dentro del sistema';

-- Datos iniciales: usuarios (10 registros)
INSERT INTO usuarios (nombre, correo, contrasena_hash, rol) VALUES
    ('Administrador EMPLANORTE', 'admin@emplanorte.com',       crypt('Admin2024*', gen_salt('bf', 10)), 'superadmin'),
    ('Carlos Martínez López',    'carlos.martinez@emplanorte.com', crypt('Carlos2024*', gen_salt('bf', 10)), 'administrador'),
    ('María Fernanda Ruiz',      'maria.ruiz@emplanorte.com',      crypt('Maria2024*', gen_salt('bf', 10)),  'administrador'),
    ('Jorge Alberto Peña',       'jorge.pena@emplanorte.com',      crypt('Jorge2024*', gen_salt('bf', 10)),  'administrador'),
    ('Laura Patricia Gómez',     'laura.gomez@emplanorte.com',     crypt('Laura2024*', gen_salt('bf', 10)),  'administrador'),
    ('Andrés Felipe Torres',     'andres.torres@emplanorte.com',   crypt('Andres2024*', gen_salt('bf', 10)), 'administrador'),
    ('Diana Carolina Vargas',    'diana.vargas@emplanorte.com',    crypt('Diana2024*', gen_salt('bf', 10)),  'administrador'),
    ('Pedro Luis Sánchez',       'pedro.sanchez@emplanorte.com',   crypt('Pedro2024*', gen_salt('bf', 10)),  'administrador'),
    ('Natalia Andrea Ríos',      'natalia.rios@emplanorte.com',    crypt('Natalia2024*', gen_salt('bf', 10)),'administrador'),
    ('Sebastián David Castro',   'sebastian.castro@emplanorte.com',crypt('Sebas2024*', gen_salt('bf', 10)),  'superadmin');

\echo ''
\echo '======================================'
\echo '  TABLA: usuarios'
\echo '======================================'
SELECT id, nombre, correo, rol, activo, creado_en FROM usuarios;


-- ============================================================
--  TABLA: categorias_producto
--  RF03 - Tipo de envase / categoría del producto
-- ============================================================
CREATE TABLE categorias_producto (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL UNIQUE,
    descripcion     TEXT,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE categorias_producto IS 'Categorías de los productos del inventario (ej: PET, Ámbar, Aseo)';

-- Datos iniciales: categorias_producto (10 registros)
INSERT INTO categorias_producto (nombre, descripcion) VALUES
    ('Envase PET',            'Envases fabricados en polietileno tereftalato'),
    ('Envase Ámbar',          'Envases de color ámbar para productos sensibles a la luz'),
    ('Envase de Aseo',        'Envases destinados a productos de limpieza y aseo del hogar'),
    ('Envase Plástico',       'Envases plásticos de diferentes capacidades y usos'),
    ('Artículo para Hogar',   'Artículos plásticos de uso doméstico general'),
    ('Envase Farmacéutico',   'Envases especiales para uso farmacéutico y cosméticos'),
    ('Tapa y Cierre',         'Tapas, cierres y accesorios complementarios para envases'),
    ('Envase Industrial',     'Envases de gran capacidad para uso industrial'),
    ('Envase Alimenticio',    'Envases aptos para el contacto directo con alimentos'),
    ('Envase Agroindustrial', 'Envases para productos agrícolas y agroquímicos');

\echo ''
\echo '======================================'
\echo '  TABLA: categorias_producto'
\echo '======================================'
SELECT * FROM categorias_producto;


-- ============================================================
--  TABLA: productos
--  RF01, RF02, RF03, RF04 - Gestión completa de inventario
-- ============================================================
CREATE TABLE productos (
    id                  SERIAL          PRIMARY KEY,
    codigo              VARCHAR(50)     NOT NULL UNIQUE,
    nombre              VARCHAR(150)    NOT NULL,
    descripcion         TEXT,
    id_categoria        INT             NOT NULL REFERENCES categorias_producto(id),
    capacidad_ml        DECIMAL(10,2),
    costo_unitario      DECIMAL(12,2)   NOT NULL CHECK (costo_unitario >= 0),
    precio_venta        DECIMAL(12,2)   NOT NULL CHECK (precio_venta >= 0),
    stock_disponible    INT             NOT NULL DEFAULT 0 CHECK (stock_disponible >= 0),
    stock_minimo        INT             NOT NULL DEFAULT 5  CHECK (stock_minimo >= 0),
    unidad_medida       VARCHAR(30)     NOT NULL DEFAULT 'unidad',
    activo              BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en           TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en      TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  productos                 IS 'Catálogo de productos del inventario (RF01, RF02, RF03, RF04)';
COMMENT ON COLUMN productos.codigo           IS 'Código único del producto para identificación rápida';
COMMENT ON COLUMN productos.costo_unitario   IS 'Costo de compra/producción del producto';
COMMENT ON COLUMN productos.precio_venta     IS 'Precio al que se vende al cliente';
COMMENT ON COLUMN productos.stock_minimo     IS 'Nivel mínimo de stock para alertas de reabastecimiento';

-- Datos iniciales: productos (15 registros)
INSERT INTO productos (codigo, nombre, descripcion, id_categoria, capacidad_ml, costo_unitario, precio_venta, stock_disponible, stock_minimo) VALUES
    ('PET-100',   'Envase PET 100ml',         'Envase PET transparente de 100ml con tapa',        1,   100,   350,   600,  200, 20),
    ('PET-250',   'Envase PET 250ml',         'Envase PET transparente de 250ml con tapa',        1,   250,   500,   850,  150, 15),
    ('PET-500',   'Envase PET 500ml',         'Envase PET transparente de 500ml con tapa',        1,   500,   750,  1200,  180, 15),
    ('PET-1000',  'Envase PET 1000ml',        'Envase PET transparente de 1 litro con tapa',      1,  1000,  1100,  1800,  120, 10),
    ('AMB-100',   'Envase Ámbar 100ml',       'Envase ámbar de 100ml para uso farmacéutico',      2,   100,   600,   950,  100, 10),
    ('AMB-250',   'Envase Ámbar 250ml',       'Envase ámbar de 250ml resistente a la luz',        2,   250,   900,  1400,   80, 10),
    ('ASE-500',   'Envase Aseo 500ml',        'Envase plástico para limpieza 500ml',              3,   500,   650,  1050,  200, 20),
    ('ASE-1000',  'Envase Aseo 1000ml',       'Envase plástico para limpieza 1 litro',            3,  1000,   950,  1550,  160, 15),
    ('PLA-250',   'Envase Plástico 250ml',    'Envase plástico multiuso 250ml',                   4,   250,   400,   700,  250, 25),
    ('PLA-500',   'Envase Plástico 500ml',    'Envase plástico multiuso 500ml',                   4,   500,   620,  1000,  200, 20),
    ('HOG-001',   'Recipiente Hogar 1L',      'Recipiente plástico para el hogar 1 litro',        5,  1000,  1200,  1900,   90, 10),
    ('HOG-002',   'Balde Plástico 5L',        'Balde plástico resistente 5 litros',               5,  5000,  3500,  5500,   60,  8),
    ('FAR-060',   'Envase Farmacéutico 60ml', 'Envase farmacéutico con gotero 60ml',              6,    60,   800,  1300,  120, 15),
    ('IND-5000',  'Bidón Industrial 5L',      'Bidón industrial resistente de 5 litros',          8,  5000,  4500,  7200,   40,  5),
    ('ALI-500',   'Envase Alimenticio 500ml', 'Envase apto para alimentos 500ml con sello',       9,   500,   550,   900,  180, 20);

\echo ''
\echo '======================================'
\echo '  TABLA: productos'
\echo '======================================'
SELECT * FROM productos;


-- ============================================================
--  TABLA: movimientos_inventario
--  RF10 - Registro de todos los movimientos del inventario
-- ============================================================
CREATE TABLE movimientos_inventario (
    id              SERIAL          PRIMARY KEY,
    id_producto     INT             NOT NULL REFERENCES productos(id),
    tipo_movimiento VARCHAR(20)     NOT NULL
                                    CHECK (tipo_movimiento IN ('entrada', 'salida', 'ajuste')),
    cantidad        INT             NOT NULL,
    stock_anterior  INT             NOT NULL,
    stock_nuevo     INT             NOT NULL,
    motivo          VARCHAR(200),
    referencia_id   INT,
    referencia_tipo VARCHAR(50),    -- 'venta', 'ajuste_manual', 'devolucion'
    id_usuario      INT             REFERENCES usuarios(id),
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  movimientos_inventario              IS 'Trazabilidad de todos los movimientos de stock (RF10)';
COMMENT ON COLUMN movimientos_inventario.referencia_id IS 'ID del registro que originó el movimiento (ej: id venta)';

-- Nota: movimientos_inventario se llena automáticamente por el trigger trg_descontar_stock
-- Consulta: se mostrará al final del script cuando ya tenga datos


-- ============================================================
--  TABLA: clientes
--  RF15, RF16 - Gestión de clientes e historial
-- ============================================================
CREATE TABLE clientes (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(150)    NOT NULL,
    tipo_documento  VARCHAR(20)                 CHECK (tipo_documento IN ('CC', 'NIT', 'CE', 'PASAPORTE', 'OTRO')),
    numero_documento VARCHAR(30)    UNIQUE,
    telefono        VARCHAR(20),
    correo          VARCHAR(150),
    direccion       TEXT,
    ciudad          VARCHAR(100),
    observaciones   TEXT,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE clientes IS 'Clientes del negocio con información de contacto (RF15, RF16)';

-- Datos iniciales: clientes (12 registros)
INSERT INTO clientes (nombre, tipo_documento, numero_documento, telefono, correo, direccion, ciudad, observaciones) VALUES
    ('Distribuidora Norte S.A.S.',    'NIT',       '901234567-1', '3101234567', 'ventas@disnorte.com',     'Calle 15 #8-40, Zona Industrial',  'Cúcuta',         'Cliente mayorista principal'),
    ('Farmacia San Rafael',           'NIT',       '800456789-3', '3209876543', 'compras@farmasanrafael.com','Av. 6 #12-30',                   'Cúcuta',         'Compra envases ámbar frecuentemente'),
    ('Juan Esteban Orozco',           'CC',        '1098765432',  '3157891234', 'juan.orozco@gmail.com',    'Cra. 3 #22-15, Barrio Centro',     'Pamplona',       'Cliente recurrente'),
    ('Productos de Aseo La Estrella', 'NIT',       '900876543-2', '3174567890', 'pedidos@laestrella.co',    'Calle 10 #4-55',                   'Cúcuta',         'Pedidos quincenales de envases de aseo'),
    ('Claudia Patricia Mendoza',      'CC',        '37890123',    '3126543210', 'claudia.mendoza@outlook.com','Manzana 5, Casa 12, Los Pinos', 'Villa del Rosario','Compra artículos para el hogar'),
    ('Agrosoluciones del Oriente',    'NIT',       '901567890-8', '3148901234', 'logistica@agrosoluciones.co','Km 5 Vía Ureña',                'Cúcuta',         'Envases agroindustriales'),
    ('Tienda Naturista Vida Sana',    'NIT',       '800321654-7', '3163456789', 'tienda@vidasana.com',      'Calle 8 #5-21, Centro Comercial', 'Ocaña',          'Envases para aceites esenciales'),
    ('Roberto Carlos Duarte',         'CC',        '88234567',    '3112345678', 'roberto.duarte@hotmail.com','Av. 4 #9-18',                    'Pamplona',       'Compras esporádicas'),
    ('Cosméticos Bella Piel Ltda.',   'NIT',       '900234567-5', '3185678901', 'compras@bellapiel.com.co', 'Cra. 9 #16-45, Zona Industrial',  'Cúcuta',         'Envases para cremas y lociones'),
    ('Marcela Viviana Contreras',     'CC',        '1090456789',  '3196789012', 'marcela.contreras@gmail.com','Barrio La Libertad, Calle 20',  'Villa del Rosario','Cliente nueva, referida por Farmacia San Rafael'),
    ('Industrias Plásticas del Norte','NIT',       '901890123-4', '3207890123', 'info@iplasticas.com',      'Zona Franca, Bodega 14',           'Cúcuta',         'Compra al por mayor'),
    ('Supermercado El Ahorro',        'NIT',       '800567123-9', '3138901234', 'pedidos@elahorro.com',     'Calle 12 #7-30',                   'Cúcuta',         'Envases alimenticios y artículos hogar');

\echo ''
\echo '======================================'
\echo '  TABLA: clientes'
\echo '======================================'
SELECT * FROM clientes;


-- ============================================================
--  TABLA: ventas
--  RF05, RF07, RF08, RF09, RF10 - Registro de ventas
-- ============================================================
CREATE TABLE ventas (
    id                  SERIAL          PRIMARY KEY,
    numero_venta        VARCHAR(20)     NOT NULL UNIQUE,
    id_cliente          INT             REFERENCES clientes(id),
    id_usuario          INT             NOT NULL REFERENCES usuarios(id),
    fecha_venta         TIMESTAMP       NOT NULL DEFAULT NOW(),
    subtotal            DECIMAL(14,2)   NOT NULL DEFAULT 0,
    descuento           DECIMAL(14,2)   NOT NULL DEFAULT 0 CHECK (descuento >= 0),
    total               DECIMAL(14,2)   NOT NULL DEFAULT 0,
    total_costo         DECIMAL(14,2)   NOT NULL DEFAULT 0,
    ganancia            DECIMAL(14,2)   NOT NULL DEFAULT 0,
    metodo_pago         VARCHAR(30)     NOT NULL
                                        CHECK (metodo_pago IN ('efectivo', 'transferencia', 'tarjeta', 'otro')),
    estado              VARCHAR(20)     NOT NULL DEFAULT 'completada'
                                        CHECK (estado IN ('completada', 'anulada', 'pendiente')),
    observaciones       TEXT,
    origen              VARCHAR(20)     DEFAULT 'directa'
                                        CHECK (origen IN ('directa', 'cotizacion')),
    id_cotizacion       INT,            -- FK se agrega después de crear la tabla cotizaciones
    creado_en           TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en      TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  ventas              IS 'Registro maestro de ventas (RF05, RF07, RF08, RF09, RF10)';
COMMENT ON COLUMN ventas.numero_venta  IS 'Número consecutivo de venta (ej: VTA-000001)';
COMMENT ON COLUMN ventas.ganancia      IS 'Calculado como: total - total_costo';
COMMENT ON COLUMN ventas.origen        IS 'Indica si la venta viene de cotización o es directa';

-- Nota: Los INSERTs de ventas van después de los triggers (ver sección DATOS CON TRIGGERS)


-- ============================================================
--  TABLA: detalle_ventas
--  RF06, RF07, RF08 - Líneas de productos por venta
-- ============================================================
CREATE TABLE detalle_ventas (
    id                  SERIAL          PRIMARY KEY,
    id_venta            INT             NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    id_producto         INT             NOT NULL REFERENCES productos(id),
    cantidad            INT             NOT NULL CHECK (cantidad > 0),
    precio_unitario     DECIMAL(12,2)   NOT NULL CHECK (precio_unitario >= 0),
    costo_unitario      DECIMAL(12,2)   NOT NULL CHECK (costo_unitario >= 0),
    descuento_linea     DECIMAL(12,2)   NOT NULL DEFAULT 0,
    subtotal_linea      DECIMAL(14,2)   NOT NULL,
    costo_linea         DECIMAL(14,2)   NOT NULL,
    ganancia_linea      DECIMAL(14,2)   NOT NULL,
    creado_en           TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  detalle_ventas                IS 'Líneas de producto de cada venta (RF06, RF07, RF08)';
COMMENT ON COLUMN detalle_ventas.subtotal_linea  IS 'precio_unitario * cantidad - descuento_linea';
COMMENT ON COLUMN detalle_ventas.ganancia_linea  IS 'subtotal_linea - costo_linea';

-- Nota: Los INSERTs de detalle_ventas van después de los triggers (ver sección DATOS CON TRIGGERS)


-- ============================================================
--  TABLA: categorias_gasto
--  RF12 - Categorías para clasificar gastos
-- ============================================================
CREATE TABLE categorias_gasto (
    id              SERIAL          PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL UNIQUE,
    descripcion     TEXT,
    activo          BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE categorias_gasto IS 'Categorías para clasificar los gastos del negocio (RF12)';

-- Datos iniciales: categorias_gasto (10 registros)
INSERT INTO categorias_gasto (nombre, descripcion) VALUES
    ('Transporte',          'Gastos de envío, fletes y transporte de mercancía'),
    ('Arriendo',            'Pago de arriendo de bodega u oficinas'),
    ('Servicios públicos',  'Agua, luz, internet y otros servicios'),
    ('Compra de mercancía', 'Adquisición de productos para inventario'),
    ('Nómina',              'Pago de salarios y prestaciones'),
    ('Marketing',           'Publicidad y promoción del negocio'),
    ('Mantenimiento',       'Reparaciones y mantenimiento de equipos o instalaciones'),
    ('Papelería',           'Materiales de oficina e impresión'),
    ('Seguros',             'Pólizas de seguros del negocio y empleados'),
    ('Otros',               'Gastos varios no clasificados');

\echo ''
\echo '======================================'
\echo '  TABLA: categorias_gasto'
\echo '======================================'
SELECT * FROM categorias_gasto;


-- ============================================================
--  TABLA: gastos
--  RF11, RF12, RF13 - Registro de gastos del negocio
-- ============================================================
CREATE TABLE gastos (
    id              SERIAL          PRIMARY KEY,
    id_categoria    INT             NOT NULL REFERENCES categorias_gasto(id),
    id_usuario      INT             NOT NULL REFERENCES usuarios(id),
    descripcion     VARCHAR(250)    NOT NULL,
    valor           DECIMAL(14,2)   NOT NULL CHECK (valor > 0),
    fecha_gasto     DATE            NOT NULL DEFAULT CURRENT_DATE,
    comprobante     VARCHAR(200),   -- ruta o referencia del comprobante
    observaciones   TEXT,
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en  TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  gastos            IS 'Gastos operativos del negocio (RF11, RF12, RF13)';
COMMENT ON COLUMN gastos.comprobante IS 'Referencia o nombre del archivo de soporte del gasto';

-- Nota: Los INSERTs de gastos van después de los triggers (ver sección DATOS CON TRIGGERS)


-- ============================================================
--  TABLA: cotizaciones
--  RF17, RF18 - Generación y conversión de cotizaciones
-- ============================================================
CREATE TABLE cotizaciones (
    id                  SERIAL          PRIMARY KEY,
    numero_cotizacion   VARCHAR(20)     NOT NULL UNIQUE,
    id_cliente          INT             NOT NULL REFERENCES clientes(id),
    id_usuario          INT             NOT NULL REFERENCES usuarios(id),
    fecha_cotizacion    TIMESTAMP       NOT NULL DEFAULT NOW(),
    fecha_vencimiento   DATE,
    subtotal            DECIMAL(14,2)   NOT NULL DEFAULT 0,
    descuento           DECIMAL(14,2)   NOT NULL DEFAULT 0,
    total               DECIMAL(14,2)   NOT NULL DEFAULT 0,
    estado              VARCHAR(20)     NOT NULL DEFAULT 'pendiente'
                                        CHECK (estado IN ('pendiente', 'aceptada', 'rechazada', 'vencida', 'convertida')),
    notas               TEXT,
    creado_en           TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en      TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  cotizaciones                    IS 'Cotizaciones generadas para clientes (RF17, RF18)';
COMMENT ON COLUMN cotizaciones.numero_cotizacion   IS 'Consecutivo de cotización (ej: COT-000001)';
COMMENT ON COLUMN cotizaciones.estado              IS 'pendiente: sin respuesta | convertida: ya se transformó en venta';

-- Datos iniciales: cotizaciones (10 registros)
INSERT INTO cotizaciones (numero_cotizacion, id_cliente, id_usuario, fecha_cotizacion, fecha_vencimiento, subtotal, descuento, total, estado, notas) VALUES
    ('COT-000001', 1,  2, '2026-03-01 09:00:00', '2026-03-15', 180000.00, 5000.00, 175000.00, 'convertida', 'Cotización para pedido trimestral de envases PET'),
    ('COT-000002', 2,  3, '2026-03-03 10:30:00', '2026-03-17', 95000.00,     0.00,  95000.00, 'convertida', 'Envases ámbar para nueva línea farmacéutica'),
    ('COT-000003', 4,  2, '2026-03-05 14:00:00', '2026-03-19', 126000.00, 6000.00, 120000.00, 'convertida', 'Envases de aseo para promoción quincenal'),
    ('COT-000004', 6,  4, '2026-03-08 08:45:00', '2026-03-22', 288000.00,    0.00, 288000.00, 'pendiente',  'Bidones industriales para temporada agrícola'),
    ('COT-000005', 9,  3, '2026-03-10 11:00:00', '2026-03-24', 78000.00,  3000.00,  75000.00, 'aceptada',   'Envases para cremas faciales'),
    ('COT-000006', 7,  5, '2026-03-12 15:20:00', '2026-03-26', 52000.00,     0.00,  52000.00, 'convertida', 'Envases farmacéuticos para aceites'),
    ('COT-000007', 11, 2, '2026-03-15 09:30:00', '2026-03-29', 540000.00,20000.00, 520000.00, 'pendiente',  'Pedido mayorista trimestral'),
    ('COT-000008', 3,  6, '2026-03-18 10:00:00', '2026-04-01',  14000.00,    0.00,  14000.00, 'rechazada',  'Envases plásticos multiuso'),
    ('COT-000009', 12, 4, '2026-03-20 16:00:00', '2026-04-03', 162000.00, 7000.00, 155000.00, 'convertida', 'Envases alimenticios para nueva sucursal'),
    ('COT-000010', 5,  3, '2026-03-25 13:15:00', '2026-04-08',  38000.00,    0.00,  38000.00, 'vencida',    'Artículos hogar varios');

\echo ''
\echo '======================================'
\echo '  TABLA: cotizaciones'
\echo '======================================'
SELECT * FROM cotizaciones;


-- ============================================================
--  TABLA: detalle_cotizaciones
--  RF17 - Líneas de producto por cotización
-- ============================================================
CREATE TABLE detalle_cotizaciones (
    id                  SERIAL          PRIMARY KEY,
    id_cotizacion       INT             NOT NULL REFERENCES cotizaciones(id) ON DELETE CASCADE,
    id_producto         INT             NOT NULL REFERENCES productos(id),
    cantidad            INT             NOT NULL CHECK (cantidad > 0),
    precio_unitario     DECIMAL(12,2)   NOT NULL CHECK (precio_unitario >= 0),
    descuento_linea     DECIMAL(12,2)   NOT NULL DEFAULT 0,
    subtotal_linea      DECIMAL(14,2)   NOT NULL,
    creado_en           TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE detalle_cotizaciones IS 'Líneas de producto de cada cotización (RF17)';

-- Datos iniciales: detalle_cotizaciones (15 registros)
INSERT INTO detalle_cotizaciones (id_cotizacion, id_producto, cantidad, precio_unitario, descuento_linea, subtotal_linea) VALUES
    (1,  1, 100,  600.00,  0.00,  60000.00),
    (1,  2,  80,  850.00,  0.00,  68000.00),
    (1,  3,  40, 1200.00,  0.00,  48000.00),
    (2,  5,  50,  950.00,  0.00,  47500.00),
    (2,  6,  34, 1400.00,  0.00,  47600.00),
    (3,  7,  60, 1050.00,  0.00,  63000.00),
    (3,  8,  40, 1550.00,  0.00,  62000.00),
    (4, 14,  40, 7200.00,  0.00, 288000.00),
    (5, 13,  60, 1300.00,  0.00,  78000.00),
    (6, 13,  40, 1300.00,  0.00,  52000.00),
    (7,  1, 200,  600.00,  0.00, 120000.00),
    (7,  2, 150,  850.00,  0.00, 127500.00),
    (8,  9,  20,  700.00,  0.00,  14000.00),
    (9, 15, 180,  900.00,  0.00, 162000.00),
    (10,11,  20, 1900.00,  0.00,  38000.00);

\echo ''
\echo '======================================'
\echo '  TABLA: detalle_cotizaciones'
\echo '======================================'
SELECT * FROM detalle_cotizaciones;


-- ============================================================
--  FK DIFERIDA: ventas.id_cotizacion → cotizaciones.id
--  RF18 - Trazabilidad de conversión cotización → venta
-- ============================================================
ALTER TABLE ventas
    ADD CONSTRAINT fk_ventas_cotizacion
    FOREIGN KEY (id_cotizacion) REFERENCES cotizaciones(id);


-- ============================================================
--  TABLA: resumen_diario
--  RF13 - Resumen financiero diario (caché de estadísticas)
-- ============================================================
CREATE TABLE resumen_diario (
    id              SERIAL          PRIMARY KEY,
    fecha           DATE            NOT NULL UNIQUE,
    total_ventas    DECIMAL(14,2)   NOT NULL DEFAULT 0,
    total_gastos    DECIMAL(14,2)   NOT NULL DEFAULT 0,
    total_ganancias DECIMAL(14,2)   NOT NULL DEFAULT 0,
    num_ventas      INT             NOT NULL DEFAULT 0,
    num_gastos      INT             NOT NULL DEFAULT 0,
    actualizado_en  TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE resumen_diario IS 'Caché del resumen financiero por día para consultas rápidas (RF13)';

-- Nota: resumen_diario se llena automáticamente por los triggers de ventas y gastos


-- ============================================================
--  TABLA: sesiones_usuario
--  RNF05 - Auditoría de accesos al sistema
-- ============================================================
CREATE TABLE sesiones_usuario (
    id              SERIAL          PRIMARY KEY,
    id_usuario      INT             NOT NULL REFERENCES usuarios(id),
    token           TEXT            NOT NULL,
    ip_acceso       VARCHAR(45),
    dispositivo     TEXT,
    fecha_inicio    TIMESTAMP       NOT NULL DEFAULT NOW(),
    fecha_expiracion TIMESTAMP      NOT NULL,
    activa          BOOLEAN         NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE sesiones_usuario IS 'Control de sesiones activas por usuario (RNF05)';

-- Datos iniciales: sesiones_usuario (10 registros)
INSERT INTO sesiones_usuario (id_usuario, token, ip_acceso, dispositivo, fecha_inicio, fecha_expiracion, activa) VALUES
    (1, 'tok_a1b2c3d4e5f6g7h8i9j0k1l2m3n4', '192.168.1.10',  'Chrome 120 / Windows 11',    '2026-04-10 07:00:00', '2026-04-10 19:00:00', TRUE),
    (2, 'tok_b2c3d4e5f6g7h8i9j0k1l2m3n4o5', '192.168.1.15',  'Chrome 120 / Windows 10',    '2026-04-10 07:30:00', '2026-04-10 19:30:00', TRUE),
    (3, 'tok_c3d4e5f6g7h8i9j0k1l2m3n4o5p6', '192.168.1.20',  'Firefox 122 / Ubuntu 24.04', '2026-04-10 08:00:00', '2026-04-10 20:00:00', TRUE),
    (4, 'tok_d4e5f6g7h8i9j0k1l2m3n4o5p6q7', '10.0.0.51',     'Safari 17 / macOS Sonoma',   '2026-04-09 09:00:00', '2026-04-09 21:00:00', FALSE),
    (5, 'tok_e5f6g7h8i9j0k1l2m3n4o5p6q7r8', '192.168.1.30',  'Edge 120 / Windows 11',      '2026-04-10 08:15:00', '2026-04-10 20:15:00', TRUE),
    (1, 'tok_f6g7h8i9j0k1l2m3n4o5p6q7r8s9', '200.93.45.12',  'Chrome 120 / Android 14',    '2026-04-09 12:00:00', '2026-04-09 18:00:00', FALSE),
    (6, 'tok_g7h8i9j0k1l2m3n4o5p6q7r8s9t0', '192.168.1.40',  'Chrome 120 / Windows 10',    '2026-04-10 09:00:00', '2026-04-10 21:00:00', TRUE),
    (2, 'tok_h8i9j0k1l2m3n4o5p6q7r8s9t0u1', '10.0.0.55',     'Firefox 122 / Windows 11',   '2026-04-08 08:00:00', '2026-04-08 20:00:00', FALSE),
    (7, 'tok_i9j0k1l2m3n4o5p6q7r8s9t0u1v2', '192.168.1.50',  'Chrome 120 / Windows 10',    '2026-04-10 07:45:00', '2026-04-10 19:45:00', TRUE),
    (10,'tok_j0k1l2m3n4o5p6q7r8s9t0u1v2w3', '192.168.1.100', 'Chrome 120 / Windows 11',    '2026-04-10 08:30:00', '2026-04-10 20:30:00', TRUE);

\echo ''
\echo '======================================'
\echo '  TABLA: sesiones_usuario'
\echo '======================================'
SELECT * FROM sesiones_usuario;


-- ============================================================
--  TABLA: auditoria
--  RNF03, RNF06 - Trazabilidad de cambios críticos
-- ============================================================
CREATE TABLE auditoria (
    id              SERIAL          PRIMARY KEY,
    tabla_afectada  VARCHAR(80)     NOT NULL,
    operacion       VARCHAR(10)     NOT NULL CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    id_registro     INT,
    datos_anteriores TEXT,
    datos_nuevos    TEXT,
    id_usuario      INT             REFERENCES usuarios(id),
    ip_acceso       VARCHAR(45),
    creado_en       TIMESTAMP       NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE auditoria IS 'Registro de auditoría de cambios críticos en el sistema (RNF03, RNF06)';

-- Datos iniciales: auditoria (12 registros)
INSERT INTO auditoria (tabla_afectada, operacion, id_registro, datos_anteriores, datos_nuevos, id_usuario, ip_acceso) VALUES
    ('productos',   'INSERT', 1,  NULL, 'codigo=PET-100, nombre=Envase PET 100ml, stock_disponible=200', 1, '192.168.1.10'),
    ('productos',   'INSERT', 2,  NULL, 'codigo=PET-250, nombre=Envase PET 250ml, stock_disponible=150', 1, '192.168.1.10'),
    ('productos',   'UPDATE', 1,  'precio_venta=550', 'precio_venta=600', 2, '192.168.1.15'),
    ('clientes',    'INSERT', 1,  NULL, 'nombre=Distribuidora Norte S.A.S., nit=901234567-1', 2, '192.168.1.15'),
    ('clientes',    'INSERT', 2,  NULL, 'nombre=Farmacia San Rafael, nit=800456789-3', 3, '192.168.1.20'),
    ('ventas',      'INSERT', 1,  NULL, 'numero_venta=VTA-000001, total=175000', 2, '192.168.1.15'),
    ('ventas',      'INSERT', 2,  NULL, 'numero_venta=VTA-000002, total=95000', 3, '192.168.1.20'),
    ('usuarios',    'UPDATE', 3,  'ultimo_acceso=null', 'ultimo_acceso=2026-03-04', 3, '192.168.1.20'),
    ('productos',   'UPDATE', 7,  'stock_disponible=200', 'stock_disponible=140', 2, '192.168.1.15'),
    ('gastos',      'INSERT', 1,  NULL, 'descripcion=Flete envio mercancia a Ocana, valor=250000', 1, '192.168.1.10'),
    ('cotizaciones','INSERT', 1,  NULL, 'numero_cotizacion=COT-000001, total=175000', 2, '192.168.1.15'),
    ('cotizaciones','UPDATE', 1,  'estado=pendiente', 'estado=convertida', 2, '192.168.1.15');

\echo ''
\echo '======================================'
\echo '  TABLA: auditoria'
\echo '======================================'
SELECT * FROM auditoria;


-- ============================================================
--  ÍNDICES - Optimización de consultas frecuentes (RNF04)
-- ============================================================

-- Productos
CREATE INDEX idx_productos_categoria    ON productos(id_categoria);
CREATE INDEX idx_productos_activo       ON productos(activo);
CREATE INDEX idx_productos_nombre       ON productos USING gin(to_tsvector('spanish', nombre));

-- Ventas
CREATE INDEX idx_ventas_fecha           ON ventas(fecha_venta);
CREATE INDEX idx_ventas_cliente         ON ventas(id_cliente);
CREATE INDEX idx_ventas_usuario         ON ventas(id_usuario);
CREATE INDEX idx_ventas_estado          ON ventas(estado);

-- Detalle ventas
CREATE INDEX idx_detalle_ventas_venta   ON detalle_ventas(id_venta);
CREATE INDEX idx_detalle_ventas_prod    ON detalle_ventas(id_producto);

-- Gastos
CREATE INDEX idx_gastos_fecha           ON gastos(fecha_gasto);
CREATE INDEX idx_gastos_categoria       ON gastos(id_categoria);

-- Cotizaciones
CREATE INDEX idx_cotizaciones_cliente   ON cotizaciones(id_cliente);
CREATE INDEX idx_cotizaciones_estado    ON cotizaciones(estado);
CREATE INDEX idx_cotizaciones_fecha     ON cotizaciones(fecha_cotizacion);

-- Movimientos inventario
CREATE INDEX idx_mov_inventario_prod    ON movimientos_inventario(id_producto);
CREATE INDEX idx_mov_inventario_fecha   ON movimientos_inventario(creado_en);

-- Auditoría
CREATE INDEX idx_auditoria_tabla        ON auditoria(tabla_afectada);
CREATE INDEX idx_auditoria_fecha        ON auditoria(creado_en);

-- Resumen diario
CREATE INDEX idx_resumen_fecha          ON resumen_diario(fecha);


-- ============================================================
--  VISTAS - Consultas frecuentes prearmadas (RF13, RF14, RF19, RF20)
-- ============================================================

-- Vista: inventario completo con categoría
CREATE OR REPLACE VIEW v_inventario AS
SELECT
    p.id,
    p.codigo,
    p.nombre,
    c.nombre           AS categoria,
    p.capacidad_ml,
    p.costo_unitario,
    p.precio_venta,
    ROUND(p.precio_venta - p.costo_unitario, 2)                     AS margen_unitario,
    ROUND(((p.precio_venta - p.costo_unitario) / NULLIF(p.precio_venta, 0)) * 100, 2) AS margen_porcentual,
    p.stock_disponible,
    p.stock_minimo,
    CASE WHEN p.stock_disponible <= p.stock_minimo THEN TRUE ELSE FALSE END AS alerta_stock,
    p.unidad_medida,
    p.activo
FROM productos p
JOIN categorias_producto c ON c.id = p.id_categoria;

COMMENT ON VIEW v_inventario IS 'Vista completa del inventario con márgenes y alertas de stock (RF20)';


-- Vista: ventas con detalle de cliente y usuario
CREATE OR REPLACE VIEW v_ventas AS
SELECT
    v.id,
    v.numero_venta,
    v.fecha_venta,
    COALESCE(cl.nombre, 'Cliente general') AS cliente,
    u.nombre            AS vendedor,
    v.subtotal,
    v.descuento,
    v.total,
    v.total_costo,
    v.ganancia,
    v.metodo_pago,
    v.estado,
    v.origen
FROM ventas v
JOIN usuarios u  ON u.id  = v.id_usuario
LEFT JOIN clientes cl ON cl.id = v.id_cliente;

COMMENT ON VIEW v_ventas IS 'Vista enriquecida de ventas con cliente y vendedor (RF19)';


-- Vista: resumen financiero por día (RF13)
CREATE OR REPLACE VIEW v_resumen_financiero_diario AS
SELECT
    DATE(v.fecha_venta)             AS fecha,
    COUNT(v.id)                     AS num_ventas,
    COALESCE(SUM(v.total), 0)       AS total_ventas,
    COALESCE(SUM(v.ganancia), 0)    AS total_ganancias,
    COALESCE(g.total_gastos, 0)     AS total_gastos,
    COALESCE(SUM(v.ganancia), 0) - COALESCE(g.total_gastos, 0) AS utilidad_neta
FROM ventas v
LEFT JOIN (
    SELECT fecha_gasto, SUM(valor) AS total_gastos
    FROM gastos
    GROUP BY fecha_gasto
) g ON g.fecha_gasto = DATE(v.fecha_venta)
WHERE v.estado = 'completada'
GROUP BY DATE(v.fecha_venta), g.total_gastos
ORDER BY fecha DESC;

COMMENT ON VIEW v_resumen_financiero_diario IS 'Resumen financiero diario de ventas, gastos y ganancias (RF13)';


-- Vista: productos más vendidos (RF14, RF19)
CREATE OR REPLACE VIEW v_productos_mas_vendidos AS
SELECT
    p.id,
    p.codigo,
    p.nombre,
    c.nombre            AS categoria,
    SUM(dv.cantidad)    AS total_unidades_vendidas,
    SUM(dv.subtotal_linea) AS total_ingresos,
    SUM(dv.ganancia_linea) AS total_ganancias,
    COUNT(DISTINCT dv.id_venta) AS num_ventas
FROM detalle_ventas dv
JOIN productos p  ON p.id  = dv.id_producto
JOIN categorias_producto c ON c.id = p.id_categoria
JOIN ventas v     ON v.id  = dv.id_venta AND v.estado = 'completada'
GROUP BY p.id, p.codigo, p.nombre, c.nombre
ORDER BY total_unidades_vendidas DESC;

COMMENT ON VIEW v_productos_mas_vendidos IS 'Ranking de productos por unidades vendidas (RF14, RF19)';


-- Vista: historial de compras por cliente (RF16)
CREATE OR REPLACE VIEW v_historial_clientes AS
SELECT
    cl.id               AS id_cliente,
    cl.nombre           AS cliente,
    cl.telefono,
    v.id                AS id_venta,
    v.numero_venta,
    v.fecha_venta,
    v.total,
    v.ganancia,
    v.metodo_pago,
    v.estado
FROM clientes cl
JOIN ventas v ON v.id_cliente = cl.id
ORDER BY cl.id, v.fecha_venta DESC;

COMMENT ON VIEW v_historial_clientes IS 'Historial completo de compras por cliente (RF16)';


-- Vista: gastos por categoría y período (RF11, RF12)
CREATE OR REPLACE VIEW v_gastos_por_categoria AS
SELECT
    cg.nombre           AS categoria,
    DATE_TRUNC('month', g.fecha_gasto::TIMESTAMP) AS mes,
    COUNT(g.id)         AS num_gastos,
    SUM(g.valor)        AS total_gastado
FROM gastos g
JOIN categorias_gasto cg ON cg.id = g.id_categoria
GROUP BY cg.nombre, DATE_TRUNC('month', g.fecha_gasto::TIMESTAMP)
ORDER BY mes DESC, total_gastado DESC;

COMMENT ON VIEW v_gastos_por_categoria IS 'Resumen de gastos agrupados por categoría y mes (RF11, RF12)';


-- Vista: cotizaciones con estado y cliente (RF17, RF18)
CREATE OR REPLACE VIEW v_cotizaciones AS
SELECT
    co.id,
    co.numero_cotizacion,
    cl.nombre           AS cliente,
    cl.telefono,
    co.fecha_cotizacion,
    co.fecha_vencimiento,
    co.total,
    co.estado,
    u.nombre            AS creado_por,
    v.numero_venta      AS venta_generada
FROM cotizaciones co
JOIN clientes cl    ON cl.id = co.id_cliente
JOIN usuarios u     ON u.id  = co.id_usuario
LEFT JOIN ventas v  ON v.id_cotizacion = co.id;

COMMENT ON VIEW v_cotizaciones IS 'Vista de cotizaciones con estado y venta asociada (RF17, RF18)';


-- ============================================================
--  FUNCIONES Y TRIGGERS
-- ============================================================

-- Función: actualizar campo 'actualizado_en' automáticamente
CREATE OR REPLACE FUNCTION fn_actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de timestamp
CREATE TRIGGER trg_productos_ts
    BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_ventas_ts
    BEFORE UPDATE ON ventas
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_clientes_ts
    BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_gastos_ts
    BEFORE UPDATE ON gastos
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER trg_cotizaciones_ts
    BEFORE UPDATE ON cotizaciones
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();


-- Función: descontar stock al registrar una venta (RF10)
CREATE OR REPLACE FUNCTION fn_descontar_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_anterior INT;
    v_stock_nuevo    INT;
BEGIN
    -- Obtener stock actual
    SELECT stock_disponible INTO v_stock_anterior
    FROM productos WHERE id = NEW.id_producto;

    -- Validar stock suficiente
    IF v_stock_anterior < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto id=%. Disponible: %, Solicitado: %',
            NEW.id_producto, v_stock_anterior, NEW.cantidad;
    END IF;

    v_stock_nuevo := v_stock_anterior - NEW.cantidad;

    -- Actualizar stock
    UPDATE productos
    SET stock_disponible = v_stock_nuevo
    WHERE id = NEW.id_producto;

    -- Registrar movimiento de inventario
    INSERT INTO movimientos_inventario (
        id_producto, tipo_movimiento, cantidad,
        stock_anterior, stock_nuevo, motivo,
        referencia_id, referencia_tipo
    ) VALUES (
        NEW.id_producto, 'salida', NEW.cantidad,
        v_stock_anterior, v_stock_nuevo,
        'Salida por venta',
        NEW.id_venta, 'venta'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock
    AFTER INSERT ON detalle_ventas
    FOR EACH ROW EXECUTE FUNCTION fn_descontar_stock();


-- Función: actualizar resumen diario automáticamente (RF13)
CREATE OR REPLACE FUNCTION fn_actualizar_resumen_diario()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha DATE;
    v_total_ventas    DECIMAL(14,2);
    v_total_ganancias DECIMAL(14,2);
    v_num_ventas      INT;
BEGIN
    v_fecha := DATE(COALESCE(NEW.fecha_venta, OLD.fecha_venta));

    SELECT
        COALESCE(SUM(total), 0),
        COALESCE(SUM(ganancia), 0),
        COUNT(*)
    INTO v_total_ventas, v_total_ganancias, v_num_ventas
    FROM ventas
    WHERE DATE(fecha_venta) = v_fecha AND estado = 'completada';

    INSERT INTO resumen_diario (fecha, total_ventas, total_ganancias, num_ventas)
    VALUES (v_fecha, v_total_ventas, v_total_ganancias, v_num_ventas)
    ON CONFLICT (fecha) DO UPDATE
        SET total_ventas    = EXCLUDED.total_ventas,
            total_ganancias = EXCLUDED.total_ganancias,
            num_ventas      = EXCLUDED.num_ventas,
            actualizado_en  = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_resumen_diario_venta
    AFTER INSERT OR UPDATE ON ventas
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_resumen_diario();


-- Función: actualizar resumen diario con gastos (RF13)
CREATE OR REPLACE FUNCTION fn_actualizar_resumen_gastos()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha        DATE;
    v_total_gastos DECIMAL(14,2);
    v_num_gastos   INT;
BEGIN
    v_fecha := COALESCE(NEW.fecha_gasto, OLD.fecha_gasto);

    SELECT COALESCE(SUM(valor), 0), COUNT(*)
    INTO v_total_gastos, v_num_gastos
    FROM gastos
    WHERE fecha_gasto = v_fecha;

    INSERT INTO resumen_diario (fecha, total_gastos, num_gastos)
    VALUES (v_fecha, v_total_gastos, v_num_gastos)
    ON CONFLICT (fecha) DO UPDATE
        SET total_gastos   = EXCLUDED.total_gastos,
            num_gastos     = EXCLUDED.num_gastos,
            actualizado_en = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_resumen_diario_gasto
    AFTER INSERT OR UPDATE OR DELETE ON gastos
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_resumen_gastos();


-- Función: marcar cotización como 'convertida' al generar venta (RF18)
CREATE OR REPLACE FUNCTION fn_marcar_cotizacion_convertida()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_cotizacion IS NOT NULL THEN
        UPDATE cotizaciones
        SET estado = 'convertida', actualizado_en = NOW()
        WHERE id = NEW.id_cotizacion;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_convertir_cotizacion
    AFTER INSERT ON ventas
    FOR EACH ROW EXECUTE FUNCTION fn_marcar_cotizacion_convertida();


-- ============================================================
--  DATOS CON TRIGGERS ACTIVOS
--  Los siguientes INSERTs se ejecutan después de crear los triggers
--  para que se activen automáticamente (descuento de stock,
--  resumen diario, conversión de cotizaciones)
-- ============================================================

-- Datos iniciales: ventas (10 registros)
-- Nota: el trigger trg_resumen_diario_venta actualiza resumen_diario
-- Nota: el trigger trg_convertir_cotizacion marca cotizaciones como convertidas
INSERT INTO ventas (numero_venta, id_cliente, id_usuario, fecha_venta, subtotal, descuento, total, total_costo, ganancia, metodo_pago, estado, observaciones, origen, id_cotizacion) VALUES
    ('VTA-000001', 1,  2, '2026-03-02 10:15:00', 180000.00,  5000.00, 175000.00, 105000.00,  70000.00, 'transferencia', 'completada', 'Pedido trimestral envases PET',              'cotizacion', 1),
    ('VTA-000002', 2,  3, '2026-03-04 11:00:00',  95000.00,     0.00,  95000.00,  60000.00,  35000.00, 'transferencia', 'completada', 'Envases ámbar para farmacia',                'cotizacion', 2),
    ('VTA-000003', 4,  2, '2026-03-06 09:30:00', 126000.00,  6000.00, 120000.00,  78000.00,  42000.00, 'efectivo',      'completada', 'Envases de aseo quincenal',                  'cotizacion', 3),
    ('VTA-000004', 3,  6, '2026-03-10 14:00:00',  17500.00,     0.00,  17500.00,  10000.00,   7500.00, 'efectivo',      'completada', 'Compra de envases varios',                   'directa',    NULL),
    ('VTA-000005', 7,  5, '2026-03-13 15:30:00',  52000.00,     0.00,  52000.00,  32000.00,  20000.00, 'transferencia', 'completada', 'Envases farmacéuticos para aceites',          'cotizacion', 6),
    ('VTA-000006', 5,  3, '2026-03-16 10:45:00',  38000.00,  2000.00,  36000.00,  24000.00,  12000.00, 'tarjeta',       'completada', 'Artículos plásticos para el hogar',           'directa',    NULL),
    ('VTA-000007', 12, 4, '2026-03-21 09:00:00', 162000.00,  7000.00, 155000.00,  99000.00,  56000.00, 'transferencia', 'completada', 'Envases alimenticios nueva sucursal',         'cotizacion', 9),
    ('VTA-000008', 8,  2, '2026-03-25 16:20:00',  12000.00,     0.00,  12000.00,   7500.00,   4500.00, 'efectivo',      'completada', 'Compra menor de envases plásticos',           'directa',    NULL),
    ('VTA-000009', 10, 3, '2026-03-28 11:30:00',  26000.00,  1000.00,  25000.00,  15600.00,   9400.00, 'tarjeta',       'completada', 'Envases farmacéuticos y ámbar',               'directa',    NULL),
    ('VTA-000010', 1,  2, '2026-04-01 08:45:00',  96000.00,  3000.00,  93000.00,  60000.00,  33000.00, 'transferencia', 'completada', 'Reposición mensual envases PET',              'directa',    NULL);

-- Datos iniciales: detalle_ventas (20 registros)
-- Nota: cada INSERT activa el trigger trg_descontar_stock que descuenta stock y registra movimiento
INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario, costo_unitario, descuento_linea, subtotal_linea, costo_linea, ganancia_linea) VALUES
    -- VTA-000001: Envases PET surtidos
    (1, 1,  50,  600.00,  350.00, 0.00,  30000.00, 17500.00, 12500.00),
    (1, 2,  40,  850.00,  500.00, 0.00,  34000.00, 20000.00, 14000.00),
    (1, 3,  30, 1200.00,  750.00, 0.00,  36000.00, 22500.00, 13500.00),
    -- VTA-000002: Envases ámbar
    (2, 5,  50,  950.00,  600.00, 0.00,  47500.00, 30000.00, 17500.00),
    (2, 6,  34, 1400.00,  900.00, 0.00,  47600.00, 30600.00, 17000.00),
    -- VTA-000003: Envases de aseo
    (3, 7,  60, 1050.00,  650.00, 0.00,  63000.00, 39000.00, 24000.00),
    (3, 8,  40, 1550.00,  950.00, 0.00,  62000.00, 38000.00, 24000.00),
    -- VTA-000004: Compra variada
    (4, 9,  15,  700.00,  400.00, 0.00,  10500.00,  6000.00,  4500.00),
    (4, 10, 7,  1000.00,  620.00, 0.00,   7000.00,  4340.00,  2660.00),
    -- VTA-000005: Envases farmacéuticos
    (5, 13, 40, 1300.00,  800.00, 0.00,  52000.00, 32000.00, 20000.00),
    -- VTA-000006: Artículos hogar
    (6, 11, 10, 1900.00, 1200.00, 0.00,  19000.00, 12000.00,  7000.00),
    (6, 12,  3, 5500.00, 3500.00, 0.00,  16500.00, 10500.00,  6000.00),
    -- VTA-000007: Envases alimenticios
    (7, 15, 80,  900.00,  550.00, 0.00,  72000.00, 44000.00, 28000.00),
    (7, 9,  50,  700.00,  400.00, 0.00,  35000.00, 20000.00, 15000.00),
    -- VTA-000008: Compra menor
    (8, 10, 12, 1000.00,  620.00, 0.00,  12000.00,  7440.00,  4560.00),
    -- VTA-000009: Envases farmacéuticos y ámbar
    (9, 13, 20, 1300.00,  800.00, 0.00,  26000.00, 16000.00, 10000.00),
    -- VTA-000010: Reposición PET
    (10, 1,  40,  600.00,  350.00, 0.00,  24000.00, 14000.00, 10000.00),
    (10, 2,  30,  850.00,  500.00, 0.00,  25500.00, 15000.00, 10500.00),
    (10, 3,  20, 1200.00,  750.00, 0.00,  24000.00, 15000.00,  9000.00),
    (10, 4,  10, 1800.00, 1100.00, 0.00,  18000.00, 11000.00,  7000.00);

-- Datos iniciales: gastos (12 registros)
-- Nota: el trigger trg_resumen_diario_gasto actualiza resumen_diario
INSERT INTO gastos (id_categoria, id_usuario, descripcion, valor, fecha_gasto, comprobante, observaciones) VALUES
    (1,  1, 'Flete envío mercancía a Ocaña',                    250000.00, '2026-03-01', 'COMP-FL-001.pdf',  'Transportadora Nacional Express'),
    (2,  1, 'Arriendo bodega mes de marzo',                    1800000.00, '2026-03-01', 'COMP-AR-003.pdf',  'Contrato vigente hasta diciembre 2026'),
    (3,  1, 'Servicios públicos marzo (agua, luz, internet)',    450000.00, '2026-03-05', 'COMP-SP-003.pdf',  'Incluye reconexión de internet'),
    (4,  2, 'Compra lote de envases PET al proveedor',         2500000.00, '2026-03-07', 'COMP-CM-012.pdf',  'Proveedor Plastiqueros S.A.S.'),
    (5,  1, 'Nómina primera quincena marzo',                   3200000.00, '2026-03-15', 'COMP-NM-006.pdf',  'Incluye prestaciones sociales'),
    (6,  3, 'Publicidad en redes sociales marzo',                180000.00, '2026-03-10', 'COMP-MK-002.pdf',  'Pauta en Facebook e Instagram'),
    (7,  4, 'Reparación estantería de bodega',                   320000.00, '2026-03-12', 'COMP-MT-004.pdf',  'Soldadura y pintura de estructura'),
    (8,  2, 'Resma de papel y tóner para impresora',              85000.00, '2026-03-14', 'COMP-PP-001.pdf',  'Papelería Central'),
    (5,  1, 'Nómina segunda quincena marzo',                   3200000.00, '2026-03-30', 'COMP-NM-007.pdf',  'Incluye prestaciones sociales'),
    (9,  1, 'Póliza de seguro contra incendio y robo',           750000.00, '2026-03-20', 'COMP-SG-001.pdf',  'Renovación anual, Seguros Bolívar'),
    (1,  2, 'Flete envío mercancía a Villa del Rosario',         180000.00, '2026-03-22', 'COMP-FL-002.pdf',  'Transportadora local'),
    (4,  2, 'Compra envases ámbar importados',                 1800000.00, '2026-03-25', 'COMP-CM-013.pdf',  'Importación desde Bogotá');

\echo ''
\echo '======================================'
\echo '  TABLA: ventas'
\echo '======================================'
SELECT * FROM ventas;

\echo ''
\echo '======================================'
\echo '  TABLA: detalle_ventas'
\echo '======================================'
SELECT * FROM detalle_ventas;

\echo ''
\echo '======================================'
\echo '  TABLA: gastos'
\echo '======================================'
SELECT * FROM gastos;

\echo ''
\echo '======================================'
\echo '  TABLA: movimientos_inventario  (llenada automaticamente por trigger)'
\echo '======================================'
SELECT * FROM movimientos_inventario;

\echo ''
\echo '======================================'
\echo '  TABLA: resumen_diario  (llenada automaticamente por trigger)'
\echo '======================================'
SELECT * FROM resumen_diario;

\echo ''
\echo '======================================'
\echo '  VISTA: v_inventario'
\echo '======================================'
SELECT * FROM v_inventario;

\echo ''
\echo '======================================'
\echo '  VISTA: v_ventas'
\echo '======================================'
SELECT * FROM v_ventas;

\echo ''
\echo '======================================'
\echo '  VISTA: v_resumen_financiero_diario'
\echo '======================================'
SELECT * FROM v_resumen_financiero_diario;

\echo ''
\echo '======================================'
\echo '  VISTA: v_productos_mas_vendidos'
\echo '======================================'
SELECT * FROM v_productos_mas_vendidos;

\echo ''
\echo '======================================'
\echo '  VISTA: v_historial_clientes'
\echo '======================================'
SELECT * FROM v_historial_clientes;

\echo ''
\echo '======================================'
\echo '  VISTA: v_gastos_por_categoria'
\echo '======================================'
SELECT * FROM v_gastos_por_categoria;

\echo ''
\echo '======================================'
\echo '  VISTA: v_cotizaciones'
\echo '======================================'
SELECT * FROM v_cotizaciones;


-- ============================================================
--  FUNCIONES DE UTILIDAD
-- ============================================================

-- Función: generar número de venta consecutivo
CREATE OR REPLACE FUNCTION fn_generar_numero_venta()
RETURNS TEXT AS $$
DECLARE
    v_ultimo INT;
    v_numero TEXT;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_venta FROM 5) AS INT)), 0)
    INTO v_ultimo
    FROM ventas;

    v_numero := 'VTA-' || LPAD((v_ultimo + 1)::TEXT, 6, '0');
    RETURN v_numero;
END;
$$ LANGUAGE plpgsql;

-- Función: generar número de cotización consecutivo
CREATE OR REPLACE FUNCTION fn_generar_numero_cotizacion()
RETURNS TEXT AS $$
DECLARE
    v_ultimo INT;
    v_numero TEXT;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(numero_cotizacion FROM 5) AS INT)), 0)
    INTO v_ultimo
    FROM cotizaciones;

    v_numero := 'COT-' || LPAD((v_ultimo + 1)::TEXT, 6, '0');
    RETURN v_numero;
END;
$$ LANGUAGE plpgsql;

-- Función: reporte de ventas por rango de fechas (RF19)
CREATE OR REPLACE FUNCTION fn_reporte_ventas(p_desde DATE, p_hasta DATE)
RETURNS TABLE (
    producto        VARCHAR,
    categoria       VARCHAR,
    total_cantidad  BIGINT,
    total_ingresos  DECIMAL,
    total_costo     DECIMAL,
    total_ganancia  DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.nombre::VARCHAR,
        c.nombre::VARCHAR,
        SUM(dv.cantidad),
        SUM(dv.subtotal_linea),
        SUM(dv.costo_linea),
        SUM(dv.ganancia_linea)
    FROM detalle_ventas dv
    JOIN ventas v   ON v.id = dv.id_venta
    JOIN productos p ON p.id = dv.id_producto
    JOIN categorias_producto c ON c.id = p.id_categoria
    WHERE DATE(v.fecha_venta) BETWEEN p_desde AND p_hasta
      AND v.estado = 'completada'
    GROUP BY p.nombre, c.nombre
    ORDER BY total_ganancia DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_reporte_ventas IS 'Genera reporte de ventas por rango de fechas (RF19)';

-- Función: reporte de inventario actual (RF20)
CREATE OR REPLACE FUNCTION fn_reporte_inventario()
RETURNS TABLE (
    codigo          VARCHAR,
    nombre          VARCHAR,
    categoria       VARCHAR,
    capacidad_ml    DECIMAL,
    stock_disponible INT,
    stock_minimo    INT,
    alerta_stock    BOOLEAN,
    costo_unitario  DECIMAL,
    precio_venta    DECIMAL,
    valor_inventario DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.codigo,
        p.nombre,
        c.nombre::VARCHAR,
        p.capacidad_ml,
        p.stock_disponible,
        p.stock_minimo,
        (p.stock_disponible <= p.stock_minimo),
        p.costo_unitario,
        p.precio_venta,
        (p.costo_unitario * p.stock_disponible)
    FROM productos p
    JOIN categorias_producto c ON c.id = p.id_categoria
    WHERE p.activo = TRUE
    ORDER BY c.nombre, p.nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_reporte_inventario IS 'Genera reporte completo del inventario actual (RF20)';


-- ============================================================
--  PERMISOS - Usuario de aplicación (reemplazar 'app_user')
-- ============================================================
-- CREATE ROLE app_emplanorte WITH LOGIN PASSWORD 'CambiarEsta!2024';
-- GRANT USAGE ON SCHEMA emplanorte TO app_emplanorte;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA emplanorte TO app_emplanorte;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA emplanorte TO app_emplanorte;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA emplanorte TO app_emplanorte;


-- ============================================================
--  FIN DEL SCRIPT - EMPLANORTE S.A.S.
-- ============================================================
