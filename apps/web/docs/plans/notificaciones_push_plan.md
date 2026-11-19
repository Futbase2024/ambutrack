# Plan: Notificaciones push en la app móvil

> Fecha: 2026-11-19 · Estado: **código terminado — falta configurar Firebase/Apple** (ver "Activación")
> Decisión: aprobada la opción A (Firebase **solo** para Cloud Messaging).

## Objetivo

Que los avisos (avería de vehículo, traslado asignado, vacaciones, vestuario…) **suenen en el móvil
aunque la app esté cerrada o en segundo plano**.

## Situación actual

- Todos los avisos se guardan en `tnotificaciones` (una fila por destinatario).
- Desde el 19/11/2026 las averías generan su aviso en la base de datos (trigger
  `trg_notificar_nueva_averia`), vengan de la web o del móvil.
- La app móvil escucha `tnotificaciones` por **Realtime** y muestra un diálogo/notificación local
  con `flutter_local_notifications`. **Solo funciona con la app abierta.** Con la app cerrada el aviso
  se ve al abrirla, sin sonido.
- No hay ningún servicio push configurado (sin `google-services.json` ni `GoogleService-Info.plist`).
- Identificador de la app: `com.emertrack.app` (Android e iOS); flavor dev: `com.emertrack.app.dev`.

## Decisión previa (bloqueante)

El `CLAUDE.md` del proyecto **prohíbe Firebase**. Pero en Android las notificaciones push con la app
cerrada pasan obligatoriamente por **Firebase Cloud Messaging (FCM)**, el servicio de Google. Cualquier
proveedor (OneSignal, Pusher Beams…) usa FCM por debajo y también pide un proyecto de Firebase.

| Opción | Qué implica | Coste |
|---|---|---|
| **A. FCM solo como canal de envío** (recomendada) | Proyecto Firebase **solo para Messaging**. Nada de Firestore ni Firebase Auth: datos y login siguen en Supabase. El envío lo hace una Edge Function de Supabase. | Gratis |
| B. OneSignal | SDK de OneSignal en la app y su panel. Igualmente necesita credenciales FCM (Android) y la clave APNs (iOS). Una dependencia externa más. | Gratis hasta cierto volumen |
| C. Sin push | Mantener Realtime (solo con la app abierta). | — |

**Hace falta que se apruebe una excepción a la regla "Firebase prohibido", limitada a Messaging (opción A).**

## Diseño (opción A)

```
web / móvil / trigger ──► INSERT en tnotificaciones
                                │  (trigger AFTER INSERT + pg_net)
                                ▼
                    Edge Function `enviar-push`
                    ─ lee los tokens del usuario destino (dispositivos_push)
                    ─ envía por FCM HTTP v1 (Android + iOS vía APNs)
                    ─ borra los tokens caducados
                                ▼
                      móvil del destinatario 🔔
```

### 1. Base de datos
- Activar la extensión **`pg_net`** (ahora solo está `pg_cron`).
- Tabla `dispositivos_push`: `id`, `usuario_id` (FK `usuarios`, cascade), `token` (único), `plataforma`
  (`android`/`ios`), `app_version`, `updated_at`. RLS: cada usuario solo ve y gestiona sus propios tokens.
- Trigger `AFTER INSERT ON tnotificaciones` que llama por `pg_net` a `enviar-push` con el id de la
  notificación. Nunca debe bloquear el INSERT (excepciones capturadas).

### 2. Edge Function `enviar-push`
- Secreto `FCM_SERVICE_ACCOUNT` (JSON de la cuenta de servicio de Firebase, solo en servidor).
- Solo acepta llamadas internas (cabecera secreta compartida con el trigger, `verify_jwt` desactivado).
- Carga la notificación y los tokens del destinatario y envía título, mensaje y
  `data: { notificacion_id, tipo, entidad_id }`.
- Si FCM responde `UNREGISTERED` o `INVALID_ARGUMENT`, borra el token.

### 3. App móvil
- Dependencias: `firebase_core` + `firebase_messaging` (se mantiene `flutter_local_notifications`).
- Configuración: `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) para
  `com.emertrack.app` y `com.emertrack.app.dev`.
- iOS: capacidades *Push Notifications* y *Background Modes → Remote notifications*; subir la
  **clave APNs (.p8)** a Firebase; revisar `PrivacyInfo.xcprivacy`.
- Android 13+: pedir el permiso `POST_NOTIFICATIONS` (se puede aprovechar el del servicio actual).
- Al iniciar sesión: pedir permiso, obtener el token y guardarlo en `dispositivos_push`.
  En `onTokenRefresh`, actualizarlo. Al cerrar sesión, borrarlo.
- **App en primer plano:** no mostrar el push del sistema; sigue funcionando el diálogo actual por
  Realtime, para no avisar dos veces.
- **Al tocar la notificación:** abrir la pantalla correspondiente reutilizando `_rutaNotificacion`
  de `app.dart` y marcarla como leída.
- Canal Android "Avisos" con sonido e importancia alta; las averías críticas, con prioridad máxima.

### 4. Datasource (core)
- `dispositivos_push/` siguiendo el patrón: entity, model, contract, factory e implementación Supabase
  (`registrar`, `eliminar`).

## Trabajo manual (fuera del código)
1. Crear el proyecto en la consola de Firebase y registrar las apps Android e iOS.
2. Descargar los ficheros de configuración y la cuenta de servicio (va como secreto en Supabase).
3. Apple Developer: crear la clave APNs y subirla a Firebase.
4. Publicar versiones nuevas en Play Store y App Store.

## Estimación
| Bloque | Esfuerzo |
|---|---|
| BD + Edge Function | 0,5 día |
| App móvil (registro de token, recepción, navegación) | 1–1,5 días |
| Configuración Firebase / Apple + pruebas en dispositivos reales | 0,5–1 día |
| **Total** | **2–3 días** |

## Riesgos
- **iOS** requiere cuenta de Apple Developer de pago y probar en un dispositivo real (el simulador
  no recibe push).
- Algunos Android con ahorro de batería agresivo (Xiaomi, Huawei…) retrasan los push; hay que pedir
  al usuario que excluya la app de la optimización de batería.
- Los avisos duplicados (Realtime + push) se evitan con la regla de primer plano.

---

## ✅ Implementado (19/11/2026)

| Pieza | Dónde |
|---|---|
| Extensión `pg_net`, tabla `dispositivos_push`, RPCs `fn_registrar_dispositivo_push` / `fn_eliminar_dispositivo_push`, columna `tnotificaciones.push_enviado_at`, trigger `trg_encolar_push_notificacion` | Migración `notificaciones_push` |
| Edge Function `enviar-push` (FCM HTTP v1, sin JWT, envío único por notificación, limpia tokens muertos) | `apps/web/supabase/functions/enviar-push/` |
| Datasource `dispositivos_push` | `packages/ambutrack_core_datasource/lib/src/datasources/dispositivos_push/` |
| `PushNotificationsService` (registro de token, baja al cerrar sesión, tocar → pantalla) | `apps/mobile/lib/core/services/push_notifications_service.dart` |
| Plugin Google Services **condicional** (solo si existe `google-services.json`) + canal por defecto | `apps/mobile/android/` |
| Producción inicializa ya las notificaciones locales (antes solo dev) | `apps/mobile/lib/main_android.dart` |

Sin configuración de Firebase todo queda **inactivo y la app funciona como antes**.

## 🔧 Activación (pasos manuales)

### 1. Firebase (console.firebase.google.com)
1. Crear proyecto (p.ej. `emertrack`). Desactivar Google Analytics (no se usa).
2. Añadir app **Android** con paquete `com.emertrack.app` y otra con `com.emertrack.app.dev`.
   Descargar `google-services.json` (incluye las dos) → `apps/mobile/android/app/google-services.json`.
3. Añadir app **iOS** con bundle `com.emertrack.app`.
   Descargar `GoogleService-Info.plist` → `apps/mobile/ios/Runner/` y **añadirlo al target Runner en Xcode**.
4. Configuración del proyecto → Cuentas de servicio → *Generar nueva clave privada* (JSON).

### 2. Supabase
- Edge Functions → Secrets → `FCM_SERVICE_ACCOUNT` = contenido completo del JSON del paso 1.4.
  (o `supabase secrets set FCM_SERVICE_ACCOUNT="$(cat clave.json)"`).

### 3. Apple (developer.apple.com + Xcode)
1. Keys → crear clave con **Apple Push Notifications service (APNs)** → descargar `.p8`.
2. Firebase → Configuración → Cloud Messaging → app iOS → subir la clave `.p8` (Key ID + Team ID).
3. Xcode → Runner → Signing & Capabilities → **+ Push Notifications**.

### 4. Probar
1. Compilar e instalar la app, iniciar sesión, aceptar el permiso de notificaciones.
2. Comprobar que aparece una fila en `dispositivos_push`.
3. Cerrar la app y crear una avería desde la web → debe sonar en el móvil del jefe de mantenimiento.
4. Logs: Supabase → Edge Functions → `enviar-push` (`📲 Push … {enviados: 1}`).

**No subir a git** la clave de la cuenta de servicio ni el `.p8`. `google-services.json` y
`GoogleService-Info.plist` no son secretos, pero conviene no publicarlos en repos públicos.
