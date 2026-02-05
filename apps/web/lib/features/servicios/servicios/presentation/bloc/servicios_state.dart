import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/servicio_entity.dart';

part 'servicios_state.freezed.dart';

/// Estados del BLoC de Servicios
@freezed
class ServiciosState with _$ServiciosState {
  /// Estado inicial
  const factory ServiciosState.initial() = _Initial;

  /// Cargando servicios
  const factory ServiciosState.loading() = _Loading;

  /// Servicios cargados exitosamente
  const factory ServiciosState.loaded({
    required List<ServicioEntity> servicios,
    @Default('') String searchQuery,
    int? yearFilter,
    String? estadoFilter,
    @Default(false) bool isRefreshing,
    ServicioEntity? selectedServicio,
    @Default(false) bool isLoadingDetails,
  }) = _Loaded;

  /// Error al cargar servicios
  const factory ServiciosState.error({
    required String message,
    List<ServicioEntity>? previousServicios,
  }) = _Error;
}
