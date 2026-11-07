import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de caducidades
///
/// Gestiona el acceso a stock con caducidades, alertas y reposiciones
abstract class CaducidadesRepository {
  /// Obtiene stock de un vehículo filtrado por estado de caducidad
  ///
  /// [vehiculoId] ID del vehículo
  /// [estadoCaducidad] Filtro opcional: null = todos, 'ok', 'proximo', 'critico', 'caducado'
  Future<List<StockVehiculoEntity>> getStockConCaducidades({
    required String vehiculoId,
    String? estadoCaducidad,
  });

  /// Obtiene alertas activas de caducidad de un vehículo
  ///
  /// [vehiculoId] ID del vehículo
  Future<List<AlertaStockEntity>> getAlertasCaducidad({
    required String vehiculoId,
  });

  /// Solicita reposición de un item caducado/próximo a caducar
  ///
  /// Registra un movimiento de stock manual con motivo "Reposición por caducidad"
  /// [vehiculoId] ID del vehículo
  /// [productoId] ID del producto
  /// [cantidadSolicitada] Cantidad a reponer
  /// [motivo] Motivo de la solicitud
  /// [usuarioId] ID del usuario que solicita
  Future<void> solicitarReposicion({
    required String vehiculoId,
    required String productoId,
    required int cantidadSolicitada,
    required String motivo,
    required String usuarioId,
  });

  /// Registra incidencia de caducidad
  ///
  /// [vehiculoId] ID del vehículo
  /// [titulo] Título de la incidencia
  /// [descripcion] Descripción detallada
  /// [reportadoPor] ID del usuario que reporta
  /// [reportadoPorNombre] Nombre del usuario en MAYÚSCULAS
  /// [empresaId] ID de la empresa
  Future<IncidenciaVehiculoEntity> registrarIncidencia({
    required String vehiculoId,
    required String titulo,
    required String descripcion,
    required String reportadoPor,
    required String reportadoPorNombre,
    required String empresaId,
  });

  /// Resuelve una alerta de caducidad
  ///
  /// [alertaId] ID de la alerta
  /// [usuarioId] ID del usuario que resuelve
  Future<void> resolverAlerta({
    required String alertaId,
    required String usuarioId,
  });

  /// Actualiza un item de stock
  ///
  /// [stock] Item de stock a actualizar
  Future<StockVehiculoEntity> actualizarItem({
    required StockVehiculoEntity stock,
  });

  /// Elimina un item de stock (establece cantidad en 0)
  ///
  /// [vehiculoId] ID del vehículo
  /// [productoId] ID del producto
  /// [usuarioId] ID del usuario que elimina
  /// [motivo] Motivo de eliminación
  Future<void> eliminarItem({
    required String vehiculoId,
    required String productoId,
    required String usuarioId,
    required String motivo,
  });
}
