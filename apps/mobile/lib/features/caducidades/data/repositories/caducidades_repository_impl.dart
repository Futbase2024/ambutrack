import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../domain/repositories/caducidades_repository.dart';

/// Implementación del repositorio de caducidades
///
/// Pass-through directo al StockDataSource e IncidenciaVehiculoDataSource
@LazySingleton(as: CaducidadesRepository)
class CaducidadesRepositoryImpl implements CaducidadesRepository {
  CaducidadesRepositoryImpl()
      : _stockDataSource = StockDataSourceFactory.createSupabase(),
        _incidenciaDataSource =
            IncidenciaVehiculoDataSourceFactory.createSupabase(),
        _equipamientoDataSource =
            EquipamientoVehiculoDataSourceFactory.createSupabase();

  final StockDataSource _stockDataSource;
  final EquipamientoVehiculoDataSource _equipamientoDataSource;
  final IncidenciaVehiculoDataSource _incidenciaDataSource;
  final _uuid = const Uuid();

  @override
  Future<List<StockVehiculoEntity>> getStockConCaducidades({
    required String vehiculoId,
    String? estadoCaducidad,
  }) async {
    debugPrint('📦 CaducidadesRepository: Obteniendo stock con caducidades...');
    debugPrint('   - Vehículo: $vehiculoId');
    debugPrint('   - Filtro estado: ${estadoCaducidad ?? 'todos'}');

    // Obtener stock del vehículo
    final stock = await _stockDataSource.getStockVehiculo(vehiculoId);

    // Filtrar por estado de caducidad si se especifica
    if (estadoCaducidad != null) {
      final stockFiltrado = stock
          .where(
            (item) => item.estadoCaducidad == estadoCaducidad,
          )
          .toList();

      debugPrint(
        '✅ CaducidadesRepository: ${stockFiltrado.length} items filtrados',
      );
      return stockFiltrado;
    }

    // Filtrar solo items con fecha de caducidad
    final stockConCaducidad = stock
        .where(
          (item) => item.fechaCaducidad != null,
        )
        .toList();

    debugPrint(
      '✅ CaducidadesRepository: ${stockConCaducidad.length} items con caducidad',
    );
    return stockConCaducidad;
  }

  @override
  Future<List<AlertaStockEntity>> getAlertasCaducidad({
    required String vehiculoId,
  }) async {
    debugPrint('⚠️ CaducidadesRepository: Obteniendo alertas de caducidad...');

    final alertas = await _stockDataSource.getAlertasVehiculo(vehiculoId);

    // Filtrar solo alertas de caducidad
    final alertasCaducidad = alertas
        .where(
          (alerta) =>
              alerta.tipoAlerta == TipoAlerta.caducidadProxima ||
              alerta.tipoAlerta == TipoAlerta.caducado,
        )
        .toList();

    debugPrint(
      '✅ CaducidadesRepository: ${alertasCaducidad.length} alertas de caducidad',
    );
    return alertasCaducidad;
  }

  @override
  Future<void> solicitarReposicion({
    required String vehiculoId,
    required String productoId,
    required int cantidadSolicitada,
    required String motivo,
    required String usuarioId,
  }) async {
    debugPrint('📝 CaducidadesRepository: Solicitando reposición...');
    debugPrint('   - Producto: $productoId');
    debugPrint('   - Cantidad: $cantidadSolicitada');

    // Registrar movimiento manual con motivo de reposición por caducidad
    await _stockDataSource.registrarStockManual(
      vehiculoId: vehiculoId,
      productoId: productoId,
      cantidad: 0, // 0 porque es solo solicitud, no entrada real
      motivo: 'SOLICITUD REPOSICIÓN POR CADUCIDAD: $motivo',
      usuarioId: usuarioId,
    );

    debugPrint('✅ CaducidadesRepository: Solicitud de reposición registrada');
  }

  @override
  Future<IncidenciaVehiculoEntity> registrarIncidencia({
    required String vehiculoId,
    required String titulo,
    required String descripcion,
    required String reportadoPor,
    required String reportadoPorNombre,
    required String empresaId,
  }) async {
    debugPrint('🚨 CaducidadesRepository: Registrando incidencia de caducidad...');

    final incidencia = IncidenciaVehiculoEntity(
      id: _uuid.v4(),
      vehiculoId: vehiculoId,
      reportadoPor: reportadoPor,
      reportadoPorNombre: reportadoPorNombre.toUpperCase(), // ✅ MAYÚSCULAS
      fechaReporte: DateTime.now(),
      tipo: TipoIncidencia.equipamiento, // Tipo específico
      prioridad: PrioridadIncidencia.alta, // Alta por defecto para caducidades
      estado: EstadoIncidencia.reportada,
      titulo: titulo,
      descripcion: descripcion,
      empresaId: empresaId,
      createdAt: DateTime.now(),
    );

    debugPrint('   - Tipo: ${incidencia.tipo.nombre}');
    debugPrint('   - Prioridad: ${incidencia.prioridad.nombre}');

    final creada = await _incidenciaDataSource.create(incidencia);
    debugPrint('✅ CaducidadesRepository: Incidencia creada con ID ${creada.id}');

    return creada;
  }

  @override
  Future<void> resolverAlerta({
    required String alertaId,
    required String usuarioId,
  }) async {
    debugPrint('✅ CaducidadesRepository: Resolviendo alerta $alertaId...');
    await _stockDataSource.resolverAlerta(alertaId, usuarioId);
    debugPrint('✅ CaducidadesRepository: Alerta resuelta');
  }

  @override
  Future<StockVehiculoEntity> actualizarItem({
    required StockVehiculoEntity stock,
  }) async {
    debugPrint('📝 CaducidadesRepository: Actualizando item ${stock.id}...');
    debugPrint('   - Producto: ${stock.productoNombre}');
    debugPrint('   - Cantidad: ${stock.cantidadActual}');
    debugPrint('   - Fecha caducidad: ${stock.fechaCaducidad}');
    debugPrint('   - Lote: ${stock.lote}');

    final actualizado = await _stockDataSource.updateStock(stock);
    debugPrint('✅ CaducidadesRepository: Item actualizado');

    return actualizado;
  }

  @override
  Future<void> eliminarItem({
    required String vehiculoId,
    required String productoId,
    required String usuarioId,
    required String motivo,
  }) async {
    debugPrint('🗑️ CaducidadesRepository: Eliminando item de stock...');
    debugPrint('   - Vehículo: $vehiculoId');
    debugPrint('   - Producto: $productoId');
    debugPrint('   - Motivo: $motivo');

    // Registrar salida total del producto (establece cantidad en 0)
    await _stockDataSource.registrarMovimiento(
      vehiculoId: vehiculoId,
      productoId: productoId,
      tipo: 'salida',
      cantidad: 999, // Cantidad grande para asegurar que se elimine todo
      motivo: motivo,
      usuarioId: usuarioId,
    );

    debugPrint('✅ CaducidadesRepository: Item eliminado');
  }

  @override
  Stream<void> watchCambios(String vehiculoId) =>
      _equipamientoDataSource.watchCambios(vehiculoId);
}
