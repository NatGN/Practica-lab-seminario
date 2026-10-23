# Equipo 07 — Caso Gimnasio

**Integrantes:**
-Natalia Godinez Alavez 
-Paulina Monserrat Meraz Alcantara
-Jesus Diaz Hernandez 

## Esquema relacional

<!-- Usen la notación de guias/notacion.md. Una tabla por renglón. -->

```
PLAN(**id_plan**, nombre, costo_mensual)

LOCKER(**num_locker**, ubicacion)

SOCIO(**num_socio**, nombre, apellidos, fecha_nacimiento, correo, id_plan → PLAN, num_locker? UNIQUE → LOCKER)

SOCIO_TELEFONO(**num_socio** → SOCIO, **telefono**)

INSTRUCTOR(**num_empleado**, nombre, apellidos, especialidad, num_supervisor? → INSTRUCTOR)

CLASE(**id_clase**, nombre, cupo_max, num_empleado → INSTRUCTOR)

SESION(**id_clase** → CLASE, **numero_sesion**, fecha, hora_inicio, salon)

INSCRIPCION(**num_socio** → SOCIO, **id_clase** → CLASE, **fecha_inscripcion**, estatus)

<!-- Si quieren, dibujen aquí el esquema en Mermaid. -->
