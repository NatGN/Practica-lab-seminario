-- Practica 7 - Indices que se demuestran
-- Equipo: TresD
-- Autor: NatGN
--
-- Consulta adicional - Parte 3.1
-- Indice sobre fecha_pedido para busquedas por rango.
--
-- La consulta reescrita utiliza Bitmap Index Scan.
-- Tiempo mediano original: 5.694 ms.
-- Tiempo mediano reescrita: 1.429 ms.
-- Buffers originales: 211.
-- Buffers reescrita: 217.
--
-- El indice se conserva para consultas por rango de fechas.
-- No se demostro una mejora concluyente para C7.

CREATE INDEX IF NOT EXISTS pedido_fecha_pedido_idx
ON public.pedido (fecha_pedido);


-- C4 · autor: Pau24711
-- Índice sobre total para mejorar ORDER BY total DESC LIMIT 20.
-- Antes: Seq Scan · 422 Buffers · 14.885 ms.
-- Después: Index Scan Backward · 79 Buffers · 6.285 ms.
-- El índice se conserva porque redujo Buffers y eliminó el Sort.

CREATE INDEX IF NOT EXISTS pedido_total_idx
ON public.pedido (total);
