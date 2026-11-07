import 'package:freezed_annotation/freezed_annotation.dart';

part 'caducidades_event.freezed.dart';

/// Eventos del CaducidadesBloc
@freezed
class CaducidadesEvent with _$CaducidadesEvent {
  /// Evento inicial - Carga caducidades del vehículo asignado
  const factory CaducidadesEvent.started({
    required String vehiculoId,
  }) = _Started;

  /// Cargar caducidades de un vehículo
  const factory CaducidadesEvent.cargarCaducidades({
    required String vehiculoId,
  }) = _CargarCaducidades;

  /// Filtrar por estado de caducidad
  /// [filtro] null = todas, 'proximo' = 8-30 días, 'critico' = 0-7 días, 'caducado' = ya caducado
  const factory CaducidadesEvent.filtrarPorEstado({
    String? filtro,
  }) = _FiltrarPorEstado;

  /// Cargar alertas activas
  const factory CaducidadesEvent.cargarAlertas({
    required String vehiculoId,
  }) = _CargarAlertas;

  /// Solicitar reposición de un item
  const factory CaducidadesEvent.solicitarReposicion({
    required String vehiculoId,
    required String productoId,
    required String productoNombre,
    required int cantidadSolicitada,
    required String motivo,
    required String usuarioId,
  }) = _SolicitarReposicion;

  /// Registrar incidencia de caducidad
  const factory CaducidadesEvent.registrarIncidencia({
    required String vehiculoId,
    required String titulo,
    required String descripcion,
    required String reportadoPor,
    required String reportadoPorNombre,
    required String empresaId,
  }) = _RegistrarIncidencia;

  /// Resolver alerta de caducidad
  const factory CaducidadesEvent.resolverAlerta({
    required String alertaId,
    required String usuarioId,
  }) = _ResolverAlerta;

  /// Actualizar item de stock
  const factory CaducidadesEvent.actualizarItem({
    required String itemId,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    String? lote,
    String? ubicacion,
    String? observaciones,
  }) = _ActualizarItem;

  /// Eliminar item de stock
  const factory CaducidadesEvent.eliminarItem({
    required String itemId,
    required String vehiculoId,
    required String productoNombre,
    required String usuarioId,
  }) = _EliminarItem;

  /// Refrescar lista (pull-to-refresh)
  const factory CaducidadesEvent.refrescar() = _Refrescar;
}
