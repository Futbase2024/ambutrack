import 'package:flutter/material.dart';
import 'connection_manager.dart';

/// Widget que muestra el estado de la conexión Realtime
///
/// Diseño:
/// - Conectado: Badge verde discreto con icono ✓
/// - Conectando/Reconectando: Badge amarillo con spinner
/// - Desconectado: No se muestra
/// - Error: Badge rojo con icono ! y opción de reconexión manual
///
/// Uso:
/// ```dart
/// ConnectionStatusIndicator(
///   connectionManager: manager,
/// )
/// ```
class ConnectionStatusIndicator extends StatelessWidget {
  final RealtimeConnectionManager connectionManager;
  final bool showWhenConnected;

  const ConnectionStatusIndicator({
    super.key,
    required this.connectionManager,
    this.showWhenConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimeConnectionState>(
      stream: connectionManager.connectionState,
      initialData: connectionManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null) return const SizedBox.shrink();

        // No mostrar nada si está desconectado o conectado (opcional)
        if (state.status == ConnectionStatus.disconnected) {
          return const SizedBox.shrink();
        }

        if (state.status == ConnectionStatus.connected && !showWhenConnected) {
          return const SizedBox.shrink();
        }

        return _buildIndicator(context, state);
      },
    );
  }

  Widget _buildIndicator(BuildContext context, RealtimeConnectionState state) {
    final config = _getConfig(state.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(config, state),
          const SizedBox(width: 8),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.status == ConnectionStatus.failed) ...[
            const SizedBox(width: 8),
            _buildRetryButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(_StatusConfig config, RealtimeConnectionState state) {
    if (state.isConnecting) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(config.color),
        ),
      );
    }

    return Icon(
      config.icon,
      size: 14,
      color: config.color,
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return InkWell(
      onTap: () => connectionManager.forceReconnect(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 12,
              color: Colors.red,
            ),
            SizedBox(width: 4),
            Text(
              'Reintentar',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getConfig(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return const _StatusConfig(
          label: 'Conectado',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case ConnectionStatus.connecting:
        return const _StatusConfig(
          label: 'Conectando...',
          color: Colors.orange,
          icon: Icons.wifi_find,
        );
      case ConnectionStatus.reconnecting:
        return const _StatusConfig(
          label: 'Reconectando...',
          color: Colors.orange,
          icon: Icons.sync,
        );
      case ConnectionStatus.failed:
        return const _StatusConfig(
          label: 'Sin conexión',
          color: Colors.red,
          icon: Icons.error,
        );
      case ConnectionStatus.disconnected:
        return const _StatusConfig(
          label: 'Desconectado',
          color: Colors.grey,
          icon: Icons.cloud_off,
        );
    }
  }
}

/// Configuración de estilo para cada estado
class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Versión compacta del indicador (solo icono)
class ConnectionStatusIcon extends StatelessWidget {
  final RealtimeConnectionManager connectionManager;

  const ConnectionStatusIcon({
    super.key,
    required this.connectionManager,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RealtimeConnectionState>(
      stream: connectionManager.connectionState,
      initialData: connectionManager.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null ||
            state.status == ConnectionStatus.disconnected ||
            state.status == ConnectionStatus.connected) {
          return const SizedBox.shrink();
        }

        final config = _getConfig(state.status);

        return Tooltip(
          message: config.label,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: state.isConnecting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(config.color),
                    ),
                  )
                : Icon(
                    config.icon,
                    size: 16,
                    color: config.color,
                  ),
          ),
        );
      },
    );
  }

  _StatusConfig _getConfig(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return const _StatusConfig(
          label: 'Conectado',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case ConnectionStatus.connecting:
        return const _StatusConfig(
          label: 'Conectando...',
          color: Colors.orange,
          icon: Icons.wifi_find,
        );
      case ConnectionStatus.reconnecting:
        return const _StatusConfig(
          label: 'Reconectando...',
          color: Colors.orange,
          icon: Icons.sync,
        );
      case ConnectionStatus.failed:
        return const _StatusConfig(
          label: 'Sin conexión',
          color: Colors.red,
          icon: Icons.error,
        );
      case ConnectionStatus.disconnected:
        return const _StatusConfig(
          label: 'Desconectado',
          color: Colors.grey,
          icon: Icons.cloud_off,
        );
    }
  }
}
