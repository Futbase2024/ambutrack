import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de la dotación
enum EquipamientoStatus { initial, loading, loaded, failure }

/// Resultado de la última escritura
enum EquipamientoResultado { ninguno, exito, error }

/// Estado del BLoC de equipamiento del vehículo
///
/// [operacion] se incrementa al terminar cada guardado (listenWhen).
class EquipamientoState extends Equatable {
  const EquipamientoState({
    this.vehiculoId,
    this.status = EquipamientoStatus.initial,
    this.lineas = const <StockVehiculoEntity>[],
    this.saving = false,
    this.operacion = 0,
    this.resultado = EquipamientoResultado.ninguno,
    this.error,
  });

  final String? vehiculoId;
  final EquipamientoStatus status;

  /// Líneas visibles para el técnico (sin excluidas)
  final List<StockVehiculoEntity> lineas;
  final bool saving;
  final int operacion;
  final EquipamientoResultado resultado;
  final String? error;

  EquipamientoState copyWith({
    String? vehiculoId,
    EquipamientoStatus? status,
    List<StockVehiculoEntity>? lineas,
    bool? saving,
    int? operacion,
    EquipamientoResultado? resultado,
    String? error,
    bool clearError = false,
  }) {
    return EquipamientoState(
      vehiculoId: vehiculoId ?? this.vehiculoId,
      status: status ?? this.status,
      lineas: lineas ?? this.lineas,
      saving: saving ?? this.saving,
      operacion: operacion ?? this.operacion,
      resultado: resultado ?? this.resultado,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[vehiculoId, status, lineas, saving, operacion, resultado, error];
}
