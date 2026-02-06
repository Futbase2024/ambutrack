import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logging/app_logger.dart';

/// Estados posibles de la conexión Realtime
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// Estado de conexión con metadatos
class RealtimeConnectionState {
  final ConnectionStatus status;
  final int attemptCount;
  final DateTime? lastConnected;
  final String? error;

  const RealtimeConnectionState({
    required this.status,
    this.attemptCount = 0,
    this.lastConnected,
    this.error,
  });

  RealtimeConnectionState copyWith({
    ConnectionStatus? status,
    int? attemptCount,
    DateTime? lastConnected,
    String? error,
  }) {
    return RealtimeConnectionState(
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastConnected: lastConnected ?? this.lastConnected,
      error: error ?? this.error,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting =>
      status == ConnectionStatus.connecting ||
      status == ConnectionStatus.reconnecting;
  bool get hasFailed => status == ConnectionStatus.failed;
}

/// Gestiona la conexión Realtime con reconexión automática
///
/// Características:
/// - Backoff exponencial (2s, 4s, 8s, 16s, 32s, max 60s)
/// - Máximo 10 intentos de reconexión
/// - Stream de estados para UI reactiva
/// - Logging estructurado
///
/// Uso:
/// ```dart
/// final manager = RealtimeConnectionManager();
///
/// // Escuchar estados
/// manager.connectionState.listen((state) {
///   print('Estado: ${state.status}');
/// });
///
/// // Notificar estado de subscribe
/// channel.subscribe((status, error) {
///   manager.onSubscribeStatus(status, error);
/// });
///
/// // Manejar reconexión
/// if (manager.needsReconnect) {
///   await manager.reconnect(() async {
///     // Recrear canal aquí
///   });
/// }
/// ```
class RealtimeConnectionManager {
  static const String _tag = 'ConnectionManager';
  static const int _maxReconnectAttempts = 10;
  static const int _maxBackoffSeconds = 60;
  static const List<int> _backoffSequence = [2, 4, 8, 16, 32];

  final _stateController = StreamController<RealtimeConnectionState>.broadcast();

  RealtimeConnectionState _currentState = const RealtimeConnectionState(
    status: ConnectionStatus.disconnected,
  );

  Timer? _reconnectTimer;
  Function()? _reconnectCallback;

  /// Stream de estados de conexión para UI
  Stream<RealtimeConnectionState> get connectionState => _stateController.stream;

  /// Estado actual de conexión
  RealtimeConnectionState get currentState => _currentState;

  /// Si necesita reconexión
  bool get needsReconnect =>
      _currentState.status == ConnectionStatus.reconnecting;

  /// Notificar estado de suscripción desde channel.subscribe()
  void onSubscribeStatus(RealtimeSubscribeStatus status, [Object? error]) {
    if (status == RealtimeSubscribeStatus.subscribed) {
      _onConnected();
    } else if (status == RealtimeSubscribeStatus.channelError) {
      _onError(error);
    } else if (status == RealtimeSubscribeStatus.timedOut) {
      _onError('Timeout');
    } else if (status == RealtimeSubscribeStatus.closed) {
      _onDisconnected();
    }
  }

  /// Marcar como conectado y resetear intentos
  void _onConnected() {
    AppLogger.info('Conexión establecida', tag: _tag);

    _updateState(
      ConnectionStatus.connected,
      attemptCount: 0,
      error: null,
    );

    _reconnectTimer?.cancel();
  }

  /// Manejar error de conexión
  void _onError(Object? error) {
    AppLogger.error(
      'Error en canal Realtime',
      error,
      null,
      tag: _tag,
    );

    _scheduleReconnect(error?.toString());
  }

  /// Manejar desconexión
  void _onDisconnected() {
    if (_currentState.status == ConnectionStatus.failed) {
      return; // Ya estamos en estado failed
    }

    AppLogger.warning('Conexión cerrada', tag: _tag);
    _scheduleReconnect();
  }

  /// Programar intento de reconexión con backoff exponencial
  void _scheduleReconnect([String? error]) {
    // Cancelar timer anterior si existe
    _reconnectTimer?.cancel();

    final attemptCount = _currentState.attemptCount + 1;

    // Verificar límite de intentos
    if (attemptCount > _maxReconnectAttempts) {
      AppLogger.error(
        'Máximo de intentos alcanzado ($_maxReconnectAttempts)',
        'Reconexión fallida',
        null,
        tag: _tag,
      );
      _updateState(
        ConnectionStatus.failed,
        attemptCount: attemptCount,
        error: error ?? 'Máximo de intentos de reconexión alcanzado',
      );
      return;
    }

    // Calcular delay con backoff exponencial
    final backoffIndex =
        (attemptCount - 1).clamp(0, _backoffSequence.length - 1);
    final baseDelay = _backoffSequence[backoffIndex];
    final delay = baseDelay.clamp(0, _maxBackoffSeconds);

    AppLogger.info(
      'Intento de reconexión $attemptCount/$_maxReconnectAttempts en ${delay}s',
      tag: _tag,
    );

    _updateState(
      ConnectionStatus.reconnecting,
      attemptCount: attemptCount,
      error: error,
    );

    // Programar reconexión
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _triggerReconnect();
    });
  }

  /// Disparar callback de reconexión
  void _triggerReconnect() {
    AppLogger.info('Ejecutando reconexión...', tag: _tag);

    if (_reconnectCallback != null) {
      _reconnectCallback!();
    } else {
      AppLogger.warning(
        'No hay callback de reconexión registrado',
        tag: _tag,
      );
    }
  }

  /// Registrar callback que se ejecutará en cada intento de reconexión
  ///
  /// El callback debe recrear el canal y llamar a subscribe()
  void onReconnect(Future<void> Function() callback) {
    _reconnectCallback = () async {
      try {
        await callback();
        AppLogger.info('Callback de reconexión ejecutado', tag: _tag);
      } catch (error, stackTrace) {
        AppLogger.failOperation(
          'Callback de reconexión',
          error,
          stackTrace,
          tag: _tag,
        );
        _scheduleReconnect(error.toString());
      }
    };
  }

  /// Forzar reconexión manual
  void forceReconnect() {
    AppLogger.info('Reconexión manual solicitada', tag: _tag);

    // Resetear contador de intentos
    _updateState(
      ConnectionStatus.reconnecting,
      attemptCount: 0,
      error: null,
    );

    _triggerReconnect();
  }

  /// Actualizar estado y emitir por stream
  void _updateState(
    ConnectionStatus status, {
    int? attemptCount,
    String? error,
  }) {
    _currentState = _currentState.copyWith(
      status: status,
      attemptCount: attemptCount,
      lastConnected: status == ConnectionStatus.connected
          ? DateTime.now()
          : _currentState.lastConnected,
      error: error,
    );

    _stateController.add(_currentState);

    // Log cambio de estado
    final emoji = _getStatusEmoji(status);
    AppLogger.info(
      '$emoji Estado: $status (intentos: ${_currentState.attemptCount})',
      tag: _tag,
    );
  }

  /// Obtener emoji para estado
  String _getStatusEmoji(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return '✅';
      case ConnectionStatus.connecting:
        return '🔄';
      case ConnectionStatus.reconnecting:
        return '🔁';
      case ConnectionStatus.disconnected:
        return '⚪';
      case ConnectionStatus.failed:
        return '❌';
    }
  }

  /// Limpiar recursos
  void dispose() {
    AppLogger.info('Limpiando ConnectionManager', tag: _tag);

    _reconnectTimer?.cancel();
    _stateController.close();
  }
}
