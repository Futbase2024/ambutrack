# Plan: Login, Entrada en Turno y Logout (app móvil)

> Fecha: 2026-11-18 · Rama: `features/taller_vehiculos` · Estado: **pendiente de aprobación**

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Dispositivo | Móvil/tablet de empresa → **dos modos**: `personal` (1 técnico) y `compartido` (1 por ambulancia) |
| Checklist | **Corto obligatorio** en cada inicio de turno (completo según periodicidad, módulo existente) |
| Compañero | **Opcional** añadirlo al iniciar turno |
| Fuera de base | Si el **vehículo/turno está libre** → deja iniciar, queda **pendiente de validación del coordinador**. Si está ocupado por otro → bloquea |
| Logout | Unificar, diálogo profesional, **controlar turno abierto** |

---

## 1. Logout (hoy duplicado en `main_layout.dart` y `perfil_page.dart`, AlertDialog básico)

```
[Cerrar sesión]
      │
 ¿Turno abierto? ──No──▶ Confirmación profesional ──▶ signOut
      │Sí
 Diálogo advertencia:
   ▶ Finalizar jornada y salir   (flujo FinalizarJornada existente → signOut)
   ▶ Salir sin finalizar         (turno sigue abierto; el compañero continúa)
   ▶ Cancelar
```

Al cerrar sesión: parar tracking GPS, cancelar suscripciones realtime, limpiar caché Hive del usuario
(se conserva solo "DNI recordado" en modo personal / lista de usuarios recientes en modo compartido).
En modo **compartido** → logout automático tras finalizar jornada.

**Archivos**
- `lib/core/widgets/dialogs/logout_flow.dart` (nuevo, función única `iniciarLogout(context)`)
- `main_layout.dart`, `perfil_page.dart` → usan `iniciarLogout`
- `auth_bloc.dart` → `_onAuthSignOutRequested` limpia servicios (GPS, realtime)

## 2. Login

| | Modo personal | Modo compartido |
|---|---|---|
| Pantalla inicial | DNI recordado + PIN | Rejilla de usuarios recientes + "Otro usuario" |
| Desbloqueo rápido | Huella / Face ID (`local_auth`) | PIN (sin biometría: no identifica a la persona) |
| Bloqueo inactividad | 15 min → pantalla de desbloqueo | 5 min |
| Fin de jornada | Sesión sigue | Logout automático |
| Olvidé clave | Diálogo "Contacta con tu coordinador" (reset desde web) | Igual |

- **Modo del dispositivo**: guardado en local (Hive). Solo se cambia desde Perfil → "Configuración del dispositivo"
  por un usuario con rol coordinador/admin. Por defecto: `personal`.
- La sesión Supabase ya persiste: la biometría/PIN es un **bloqueo de app** (`AppLockService` +
  `WidgetsBindingObserver`), no un nuevo login.

**Archivos**
- `lib/core/services/device_mode_service.dart`, `app_lock_service.dart` (nuevos)
- `features/auth/presentation/pages/login_page.dart` (recordar DNI) + `widgets/usuarios_recientes_grid.dart`
- `features/auth/presentation/pages/desbloqueo_page.dart` (nuevo) + ruta + guard en router

## 3. Entrada en turno (asistente por pasos)

Sustituye el contenido de `iniciar_turno_sheet.dart` por un asistente con 6 pasos:

| Paso | Contenido | Validación |
|---|---|---|
| 1 Turno | Cuadrante o plantilla (**ya existe**) | — |
| 2 Vehículo | Escanear QR (`mobile_scanner`) o lista (ya existe) | ⛔ seguro/ITV/homologación caducados · ⛔ vehículo ocupado por otra persona · ⚠ caduca < 15 días |
| 3 Dotación | Rol (Conductor / TES / Enfermero) + compañero **opcional** | ⛔ conductor con carnet caducado (`tdocumentos_personal`) · ⚠ documentación < 30 días |
| 4 Estado vehículo | Km iniciales (+ foto opcional `image_picker`) + combustible ¼ ½ ¾ lleno | ⛔ km < `tvehiculos.km_actual` |
| 5 Checklist corto | Items de `plantilla_checklist_vehiculo` con `tipo_checklist='inicio_turno'` | Todos marcados; ausentes → observación obligatoria |
| 6 Resumen | Declaración "en condiciones para el servicio" + ubicación vs base | Fuera de radio (200 m) → motivo + pendiente de validación |

### Fuera de base → validación del coordinador
```
GPS a > 200 m de bases.latitud/longitud
   │
 ¿Vehículo/turno ocupado por otro? ──Sí──▶ ⛔ Bloquea
   │No
 Pedir motivo ──▶ Inicia turno con estado 'pendiente_validacion'
              ──▶ tnotificaciones a coordinadores (tipo 'validacion_inicio_turno')
              ──▶ Web: coordinador aprueba / rechaza → notificación al técnico
```

### Datos (reutilizando tablas existentes)
- `asignaciones_vehiculos_turnos`: vehiculo_id, fecha, plantilla_turno_id, base_id, **km_inicial**, estado
  (`en_curso` / `pendiente_validacion`), confirmada_por, fecha_confirmacion
- `turnos_personal_vehiculos`: rol, es_responsable (uno por técnico; compañero opcional)
- `checklists_vehiculo` + `items_checklist_vehiculo`: tipo `inicio_turno`, kilometraje
- `registros_horarios`: fichaje de entrada (ya existe)
- `tvehiculos.km_actual` ← km inicial

### Migración (nueva)
```sql
ALTER TABLE asignaciones_vehiculos_turnos
  ADD COLUMN combustible_inicial text CHECK (combustible_inicial IN ('1/4','1/2','3/4','lleno')),
  ADD COLUMN foto_km_url text,
  ADD COLUMN fuera_de_base boolean DEFAULT false,
  ADD COLUMN motivo_fuera_base text,
  ADD COLUMN declaracion_aptitud boolean DEFAULT false;
-- + seed de items 'inicio_turno' en plantilla_checklist_vehiculo
-- + bucket storage 'fotos-km' con RLS
```
> ⚠️ Verificar antes cómo usa la web `asignaciones_vehiculos_turnos` y `turnos_personal_vehiculos`.

### Archivos
- `packages/ambutrack_core_datasource`: ampliar datasource de inicio de turno (contract/impl/factory/model)
- `features/registro_horario/presentation/cubit/inicio_turno_cubit.dart` + `state` → pasos, validaciones
- `features/registro_horario/domain/services/validador_inicio_turno.dart` (lógica pura, testeable)
- `widgets/inicio_turno/pasos/` → `paso_turno`, `paso_vehiculo`, `paso_dotacion`, `paso_estado_vehiculo`,
  `paso_checklist`, `paso_resumen`, `indicador_pasos.dart`, `escaner_qr_vehiculo.dart`

## 4. Web (necesario para cerrar el circuito)
- Ficha vehículo → botón **imprimir QR** (contenido: id del vehículo)
- Panel **validaciones de inicio de turno** (aprobar/rechazar)
- **Restablecer PIN** de un técnico

## 5. Dependencias nuevas
`local_auth`, `mobile_scanner`, `image_picker` (+ permisos iOS `Info.plist` / Android `AndroidManifest.xml`)

## 6. Fases

| Fase | Contenido |
|---|---|
| **1** | Logout unificado · recordar DNI · biometría · bloqueo inactividad · modo dispositivo · pasos km/combustible, checklist corto y resumen · bloqueos por documentación |
| **2** | QR vehículo · rol + compañero opcional · geocerca + validación coordinador (móvil + web) |
| **3** | Web: imprimir QR, reset PIN · usuarios recientes en modo compartido |

Al terminar cada fase: `flutter analyze` → 0 warnings (con autorización).
