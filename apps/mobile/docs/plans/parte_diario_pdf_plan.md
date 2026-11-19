# Plan: Parte diario en PDF (web + móvil)

> Fecha: 2026-11-19 · Rama: `features/taller_vehiculos`
> Objetivo: generar automáticamente, por persona y turno, el PDF equivalente a los partes en papel
> ("Registro prestaciones de servicios" + "Revisión vehículos"), imprimible desde web y móvil.

## Decisiones confirmadas

| # | Decisión |
|---|----------|
| 1 | **Un parte por persona** (y por inicio de turno: si alguien hace 2 turnos/vehículos en el día → 2 partes) |
| 2 | Hoja 2 = **checklist actual de la app** (`inicios_turno.checklist_items`), no los 23 ítems del papel |
| 3 | **P-10** = justificante opcional (campo libre, no obligatorio) |
| 4 | **Entidad** por servicio: SAS, PRIVADO, MUTUA, etc. |
| 5 | Disponible en **web y móvil** a la vez |

## Mapeo papel → datos

### Hoja 1 · Registro de prestaciones de servicios

| Campo | Origen |
|-------|--------|
| Cabecera empresa (logo, razón social, dirección, tel, CIF) | `EmpresaTenantEntity` (logoUrl, razonSocial, direccion, telefono, cif) |
| Técnico | `inicios_turno.personal_nombre` (MAYÚSCULAS) + compañero y rol |
| Matrícula | `inicios_turno.vehiculo_matricula` |
| Fecha | día del inicio de turno |
| Hora entrada / salida | fichajes `RegistroHorarioEntity` (entrada/salida emparejados) |
| KM entrada | `inicios_turno.km_inicial` |
| **KM salida** | **NUEVO** `inicios_turno.km_final` |
| KM recorridos | `km_final - km_inicial` (entero) |
| Gasóleo litros / importe | `ConsumoCombustibleEntity` (conductorId + vehiculo + fecha) → suma `litros`, `costoTotal` |
| E. servicios | nº traslados finalizados |
| Revisado controles mantenimiento | ✓ si `checklist_items` todo correcto (o check marcado con nº incidencias) |
| Tabla: Nombre paciente | `traslado.paciente` (nombre completo MAYÚSCULAS) |
| Domicilio | domicilio del paciente / origen si `tipoOrigen = domicilio_paciente` |
| Trayecto | `ida` / `vuelta` + origen → destino abreviado |
| Recog. hora | `fechaEnOrigen` (fallback `horaProgramada`) |
| Final hora | `fechaEnDestino` / hora de finalización |
| Entidad | `paciente.mutuaAseguradora` (ver Fase 1.3) |
| Incidencias servicios/vehículo | traslados no realizados + motivo, incidencias de vehículo del día, `inicios_turno.avisos` |
| **Números P-10 entregados** | **NUEVO** `inicios_turno.numeros_p10` (texto, opcional) |

### Hoja 2 · Revisión del vehículo

| Campo | Origen |
|-------|--------|
| Fecha revisión / vehículo / realizado por | `inicios_turno.created_at`, matrícula, personal_nombre |
| Ítems ✓ / ✗ / observaciones | `inicios_turno.checklist_items` (agrupados por categoría si la plantilla la tiene; si no, lista plana) |
| Nivel combustible / foto km | `inicios_turno.combustible` |
| Otras incidencias | ítems ✗ con observación + `avisos` + `motivo_fuera_base` |

## Fases

### Fase 1 · Datos que faltan (Supabase + core)

1.1 **Migración** `inicios_turno`:
```sql
ALTER TABLE inicios_turno
  ADD COLUMN km_final integer,
  ADD COLUMN foto_km_final_url text,
  ADD COLUMN numeros_p10 text,
  ADD COLUMN fin_turno_at timestamptz;
```
(RLS: misma política de UPDATE que ya usa el propio trabajador sobre su registro.)

1.2 **Core** (`packages/ambutrack_core_datasource/.../inicio_turno/`):
- Entity + Model: nuevos campos.
- Contract + impl: `registrarFinTurno({id, kmFinal, fotoKmFinal?, numerosP10?})`.

1.3 **Entidad del servicio**: hoy `mutuaAseguradora` es texto libre en paciente.
- PDF: mostrar `mutuaAseguradora` en MAYÚSCULAS; vacío → `SAS` (**a confirmar**).
- Mejora opcional (fuera de este plan): convertirlo en catálogo (SAS / PRIVADO / MUTUA + nombre).

### Fase 2 · Fin de turno en móvil

- Al fichar **salida** (`registro_horario`), si hay inicio de turno abierto → diálogo/paso "Fin de turno":
  - KM final (obligatorio, entero, ≥ km inicial; foto opcional como en entrada).
  - Nº P-10 entregados (opcional).
- Guarda con `registrarFinTurno`. SafeArea + diálogo profesional.

### Fase 3 · Generador PDF compartido

Nuevo paquete **`packages/ambutrack_pdf/`** (dependencias: `pdf`, `intl`, `ambutrack_core_datasource`):
```
lib/
├── ambutrack_pdf.dart                      # barrel
└── src/parte_diario/
    ├── parte_diario_data.dart              # DTO plano con todo lo necesario
    ├── parte_diario_builder.dart           # entities → ParteDiarioData (cálculos)
    ├── parte_diario_pdf.dart               # generar(List<ParteDiarioData>) → Uint8List
    ├── hoja_servicios.dart                 # página 1 (cabecera + tabla 17 filas + incidencias + P-10)
    ├── hoja_revision_vehiculo.dart         # página 2 (checklist ✓/✗/obs + otras incidencias)
    └── pdf_estilos.dart                    # colores corporativos (granate bordes, azul títulos), radios
```
- Estilo fiel al papel: A4 vertical, cajas redondeadas, pastillas en cabeceras de columna.
- Tabla: 17 filas fijas; si hay más servicios → página de continuación.
- Varios partes → un solo PDF (útil para "imprimir todos los del día" en web).
- Logo: descargado de `logoUrl` (bytes) antes de generar; sin logo → solo nombre.
- Paquete puro (sin Flutter UI) → testeable con tests unitarios del builder.

### Fase 4 · Móvil

- `pubspec.yaml`: añadir `ambutrack_pdf` (path) + `printing`.
- `partes_diarios`: cubit carga además inicio(s) de turno, repostajes, incidencias y empresa.
- Botón **"PDF"** en la página → `Printing.layoutPdf` (imprimir/guardar) / `Printing.sharePdf` (compartir).

### Fase 5 · Web

- `pubspec.yaml`: añadir `ambutrack_pdf` (path).
- Ubicación: **Informes → Partes diarios**: selector de fecha + tabla de personal con turno ese día.
  - Acción por fila: imprimir parte de esa persona.
  - Acción global: imprimir todos los partes del día (un PDF).
- Acceso rápido opcional desde la ficha de personal.

### Fase 6 · QA

- Tests del builder (km recorridos, emparejado de fichajes, agrupado, >17 servicios).
- `flutter analyze` en web, mobile y paquetes → 0 warnings.

## Archivos afectados (estimación)

| Zona | Archivos |
|------|----------|
| Supabase | 1 migración |
| core_datasource | entity, model (+ .g), contract, impl de `inicio_turno` |
| ambutrack_pdf (nuevo) | ~7 archivos + tests |
| mobile | registro_horario (diálogo fin turno), partes_diarios (cubit + botón), pubspec |
| web | informes/partes_diarios (página, cubit, repo), router, menú, pubspec |

## Comandos que requieren autorización

- Aplicar migración en Supabase (`ycmopmnrhrpnnzkvnihr`).
- `flutter pub get` en mobile, web y nuevo paquete.
- `dart run build_runner build --delete-conflicting-outputs` en core_datasource.
- `flutter analyze`.

## Estado (2026-11-19): IMPLEMENTADO

- Entidad vacía en paciente → `SAS` por defecto.
- KM final **obligatorio** al finalizar jornada si hay inicio de turno abierto (≤ 30 h).
- Los trabajadores no tienen UPDATE en `inicios_turno` → se cierra vía RPC `fn_registrar_fin_turno`
  (SECURITY DEFINER, valida propietario y km final ≥ inicial).
- Web: en lugar de una página nueva en Informes, se integra en **Personal → Horarios → Inicios de turno**
  (botones "Parte diario" y "Partes del día").
- Hoja 2 sin categorías: la plantilla `plantilla_checklist_inicio_turno` no tiene categoría (lista plana).
- Orquestación compartida: `ParteDiarioGenerador` + interfaz `ParteDiarioFuentes` en `ambutrack_pdf`;
  cada app implementa un repositorio pass-through.
