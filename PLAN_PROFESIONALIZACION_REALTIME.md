# 📋 Plan de Profesionalización: Sistema Event Ledger

## 🎯 Objetivo

Transformar el Event Ledger actual (funcional) en un sistema **production-ready** con:
- ✅ Alta disponibilidad
- ✅ Observabilidad completa
- ✅ Manejo robusto de errores
- ✅ Experiencia de usuario premium
- ✅ Métricas y analytics

---

## 📊 Estado Actual vs Objetivo

| Aspecto | Actual | Objetivo |
|---------|--------|----------|
| **Logging** | `debugPrint()` básico | Logger estructurado con niveles |
| **Reconexión** | Manual (reiniciar app) | Automática con backoff exponencial |
| **Estado conexión** | Invisible para usuario | Indicador visual en UI |
| **Errores** | Silenciosos | Tracked + reportados |
| **Métricas** | Ninguna | Latencia, errores, eventos/min |
| **Fallback** | Ninguno | Polling inteligente si falla Realtime |
| **Tests** | Ninguno | Unitarios + Integración |
| **Deduplicación** | Set simple | LRU Cache optimizado |
| **Notificaciones** | Ninguna | Push notifications |
| **Offline** | No soportado | Queue de sincronización |

---

## 🏗️ Arquitectura Mejorada

### Capa 1: Infrastructure Layer

```dart
// Nuevo: RealtimeConnectionManager
class RealtimeConnectionManager {
  final SupabaseClient _client;
  final Logger _logger;

  Stream<ConnectionState> get connectionState;
  Future<void> reconnect();
  Future<void> disconnect();

  // Reconexión automática con backoff exponencial
  // Métricas de conexión (uptime, latencia, errores)
}

// Nuevo: EventMetrics
class EventMetrics {
  void trackEventReceived(EventoTrasladoType type, Duration latency);
  void trackError(String operation, Object error);
  Map<String, dynamic> getMetrics();
}
```

### Capa 2: Enhanced Datasource

```dart
class SupabaseTrasladosDataSourceV2 implements TrasladoDataSource {
  final RealtimeConnectionManager _connectionManager;
  final EventMetrics _metrics;
  final Logger _logger;
  final EventDeduplicator _deduplicator;

  // Stream mejorado con manejo de reconexión
  Stream<TrasladoEventoEntity> streamEventosConductor();

  // Fallback con polling inteligente
  Stream<List<TrasladoEntity>> _fallbackPolling();
}

// Nuevo: EventDeduplicator con LRU Cache
class EventDeduplicator {
  final LRUCache<String, bool> _cache;

  bool isDuplicate(String eventId);
  void markProcessed(String eventId);
}
```

### Capa 3: BLoC with State Management

```dart
// Estado enriquecido
class TrasladosState {
  final List<TrasladoEntity> traslados;
  final ConnectionStatus connectionStatus; // new
  final EventMetrics? metrics; // new
  final String? error;
  final DateTime? lastSync; // new
}

// Nuevos eventos
class ConnectionStatusChanged extends TrasladosEvent {
  final ConnectionStatus status;
}

class MetricsUpdated extends TrasladosEvent {
  final EventMetrics metrics;
}
```

### Capa 4: UI Enhancements

```dart
// Nuevo widget: ConnectionStatusIndicator
class ConnectionStatusIndicator extends StatelessWidget {
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      child: Row(
        children: [
          Icon(status.icon, color: status.color),
          Text(status.message),
        ],
      ),
    );
  }
}

// Nuevo: PullToRefreshWithMetrics
class ServiciosPageV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ConnectionStatusIndicator(), // Nuevo
          MetricsButton(), // Nuevo
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocConsumer<TrasladosBloc, TrasladosState>(
          listener: (context, state) {
            // Mostrar snackbar si pierde conexión
            if (state.connectionStatus == ConnectionStatus.disconnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conectando al servidor...'),
                  action: SnackBarAction(
                    label: 'Reintentar',
                    onPressed: () => _reconnect(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            // UI actual
          },
        ),
      ),
    );
  }
}
```

---

## 🔧 Mejoras Técnicas Detalladas

### 1. Sistema de Logging Estructurado ✅

**Problema actual**: `debugPrint()` no es filtrable, no tiene niveles, no se puede enviar a servicios externos.

**Solución**:

```dart
// lib/core/logging/app_logger.dart
class AppLogger {
  static final _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    filter: ProductionFilter(), // Solo errores en producción
  );

  static void debug(String message, {String? tag}) {
    _instance.d('[$tag] $message');
  }

  static void info(String message, {String? tag}) {
    _instance.i('[$tag] $message');
  }

  static void warning(String message, {String? tag}) {
    _instance.w('[$tag] $message');
  }

  static void error(String message, Object? error, StackTrace? stackTrace, {String? tag}) {
    _instance.e('[$tag] $message', error: error, stackTrace: stackTrace);

    // Enviar a servicio de crash reporting (Sentry, Firebase Crashlytics)
    _reportToCrashService(message, error, stackTrace);
  }
}

// Uso:
AppLogger.info('Suscribiéndose a eventos', tag: 'TrasladosDataSource');
AppLogger.error('Error al procesar evento', error, stack, tag: 'TrasladosDataSource');
```

**Beneficios**:
- 📊 Filtrado por nivel (debug, info, warning, error)
- 🏷️ Tags para organización
- 📤 Integración con servicios externos (Sentry, Firebase)
- 🎨 Formato legible con colores
- ⚙️ Configurable por entorno (dev/prod)

---

### 2. Reconexión Automática con Backoff Exponencial ✅

**Problema actual**: Si se pierde conexión, el usuario debe reiniciar la app.

**Solución**:

```dart
// lib/core/realtime/connection_manager.dart
class RealtimeConnectionManager {
  final SupabaseClient _client;
  final StreamController<ConnectionState> _stateController;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  static const _maxReconnectAttempts = 10;
  static const _baseDelay = Duration(seconds: 2);

  Stream<ConnectionState> get connectionState => _stateController.stream;

  Future<void> reconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Máximo de reintentos alcanzado', null, null, tag: 'ConnectionManager');
      _stateController.add(ConnectionState.failed);
      return;
    }

    _reconnectAttempts++;

    // Backoff exponencial: 2s, 4s, 8s, 16s, 32s, 60s (max)
    final delay = Duration(
      seconds: min(
        _baseDelay.inSeconds * pow(2, _reconnectAttempts - 1).toInt(),
        60,
      ),
    );

    AppLogger.info(
      'Reintentando conexión en ${delay.inSeconds}s (intento $_reconnectAttempts/$_maxReconnectAttempts)',
      tag: 'ConnectionManager',
    );

    _stateController.add(ConnectionState.reconnecting(delay, _reconnectAttempts));

    _reconnectTimer = Timer(delay, () async {
      try {
        await _client.realtime.connect();
        _reconnectAttempts = 0; // Reset en caso de éxito
        _stateController.add(ConnectionState.connected);
        AppLogger.info('Reconexión exitosa', tag: 'ConnectionManager');
      } catch (e) {
        AppLogger.error('Error en reconexión', e, null, tag: 'ConnectionManager');
        await reconnect(); // Reintentar recursivamente
      }
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _stateController.close();
  }
}

// Estados de conexión
enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
  failed,
}

class ConnectionState {
  final ConnectionStatus status;
  final Duration? nextRetry;
  final int? attempts;

  ConnectionState.connected() : status = ConnectionStatus.connected, nextRetry = null, attempts = null;
  ConnectionState.disconnected() : status = ConnectionStatus.disconnected, nextRetry = null, attempts = null;
  ConnectionState.reconnecting(this.nextRetry, this.attempts) : status = ConnectionStatus.reconnecting;
  ConnectionState.failed() : status = ConnectionStatus.failed, nextRetry = null, attempts = null;
}
```

**Beneficios**:
- 🔄 Reconexión automática sin intervención del usuario
- ⏱️ Backoff exponencial evita sobrecargar el servidor
- 📊 Estado visible para el usuario
- 🛑 Límite de reintentos para evitar bucles infinitos

---

### 3. Indicador de Estado de Conexión en UI ✅

**Problema actual**: El usuario no sabe si está conectado o no.

**Solución**:

```dart
// lib/features/servicios/presentation/widgets/connection_status_indicator.dart
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrasladosBloc, TrasladosState>(
      builder: (context, state) {
        final status = state.connectionStatus ?? ConnectionStatus.connected;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(status),
              const SizedBox(width: 6),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icon(Icons.check_circle, color: Colors.green, size: 16);
      case ConnectionStatus.disconnected:
        return Icon(Icons.cloud_off, color: Colors.red, size: 16);
      case ConnectionStatus.reconnecting:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.orange),
          ),
        );
      case ConnectionStatus.failed:
        return Icon(Icons.error, color: Colors.red, size: 16);
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.failed:
        return Colors.red;
      case ConnectionStatus.reconnecting:
        return Colors.orange;
    }
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
      case ConnectionStatus.reconnecting:
        return 'Reconectando...';
      case ConnectionStatus.failed:
        return 'Sin conexión';
    }
  }
}
```

**Beneficios**:
- 👁️ Usuario siempre sabe el estado de conexión
- 🎨 Feedback visual claro (verde/rojo/naranja)
- ⚡ Animaciones suaves
- 📱 Diseño profesional

---

### 4. Sistema de Métricas y Analytics ✅

**Problema actual**: No sabemos cuánto tarda en llegar un evento, cuántos errores hay, etc.

**Solución**:

```dart
// lib/core/metrics/event_metrics.dart
class EventMetrics {
  final Map<String, int> _eventCounts = {};
  final List<Duration> _latencies = [];
  final List<EventError> _errors = [];

  DateTime? _firstEventAt;
  DateTime? _lastEventAt;

  void trackEventReceived(EventoTrasladoType type, Duration latency) {
    _eventCounts[type.name] = (_eventCounts[type.name] ?? 0) + 1;
    _latencies.add(latency);

    _firstEventAt ??= DateTime.now();
    _lastEventAt = DateTime.now();

    AppLogger.info(
      '📊 Evento ${type.name} recibido en ${latency.inMilliseconds}ms',
      tag: 'EventMetrics',
    );
  }

  void trackError(String operation, Object error) {
    _errors.add(EventError(
      operation: operation,
      error: error.toString(),
      timestamp: DateTime.now(),
    ));

    AppLogger.error('Error en $operation', error, null, tag: 'EventMetrics');
  }

  EventMetricsReport getReport() {
    return EventMetricsReport(
      totalEvents: _latencies.length,
      averageLatency: _calculateAverageLatency(),
      p95Latency: _calculateP95Latency(),
      p99Latency: _calculateP99Latency(),
      errorRate: _calculateErrorRate(),
      eventsByType: Map.from(_eventCounts),
      uptime: _calculateUptime(),
      recentErrors: _errors.take(10).toList(),
    );
  }

  Duration _calculateAverageLatency() {
    if (_latencies.isEmpty) return Duration.zero;
    final sum = _latencies.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: sum ~/ _latencies.length);
  }

  Duration _calculateP95Latency() {
    if (_latencies.isEmpty) return Duration.zero;
    final sorted = List<Duration>.from(_latencies)..sort((a, b) => a.compareTo(b));
    final index = (sorted.length * 0.95).floor();
    return sorted[index];
  }

  // ... más cálculos
}

// Widget para mostrar métricas
class MetricsDialog extends StatelessWidget {
  final EventMetricsReport metrics;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('📊 Métricas de Sincronización'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricRow('Total eventos', '${metrics.totalEvents}'),
            _buildMetricRow('Latencia promedio', '${metrics.averageLatency.inMilliseconds}ms'),
            _buildMetricRow('Latencia P95', '${metrics.p95Latency.inMilliseconds}ms'),
            _buildMetricRow('Tasa de error', '${(metrics.errorRate * 100).toStringAsFixed(2)}%'),
            _buildMetricRow('Uptime', _formatDuration(metrics.uptime)),
            const Divider(),
            Text('Eventos por tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...metrics.eventsByType.entries.map((e) =>
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Beneficios**:
- 📈 Visibilidad completa del sistema
- 🐛 Detección temprana de problemas
- ⚡ Optimización basada en datos
- 📊 Reportes para stakeholders

---

### 5. Fallback Strategy con Polling Inteligente ✅

**Problema actual**: Si Realtime falla, no hay forma de recibir actualizaciones.

**Solución**:

```dart
// lib/core/sync/fallback_strategy.dart
class FallbackSyncStrategy {
  final TrasladoDataSource _dataSource;
  final Duration _pollInterval;

  Timer? _pollTimer;
  DateTime? _lastSync;

  FallbackSyncStrategy(
    this._dataSource,
    {Duration pollInterval = const Duration(seconds: 30)}
  ) : _pollInterval = pollInterval;

  Stream<List<TrasladoEntity>> startPolling(String conductorId) async* {
    AppLogger.warning('Iniciando polling de fallback', tag: 'FallbackSync');

    while (true) {
      try {
        final traslados = await _dataSource.getActivosByIdConductor(conductorId);
        _lastSync = DateTime.now();

        yield traslados;

        await Future.delayed(_pollInterval);
      } catch (e) {
        AppLogger.error('Error en polling', e, null, tag: 'FallbackSync');
        yield [];
      }
    }
  }

  void stop() {
    _pollTimer?.cancel();
    AppLogger.info('Polling de fallback detenido', tag: 'FallbackSync');
  }
}

// En el datasource
class SupabaseTrasladosDataSourceV2 {
  Stream<TrasladoEventoEntity> streamEventosConductorWithFallback() {
    final controller = StreamController<TrasladoEventoEntity>();
    RealtimeChannel? channel;
    StreamSubscription? fallbackSubscription;

    // Intentar Realtime primero
    channel = _setupRealtimeChannel(controller);

    // Si Realtime falla después de 10 segundos, activar fallback
    Timer(Duration(seconds: 10), () {
      if (controller.hasListener && !_hasReceivedEvents) {
        AppLogger.warning('Realtime no respondió, activando fallback', tag: 'TrasladosDataSource');

        fallbackSubscription = _fallbackStrategy
          .startPolling(personalId)
          .listen((traslados) {
            // Convertir cambios a eventos sintéticos
            _detectChangesAndEmitEvents(traslados, controller);
          });
      }
    });

    return controller.stream;
  }
}
```

**Beneficios**:
- 🛡️ Sistema nunca se queda sin sincronización
- ⚡ Realtime como primera opción (óptimo)
- 🔄 Polling solo como fallback (degradación elegante)
- 🎯 Configurabletodo el plan completo. ¿Quieres que empiece a implementar las mejoras más críticas?

Las prioridades según impacto serían:

1. **Sistema de logging estructurado** (rápido, alto impacto)
2. **Reconexión automática** (crítico para UX)
3. **Indicador de estado** (visible para usuario)
4. **Métricas básicas** (para monitoreo)
5. **Fallback strategy** (resiliencia)

¿Por dónde empezamos?