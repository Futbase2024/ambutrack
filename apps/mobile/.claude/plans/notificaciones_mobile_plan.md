# Plan de Implementación: Módulo de Notificaciones Mobile

**Fecha:** 2026-02-10
**Autor:** Claude Code
**Complejidad:** Alta (8+ archivos, integración realtime, notificaciones locales)
**Estimación:** Implementación completa

---

## 📋 Resumen

Implementar sistema completo de notificaciones push en AmbuTrack Mobile para que Conductores y TES reciban notificaciones con sonido y vibración cuando:
- Se les asigne un nuevo traslado
- Se les desadjudique un traslado
- Otros eventos relevantes del sistema

---

## 🎯 Objetivos

1. ✅ **Usar arquitectura centralizada del core** (sin duplicar entities)
2. ✅ **Notificaciones locales** con sonido y vibración personalizados
3. ✅ **Realtime de Supabase** para recibir notificaciones instantáneas
4. ✅ **UI nativa Material 3** con badge y contador
5. ✅ **Gestión de permisos** Android/iOS
6. ✅ **Clean Architecture** estricta

---

## 🏗️ Arquitectura Actual vs Deseada

### ❌ Problema Actual
```
apps/mobile/lib/features/notificaciones/domain/
├── entities/notificacion_entity.dart          ❌ DUPLICADA, campos incorrectos
└── repositories/notificaciones_repository.dart ❌ DUPLICADA, métodos diferentes
```

### ✅ Arquitectura Correcta
```
# Core (ya existe, solo agregar tipos)
packages/ambutrack_core/lib/src/datasources/notificaciones/
├── entities/notificacion_entity.dart           ✅ USAR ESTA (única fuente de verdad)
├── models/notificacion_supabase_model.dart     ✅ Ya existe
├── implementations/supabase/...                ✅ Ya existe
├── notificaciones_contract.dart                ✅ Ya existe
└── notificaciones_factory.dart                 ✅ Ya existe

# Mobile (implementar)
apps/mobile/lib/features/notificaciones/
├── data/
│   └── repositories/
│       └── notificaciones_repository_impl.dart  ⬅️ CREAR (pass-through al core)
├── domain/
│   └── repositories/
│       └── notificaciones_repository.dart       ⬅️ CREAR (contrato)
├── presentation/
│   ├── bloc/
│   │   ├── notificaciones_bloc.dart
│   │   ├── notificaciones_event.dart
│   │   └── notificaciones_state.dart
│   ├── pages/
│   │   └── notificaciones_page.dart
│   └── widgets/
│       ├── notificacion_card.dart
│       ├── notificacion_badge.dart
│       └── notificaciones_empty_state.dart
└── services/
    └── local_notifications_service.dart         ⬅️ Sonido/vibración
```

---

## 📝 Tareas Detalladas

### 1️⃣ Actualizar Core - NotificacionTipo (CRÍTICO PRIMERO)

**Archivo:** `packages/ambutrack_core/lib/src/datasources/notificaciones/entities/notificacion_entity.dart`

**Acción:** Agregar nuevos tipos de notificación para traslados:

```dart
enum NotificacionTipo {
  // ... tipos existentes ...

  // ⬇️ NUEVOS TIPOS PARA MOBILE
  trasladoAsignado('traslado_asignado', 'Nuevo Traslado Asignado'),
  trasladoDesadjudicado('traslado_desadjudicado', 'Traslado Desadjudicado'),
  trasladoIniciado('traslado_iniciado', 'Traslado Iniciado'),
  trasladoFinalizado('traslado_finalizado', 'Traslado Finalizado'),
  trasladoCancelado('traslado_cancelado', 'Traslado Cancelado'),
  checklistPendiente('checklist_pendiente', 'Checklist Pendiente'),

  // ... resto de tipos ...
}
```

**Validación:**
- ✅ No romper tipos existentes
- ✅ Mantener nomenclatura snake_case en value
- ✅ Labels descriptivos en español

---

### 2️⃣ Eliminar Archivos Duplicados Mobile

**Acción:** Eliminar completamente:
```bash
rm -rf lib/features/notificaciones/domain/entities/
rm lib/features/notificaciones/domain/repositories/notificaciones_repository.dart
```

**Motivo:** Violación arquitectónica, entities solo en core.

---

### 3️⃣ Crear Contrato Repository (Domain)

**Archivo:** `lib/features/notificaciones/domain/repositories/notificaciones_repository.dart`

```dart
import 'package:ambutrack_core/ambutrack_core.dart'; // ⬅️ Importar del core

abstract class NotificacionesRepository {
  /// Obtiene notificaciones del usuario autenticado
  Future<List<NotificacionEntity>> getNotificaciones({
    int limit = 50,
    bool soloNoLeidas = false,
  });

  /// Obtiene conteo de no leídas
  Future<int> getConteoNoLeidas();

  /// Marca una notificación como leída
  Future<void> marcarComoLeida(String id);

  /// Marca todas como leídas
  Future<void> marcarTodasComoLeidas();

  /// Stream de notificaciones en tiempo real
  Stream<List<NotificacionEntity>> watchNotificaciones();

  /// Stream de conteo no leídas
  Stream<int> watchConteoNoLeidas();

  /// Elimina una notificación
  Future<void> eliminar(String id);
}
```

---

### 4️⃣ Implementar Repository (Data)

**Archivo:** `lib/features/notificaciones/data/repositories/notificaciones_repository_impl.dart`

```dart
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/notificaciones_repository.dart';

@LazySingleton(as: NotificacionesRepository)
class NotificacionesRepositoryImpl implements NotificacionesRepository {
  NotificacionesRepositoryImpl()
      : _dataSource = NotificacionesDataSourceFactory.createSupabase();

  final NotificacionesDataSource _dataSource;

  @override
  Future<List<NotificacionEntity>> getNotificaciones({
    int limit = 50,
    bool soloNoLeidas = false,
  }) async {
    // Obtener usuario autenticado actual
    final usuarioId = await _getCurrentUserId();

    if (soloNoLeidas) {
      return await _dataSource.getNoLeidas(usuarioId);
    }
    return await _dataSource.getByUsuario(usuarioId);
  }

  @override
  Stream<List<NotificacionEntity>> watchNotificaciones() {
    final usuarioId = _getCurrentUserIdSync();
    return _dataSource.watchNotificaciones(usuarioId);
  }

  // ... resto de métodos pass-through ...
}
```

**Principios:**
- ✅ Pass-through directo al datasource
- ✅ NO conversiones Entity↔Entity
- ✅ Obtener `usuarioId` del AuthService
- ✅ Logging con `debugPrint`

---

### 5️⃣ Crear Servicio de Notificaciones Locales

**Archivo:** `lib/features/notificaciones/services/local_notifications_service.dart`

**Responsabilidades:**
- Inicializar `flutter_local_notifications`
- Solicitar permisos (Android 13+, iOS)
- Configurar canales de notificación (Android)
- Mostrar notificación con sonido/vibración
- Manejar tap en notificación (navegación)

**Canales Android:**
1. **Emergencias** (urgente, sonido alto, heads-up, LED rojo)
2. **Traslados** (alta, sonido medio, heads-up)
3. **Información** (normal, sonido bajo)

**Sonidos:**
- Android: Usar sonido por defecto del sistema o custom (`android/app/src/main/res/raw/`)
- iOS: Usar sonido por defecto o custom (`ios/Runner/Resources/`)

**Ejemplo:**
```dart
@singleton
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
  }

  Future<void> mostrarNotificacion({
    required NotificacionEntity notificacion,
  }) async {
    // Determinar canal según tipo
    final channelId = _getChannelId(notificacion.tipo);

    await _plugin.show(
      notificacion.id.hashCode,
      notificacion.titulo,
      notificacion.mensaje,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: _getImportance(notificacion.tipo),
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: _getVibrationPattern(notificacion.tipo),
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
      payload: json.encode({
        'id': notificacion.id,
        'tipo': notificacion.tipo.value,
        'entidadId': notificacion.entidadId,
      }),
    );
  }
}
```

---

### 6️⃣ Crear BLoC de Notificaciones

**Archivos:**
- `lib/features/notificaciones/presentation/bloc/notificaciones_event.dart`
- `lib/features/notificaciones/presentation/bloc/notificaciones_state.dart`
- `lib/features/notificaciones/presentation/bloc/notificaciones_bloc.dart`

**Estados:**
```dart
@freezed
class NotificacionesState with _$NotificacionesState {
  const factory NotificacionesState.initial() = _Initial;
  const factory NotificacionesState.loading() = _Loading;
  const factory NotificacionesState.loaded({
    required List<NotificacionEntity> notificaciones,
    required int conteoNoLeidas,
    @Default(false) bool isRefreshing,
  }) = _Loaded;
  const factory NotificacionesState.error({required String message}) = _Error;
}
```

**Eventos:**
```dart
@freezed
class NotificacionesEvent with _$NotificacionesEvent {
  const factory NotificacionesEvent.started() = _Started;
  const factory NotificacionesEvent.loadRequested() = _LoadRequested;
  const factory NotificacionesEvent.marcarComoLeida(String id) = _MarcarComoLeida;
  const factory NotificacionesEvent.marcarTodasLeidas() = _MarcarTodasLeidas;
  const factory NotificacionesEvent.eliminar(String id) = _Eliminar;
  const factory NotificacionesEvent.realtimeReceived(NotificacionEntity notificacion) = _RealtimeReceived;
}
```

**BLoC:**
- Escuchar stream de Realtime
- Cuando llegue nueva notificación → Mostrar local notification
- Actualizar lista en tiempo real
- Mantener conteo de no leídas

---

### 7️⃣ Crear UI de Notificaciones

#### NotificacionesPage
- AppBar con título "Notificaciones" + botón "Marcar todas leídas"
- Lista scrollable con pull-to-refresh
- Empty state cuando no hay notificaciones
- Skeleton loading

#### NotificacionCard
```dart
class NotificacionCard extends StatelessWidget {
  final NotificacionEntity notificacion;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red, child: Icon(Icons.delete)),
      onDismissed: (_) => onDelete(),
      child: Card(
        color: notificacion.leida ? Colors.white : Colors.blue.shade50,
        child: ListTile(
          leading: _buildIcon(notificacion.tipo),
          title: Text(notificacion.titulo, style: TextStyle(fontWeight: notificacion.leida ? FontWeight.normal : FontWeight.bold)),
          subtitle: Text(notificacion.mensaje),
          trailing: Text(_formatTime(notificacion.createdAt)),
          onTap: onTap,
        ),
      ),
    );
  }
}
```

#### NotificacionBadge (AppBar Widget)
```dart
class NotificacionBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: Icon(Icons.notifications), onPressed: onTap),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text('$count', style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
```

---

### 8️⃣ Integrar con Sistema de Traslados

**Cuando se asigna un traslado al conductor/TES:**

**Backend (Supabase Function/Trigger):**
```sql
-- Función para notificar al personal cuando se le asigna un traslado
CREATE OR REPLACE FUNCTION notificar_traslado_asignado()
RETURNS TRIGGER AS $$
DECLARE
    v_conductor_usuario_id UUID;
    v_conductor_nombre TEXT;
BEGIN
    -- Obtener usuario_id del conductor
    SELECT usuario_id, nombre || ' ' || apellidos
    INTO v_conductor_usuario_id, v_conductor_nombre
    FROM tpersonal
    WHERE id = NEW.conductor_id;

    -- Crear notificación
    IF v_conductor_usuario_id IS NOT NULL THEN
        INSERT INTO tnotificaciones (
            usuario_destino_id,
            tipo,
            titulo,
            mensaje,
            entidad_tipo,
            entidad_id,
            metadata
        ) VALUES (
            v_conductor_usuario_id,
            'traslado_asignado',
            '🚑 Nuevo Traslado Asignado',
            'Se te ha asignado el traslado #' || NEW.numero_servicio || ' - ' || NEW.origen || ' → ' || NEW.destino,
            'traslado',
            NEW.id::TEXT,
            jsonb_build_object('servicio_id', NEW.id, 'numero_servicio', NEW.numero_servicio)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger cuando se asigna un conductor a un traslado
CREATE TRIGGER trigger_notificar_traslado_asignado
    AFTER UPDATE OF conductor_id ON traslados
    FOR EACH ROW
    WHEN (OLD.conductor_id IS DISTINCT FROM NEW.conductor_id AND NEW.conductor_id IS NOT NULL)
    EXECUTE FUNCTION notificar_traslado_asignado();
```

---

### 9️⃣ Permisos (Android/iOS)

#### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

#### iOS (Info.plist)
Ya configurado con `permission_handler`, solo solicitar en runtime.

#### Código Dart (solicitar permisos)
```dart
Future<bool> solicitarPermisos() async {
  if (Platform.isAndroid && await _isAndroid13OrHigher()) {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  if (Platform.isIOS) {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  return true;
}
```

---

### 🔟 Registrar en DI (GetIt)

**Archivo:** `lib/core/di/locator.dart`

```dart
// Servicio de notificaciones locales (singleton)
getIt.registerLazySingleton(() => LocalNotificationsService());

// Repository de notificaciones
getIt.registerLazySingleton<NotificacionesRepository>(
  () => NotificacionesRepositoryImpl(),
);

// BLoC de notificaciones (factory, se crea cada vez)
getIt.registerFactory(() => NotificacionesBloc(
  repository: getIt<NotificacionesRepository>(),
  localNotificationsService: getIt<LocalNotificationsService>(),
));
```

---

### 1️⃣1️⃣ Inicializar en main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(...);

  // Inicializar DI
  await configureDependencies();

  // Inicializar servicio de notificaciones locales
  await getIt<LocalNotificationsService>().initialize();

  // Solicitar permisos (solo primera vez)
  await getIt<LocalNotificationsService>().solicitarPermisos();

  runApp(const AmbuTrackApp());
}
```

---

## 📊 Tabla de Supabase (Actualizar tipos)

**Agregar nuevos tipos al CHECK constraint:**

```sql
ALTER TABLE tnotificaciones DROP CONSTRAINT IF EXISTS tnotificaciones_tipo_check;
ALTER TABLE tnotificaciones ADD CONSTRAINT tnotificaciones_tipo_check CHECK (tipo IN (
    -- Tipos existentes
    'vacacion_solicitada',
    'vacacion_aprobada',
    'vacacion_rechazada',
    'ausencia_solicitada',
    'ausencia_aprobada',
    'ausencia_rechazada',
    'cambio_turno',
    'alerta',
    'info',
    -- ⬇️ NUEVOS TIPOS
    'traslado_asignado',
    'traslado_desadjudicado',
    'traslado_iniciado',
    'traslado_finalizado',
    'traslado_cancelado',
    'checklist_pendiente'
));
```

---

## ✅ Checklist de Implementación

### Core
- [ ] Actualizar `NotificacionTipo` con nuevos tipos de traslados
- [ ] Ejecutar `flutter pub run build_runner build` en core
- [ ] Actualizar tabla Supabase con nuevos tipos

### Mobile - Cleanup
- [ ] Eliminar `lib/features/notificaciones/domain/entities/`
- [ ] Eliminar repository duplicado

### Mobile - Data Layer
- [ ] Crear contrato `NotificacionesRepository` (domain)
- [ ] Crear `NotificacionesRepositoryImpl` (data)
- [ ] Registrar en DI

### Mobile - Services
- [ ] Crear `LocalNotificationsService`
- [ ] Configurar canales Android
- [ ] Configurar sonidos y vibración
- [ ] Implementar navegación desde notificación
- [ ] Solicitar permisos

### Mobile - Presentation
- [ ] Crear eventos con Freezed
- [ ] Crear estados con Freezed
- [ ] Crear `NotificacionesBloc`
- [ ] Implementar listener de Realtime
- [ ] Crear `NotificacionesPage`
- [ ] Crear `NotificacionCard`
- [ ] Crear `NotificacionBadge`
- [ ] Integrar badge en AppBar principal

### Backend (Supabase)
- [ ] Crear función `notificar_traslado_asignado()`
- [ ] Crear trigger en tabla `traslados`
- [ ] Crear función `notificar_traslado_desadjudicado()`
- [ ] Probar con datos reales

### Testing
- [ ] Unit tests para BLoC
- [ ] Unit tests para Repository
- [ ] Widget tests para UI
- [ ] Prueba E2E: Asignar traslado → Recibir notificación

### Validación Final
- [ ] `flutter analyze` → 0 warnings
- [ ] Probar en dispositivo Android real
- [ ] Probar en dispositivo iOS real (si hay)
- [ ] Verificar sonido y vibración
- [ ] Verificar navegación desde notificación
- [ ] Verificar badge actualiza correctamente

---

## 🚨 Reglas Críticas a Seguir

1. ✅ **NUNCA duplicar entities** → Usar solo core
2. ✅ **Pass-through en repository** → Sin conversiones Entity↔Entity
3. ✅ **AppColors para colores** → No hardcodear
4. ✅ **debugPrint para logs** → NUNCA `print()`
5. ✅ **Material 3 widgets** → No Cupertino
6. ✅ **SafeArea obligatorio** → En todas las páginas
7. ✅ **BLoC para estado** → No StatefulWidget innecesario
8. ✅ **Widgets como clases** → NO métodos `_buildXxx()`
9. ✅ **flutter analyze = 0 warnings** → ANTES de terminar

---

## 📚 Referencias

- Core DataSource: `packages/ambutrack_core/lib/src/datasources/notificaciones/`
- Tabla Supabase: `tnotificaciones`
- Flutter Local Notifications: https://pub.dev/packages/flutter_local_notifications
- Supabase Realtime: https://supabase.com/docs/guides/realtime
- Permission Handler: https://pub.dev/packages/permission_handler

---

## 🎯 Resultado Esperado

Al finalizar:
- ✅ Conductor/TES recibe notificación instantánea cuando se le asigna traslado
- ✅ Suena notificación + vibración personalizada según prioridad
- ✅ Badge en AppBar muestra conteo de no leídas
- ✅ Lista de notificaciones en tiempo real
- ✅ Tap en notificación navega al traslado correspondiente
- ✅ Deslizar para eliminar notificación
- ✅ Arquitectura limpia siguiendo patrones del proyecto
- ✅ 0 warnings en `flutter analyze`

---

**¿Listo para implementar? 🚀**
