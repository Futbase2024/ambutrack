# Propuesta: Informe de Satisfacción del Paciente

> Estado: **propuesta** (no implementado en base de datos).
> Página actual: `lib/features/informes/presentation/pages/satisfaccion_paciente_page.dart` (estado vacío).

## 1. Situación actual

No existe en Supabase ni en `ambutrack_core_datasource` ninguna tabla/entidad de encuestas,
valoraciones u opiniones de pacientes. Las únicas referencias a "satisfacción" son la entrada del
menú y los permisos del módulo. Por eso el informe muestra un estado vacío explicativo.

## 2. Modelo de datos propuesto

### `encuestas_satisfaccion` (plantillas)
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| empresa_id | uuid FK | multiempresa |
| nombre | text | p. ej. "Encuesta post-traslado v1" |
| activa | boolean | solo una activa por empresa |
| created_at / updated_at | timestamptz | |

### `encuestas_preguntas`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| encuesta_id | uuid FK → encuestas_satisfaccion | |
| orden | int | |
| texto | text | "Puntualidad", "Trato del personal", "Comodidad del vehículo"... |
| tipo | text | `escala_1_5`, `nps_0_10`, `si_no`, `texto` |
| obligatoria | boolean | |

### `encuestas_envios` (una invitación por traslado)
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| encuesta_id | uuid FK | |
| traslado_id | uuid FK → traslados | único |
| paciente_id | uuid FK → pacientes | |
| canal | text | `sms`, `email`, `app_movil`, `telefono` |
| token | text único | enlace público de respuesta |
| enviado_at | timestamptz | |
| respondido_at | timestamptz null | |
| expira_at | timestamptz | |

### `encuestas_respuestas`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| envio_id | uuid FK → encuestas_envios | |
| pregunta_id | uuid FK → encuestas_preguntas | |
| valor_numerico | int null | escala / NPS |
| valor_texto | text null | comentarios |
| created_at | timestamptz | |

RLS: lectura por empresa para usuarios autenticados con permiso del módulo; inserción de
respuestas solo vía Edge Function que valida el `token` (respuesta anónima del paciente).

## 3. Flujo de recogida

1. Al pasar un traslado a `finalizado` (trigger o Edge Function) se crea un `encuestas_envios`
   con token y se envía por SMS/e-mail (o se ofrece en la app móvil del conductor si el
   paciente responde en el momento).
2. El paciente abre el enlace público (página web ligera) y responde.
3. La Edge Function guarda las respuestas y marca `respondido_at`.
4. Opcional: vista SQL `v_satisfaccion_traslado` con la media por envío y datos del traslado
   (fecha, vehículo, motivo, conductor) para que el informe no tenga que cruzar en cliente.

## 4. Contenido del informe (cuando existan datos)

- **KPIs**: puntuación media (1-5), NPS, tasa de respuesta (respondidos / enviados),
  nº de respuestas, % valoraciones negativas (≤ 2), comentarios recibidos.
- **Gráficos**: distribución de puntuaciones; media por pregunta.
- **Tabla**: desglose por vehículo / conductor / motivo de traslado (respuestas, media, NPS).
- **Filtros**: periodo, vehículo, motivo de traslado, canal.

## 5. Implementación (siguiendo el patrón del proyecto)

- `packages/ambutrack_core_datasource/lib/src/datasources/encuestas_satisfaccion/`
  (entities, models, contract, implementación Supabase, factory).
- Repositorio pass-through en `lib/features/informes/domain/repositories/`.
- BLoC `SatisfaccionPacienteBloc extends InformeBloc<...>` reutilizando
  `InformeScaffold`, `InformeBody`, `InformeBarChart` e `InformeTabla`.
