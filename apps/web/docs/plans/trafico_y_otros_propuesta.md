# Propuesta: módulos Tráfico y Otros (rutas con `PlaceholderPage`)

> **Estado**: PROPUESTA. No hay código implementado para estas rutas.
> **Fecha**: 2026-11-05
> **Alcance**: `/trafico/tiempo-real`, `/trafico/alertas`, `/trafico/rutas-alternativas`, `/trafico/integracion-mapas`, `/trafico/prioridad-semaforica`, `/otros/integraciones`, `/otros/backups`, `/otros/api-webhooks`.
> Esfuerzo: **S** ≤ 3 días · **M** 1–2 semanas · **L** > 2 semanas.

## 0. Inventario de lo que ya existe

| Pieza | Dónde | Estado |
|-------|-------|--------|
| Mapas web | `flutter_map ^7` + `latlong2`, tiles OSM públicos (`tile.openstreetmap.org`) | En uso: `rutas_tecnicos_page.dart` / `mapa_ruta_widget.dart`, fichajes (`ubicacion_fichaje_map_dialog.dart`, `fichaje_ubicacion_tab.dart`) |
| Routing | `lib/core/services/routing_service.dart` → **OSRM** (servidor HTTP público); fallback Haversine + velocidad media en `ruta_service.dart` | En uso en Rutas de técnicos (sin tráfico real) |
| Geocodificación | `lib/core/services/geocoding_service.dart` → **Nominatim** (OSM) | En uso (límite 1 req/s, sin SLA) |
| GPS móvil | `apps/mobile`: `geolocator ^13` | Captura puntual: fichajes (`registros_horarios.latitud/longitud`) y cambios de estado de traslado (`traslados.ubicacion_en_origen`, `..._en_transito`, `..._en_destino`, `..._finalizado` como JSON `{lat,lng,timestamp}`; `historial_estados_traslado` con ubicación opcional) |
| Histórico GPS de vehículos | Tabla `thistorial_ubicaciones` (vehiculo_id, timestamp, lat/lng, velocidad, dirección, en_servicio, servicio_id, empresa_id) en `001_crear_tablas_vehiculos.sql` | **Sin uso** en Dart (sin datasource ni escritura) |
| Pantalla Geolocalización | `lib/features/vehiculos/geolocalizacion_page.dart` (83 líneas) | Maqueta estática, sin datos |
| Realtime | Supabase Realtime en traslados (`traslados_eventos`) y notificaciones | En uso |
| Notificaciones | Tabla `tnotificaciones` + Realtime; móvil `flutter_local_notifications` | **Sin push (FCM/APNs)** ni SMS |
| Jobs | Edge Function `generar-traslados-diarios`; pg_cron (`generacion-traslados-nocturna`, `limpieza-traslados-antiguos`, `notificacion-traslados-manana`) + `cron_job_logs` | En uso |
| Módulos de permiso | `AppModule.trafico*` ya definidos en `app_module.dart` | Listos para enlazar |

**Hueco principal**: no hay **tracking continuo** de vehículos (solo posiciones puntuales al cambiar de estado). Casi todo el bloque Tráfico depende de ello.

---

## 1. `/trafico/tiempo-real` — Estado de la flota en tiempo real

- **Objetivo**: mapa con la posición actual de cada ambulancia, estado (libre / en servicio / fuera de servicio), servicio asignado y antigüedad de la última posición.
- **Datos existentes**: `thistorial_ubicaciones` (esquema listo, vacío); posiciones puntuales en `traslados`; `flutter_map` en web; `geolocator` en móvil; Realtime.
- **Faltan**:
  - Envío periódico de posición desde la app móvil (cada 15–30 s en servicio; 2–5 min en espera) con servicio en segundo plano (`flutter_background_service` o `background_locator_2` → **nueva dependencia**; permisos "siempre" en Android/iOS).
  - Tabla `vehiculos_ubicacion_actual` (1 fila por vehículo, upsert) + `thistorial_ubicaciones` (append, particionada por mes, retención 90 días).
  - RLS por `empresa_id`; publicación Realtime solo de la tabla "actual".
  - Datasource `ubicaciones_vehiculo` en core; BLoC con stream; capa de marcadores en `GeolocalizacionPage` (reutilizable aquí).
- **Servicios externos / coste**: ninguno obligatorio (OSM). Para producción conviene un proveedor de tiles con SLA (MapTiler/Stadia/Mapbox: plan gratuito ~100k–200k cargas/mes, después ~0,5–1 €/1000). Coste Supabase: almacenamiento de histórico (~1 fila/30 s/vehículo).
- **Esfuerzo**: **L** (móvil en segundo plano + BD + web).
- **Dependencias**: ninguna previa. Es la base de 2, 3 y 5.
- **Prioridad**: **ALTA** — mayor valor operativo y desbloquea el resto.

## 2. `/trafico/alertas` — Alertas viales

- **Objetivo**: incidencias de tráfico (accidentes, obras, cortes) cercanas a las rutas activas, con aviso al coordinador.
- **Datos existentes**: ninguno de tráfico; sí rutas (OSRM) y posiciones puntuales.
- **Faltan**: fuente de incidencias + tabla `trafico_incidencias` (cacheada) + job de ingesta (Edge Function + pg_cron cada 5 min) + cruce con rutas activas (PostGIS `ST_DWithin`; requiere extensión `postgis`).
- **Servicios externos / coste**:
  - **DGT – Punto de Acceso Nacional (NAP) / DATEX II**: gratuito, España, XML. Recomendado.
  - Alternativas: TomTom Traffic Incidents (gratis hasta ~2.500 req/día), HERE Traffic (freemium).
  - Para Cataluña / País Vasco, fuentes autonómicas (SCT, Trafikoa).
- **Esfuerzo**: **M** (ingesta + vista lista/mapa); **+S** si se añaden avisos al conductor.
- **Dependencias**: 1 (para cruzar con posiciones reales; sin 1 solo puede cruzarse con origen/destino planificados).
- **Prioridad**: **MEDIA**.

## 3. `/trafico/rutas-alternativas` — Rutas alternativas

- **Objetivo**: para un traslado en curso, proponer 2–3 rutas con ETA según tráfico y permitir enviarlas al conductor.
- **Datos existentes**: `routing_service.dart` (OSRM) ya devuelve geometría, distancia y duración; `mapa_ruta_widget.dart`.
- **Faltan**: ETA **con tráfico** (OSRM público no tiene tráfico ni SLA); petición con `alternatives=true`; envío de la ruta elegida al móvil (tabla `traslados_ruta_sugerida` o campo en `traslados` + Realtime).
- **Servicios externos / coste**:
  - OSRM autoalojado (gratis, sin tráfico) — mínimo recomendado para producción (el servidor demo no admite uso intensivo).
  - Con tráfico: TomTom Routing (gratis ~2.500 req/día), HERE Routing (freemium ~1.000 €/año a escala), Google Routes API (~5 $/1000; ~10 $/1000 con tráfico).
- **Esfuerzo**: **M**.
- **Dependencias**: 1 (posición actual como origen); 4 (decidir proveedor).
- **Prioridad**: **MEDIA-BAJA**.

## 4. `/trafico/integracion-mapas` — Integración con mapas / DGT

- **Objetivo**: pantalla de administración del proveedor de mapas/tráfico: tiles, routing, geocoding y feeds DGT; claves API, límites y estado (última ingesta, errores).
- **Datos existentes**: URLs hardcodeadas (OSM tiles, OSRM, Nominatim) en servicios y widgets.
- **Faltan**: centralizar endpoints en un `MapProvidersConfig`; tabla `integraciones` (ver 6) para claves y estado; **claves en Supabase Vault / secrets de Edge Functions**, nunca en el cliente web; proxy en Edge Function para APIs de pago.
- **Servicios externos / coste**: los de 2 y 3.
- **Esfuerzo**: **S** (centralización) + **S** (pantalla de estado).
- **Dependencias**: 6 (comparte modelo de integraciones).
- **Prioridad**: **MEDIA** — hacer antes de contratar proveedores de pago (2/3).

## 5. `/trafico/prioridad-semaforica` — Prioridad semafórica

- **Objetivo**: solicitar prioridad en semáforos (verde) al paso de ambulancias en urgencia.
- **Datos existentes**: ninguno.
- **Faltan**: acuerdo con cada ayuntamiento / centro de control de tráfico; protocolo (habitualmente C-ITS / ETSI SREM-SSEM, emisores en vehículo o API del centro de gestión municipal); certificación; posición continua de alta frecuencia (1 s).
- **Servicios externos / coste**: integración específica por municipio; hardware embarcado (si C-ITS) ~300–1.000 €/vehículo; proyecto institucional.
- **Esfuerzo**: **L+** (fuera del alcance de software puro; requiere convenio).
- **Dependencias**: 1 (alta frecuencia), convenios externos.
- **Prioridad**: **BAJA** — recomendación: ocultar la entrada del menú hasta que exista un piloto con un ayuntamiento.

## 6. `/otros/integraciones` — Integraciones (SMS, push, mapas…)

- **Objetivo**: catálogo de integraciones con estado (activa/inactiva/error), configuración y prueba de conexión.
- **Datos existentes**: notificaciones in-app (`tnotificaciones` + Realtime); `flutter_local_notifications` en móvil; mapas OSM/OSRM/Nominatim. **Sin FCM ni SMS**.
- **Faltan**:
  - Tabla `integraciones` (empresa_id, tipo, proveedor, activo, config JSONB **sin secretos**, ultimo_ok, ultimo_error) + secretos en Supabase Vault.
  - **Push**: FCM (gratuito) vía Edge Function `send-push` + tabla `dispositivos_push` (token por usuario). Nota: la regla del proyecto prohíbe Firebase como backend; FCM se usaría solo como transporte de push (decisión a validar) — alternativa: OneSignal (gratis hasta 10k suscriptores web).
  - **SMS**: Twilio (~0,07–0,08 €/SMS en España), Vonage o proveedores nacionales (Altiria, LabsMobile ~0,04–0,05 €/SMS). Uso típico: aviso al paciente de llegada de ambulancia.
  - Email transaccional (Resend / SendGrid, freemium).
- **Esfuerzo**: **M** (catálogo + push) ; **+S** por cada proveedor adicional.
- **Dependencias**: ninguna; desbloquea alertas a conductores (2) y webhooks (8).
- **Prioridad**: **ALTA** para push al conductor (asignaciones con la app cerrada); **MEDIA** para SMS.

## 7. `/otros/backups` — Backups y restauración

- **Objetivo**: visibilidad del estado de copias y exportaciones bajo demanda.
- **Datos existentes**: backups automáticos diarios de Supabase (gestionados por la plataforma, según plan); `cron_job_logs` para jobs propios.
- **Faltan**:
  - Verificar plan Supabase: **Pro** = backups diarios 7 días; **PITR** add-on (~100 $/mes por 7 días de retención).
  - Exportación lógica propia: Edge Function / job externo (GitHub Actions con `pg_dump` o `supabase db dump`) que suba a Storage o S3 (cifrado) + tabla `backups_registro` (fecha, tamaño, destino, estado).
  - Pantalla: listado de `backups_registro`, botón "Exportar ahora" (solo admin) y exportación CSV por módulo. **La restauración debe seguir siendo manual/DBA** (no desde la app).
  - Storage: incluir buckets (documentación de vehículos, fotos) en la política.
- **Servicios externos / coste**: S3/Backblaze B2 (~0,005–0,023 $/GB/mes); PITR opcional.
- **Esfuerzo**: **M**.
- **Dependencias**: ninguna (decisión de plan Supabase).
- **Prioridad**: **MEDIA-ALTA** (requisito habitual de RGPD / continuidad, datos de pacientes).

## 8. `/otros/api-webhooks` — API / Webhooks

- **Objetivo**: permitir a terceros (hospitales, aseguradoras, mutuas) recibir eventos (traslado creado/asignado/finalizado) y consultar estados.
- **Datos existentes**: `traslados_eventos` (event ledger) — fuente ideal de eventos; Edge Functions ya en uso.
- **Faltan**:
  - Tablas `webhooks_suscripciones` (empresa_id, url, eventos[], secreto HMAC, activo) y `webhooks_entregas` (payload, intento, código HTTP, siguiente reintento).
  - Trigger sobre `traslados_eventos` → cola (`pgmq` o tabla) → Edge Function `dispatch-webhooks` con firma HMAC-SHA256 y reintentos exponenciales (pg_cron cada minuto). Alternativa: Supabase Database Webhooks (`pg_net`).
  - API de lectura: PostgREST con API keys por cliente (rol dedicado + RLS) o Edge Function `api/v1/traslados` con clave por cliente.
  - Pantalla: CRUD de suscripciones, log de entregas, reintento manual, rotación de secretos.
  - Revisión RGPD: minimizar datos de pacientes en payloads (IDs + estado, sin datos clínicos).
- **Servicios externos / coste**: ninguno (Supabase).
- **Esfuerzo**: **M–L**.
- **Dependencias**: 6 (modelo de integraciones/secretos); auditoría (`docs/plans/administracion_auditoria.md`) recomendable.
- **Prioridad**: **BAJA-MEDIA** (solo si hay un cliente que lo pida).

---

## Resumen y orden recomendado

| # | Ruta | Esfuerzo | Prioridad | Depende de |
|---|------|----------|-----------|------------|
| 1 | `/trafico/tiempo-real` | L | Alta | — |
| 6 | `/otros/integraciones` (push) | M | Alta | — |
| 7 | `/otros/backups` | M | Media-Alta | Plan Supabase |
| 4 | `/trafico/integracion-mapas` | S+S | Media | 6 |
| 2 | `/trafico/alertas` | M | Media | 1, 4 |
| 3 | `/trafico/rutas-alternativas` | M | Media-Baja | 1, 4 |
| 8 | `/otros/api-webhooks` | M–L | Baja-Media | 6 |
| 5 | `/trafico/prioridad-semaforica` | L+ | Baja | 1 + convenios |

**Recomendación**: Fase A = tracking continuo (1) + push (6). Fase B = backups (7) y centralización de proveedores de mapas (4). Fase C = alertas DGT (2) y rutas alternativas (3). Webhooks (8) bajo demanda; prioridad semafórica (5) ocultar del menú hasta tener convenio.
