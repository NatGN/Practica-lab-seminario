import os

import psycopg
from psycopg.rows import dict_row
from fastapi import FastAPI, HTTPException, Query

app = FastAPI(title="API TresD")
DATABASE_URL = os.environ["DATABASE_URL"]


@app.get("/salud")
def salud():
    with psycopg.connect(DATABASE_URL, connect_timeout=10) as conn:
        conn.execute("SELECT 1")
    return {"estado": "ok"}


@app.get("/productos")
def listar_productos(limite: int = Query(default=20, ge=1, le=100)):
    with psycopg.connect(
        DATABASE_URL, row_factory=dict_row, connect_timeout=10
    ) as conn:
        filas = conn.execute(
            """
            SELECT id_producto, nombre_producto, descripcion,
                   material, disponible, id_categoria
            FROM public.producto
            ORDER BY id_producto
            LIMIT %s
            """,
            (limite,),
        ).fetchall()
    return filas


@app.get("/productos/{id_producto}")
def obtener_producto(id_producto: int):
    with psycopg.connect(
        DATABASE_URL, row_factory=dict_row, connect_timeout=10
    ) as conn:
        fila = conn.execute(
            """
            SELECT id_producto, nombre_producto, descripcion,
                   material, disponible, id_categoria
            FROM public.producto
            WHERE id_producto = %s
            """,
            (id_producto,),
        ).fetchone()

    if fila is None:
        raise HTTPException(
            status_code=404,
            detail="Producto no encontrado",
        )
    return fila