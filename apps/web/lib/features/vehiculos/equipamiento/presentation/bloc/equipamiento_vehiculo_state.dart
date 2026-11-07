import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de la dotación
enum EquipamientoStatus { initial, loading, loaded, failure }

/// Resultado de la última operación de escritura
enum EquipamientoResultado { ninguno, exito, error }

/// Estado del BLoC de equipamiento de un vehículo
///
/// [operacion] se incrementa al terminar cada escritura para que la UI
/// muestre el resultado una sola vez (listenWhen).
class EquipamientoVehiculoState extends Equatable {
  const EquipamientoVehiculoState({
    this.vehiculoId,
    this.status = EquipamientoStatus.initial,
    this.lineas = const <StockVehiculoEntity>[],
    this.saving = false,
    this.operacion = 0,
    this.resultado = EquipamientoResultado.ninguno,
    this.mensaje,
    this.error,
  });

  final String? vehiculoId;
  final EquipamientoStatus status;
  final List<StockVehiculoEntity> lineas;
  final bool saving;
  final int operacion;
  final EquipamientoResultado resultado;

  /// Mensaje de éxito de la última operación
  final String? mensaje;

  /// Error de carga o de la última operación
  final String? error;

  bool get hasData => status == EquipamientoStatus.loaded || lineas.isNotEmpty;

  EquipamientoVehiculoState copyWith({
    String? vehiculoId,
    EquipamientoStatus? status,
    List<StockVehiculoEntity>? lineas,
    bool? saving,
    int? operacion,
    EquipamientoResultado? resultado,
    String? mensaje,
    String? error,
    bool clearError = false,
  }) {
    return EquipamientoVehiculoState(
      vehiculoId: vehiculoId ?? this.vehiculoId,
      status: status ?? this.status,
      lineas: lineas ?? this.lineas,
      saving: saving ?? this.saving,
      operacion: operacion ?? this.operacion,
      resultado: resultado ?? this.resultado,
      mensaje: mensaje ?? this.mensaje,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[vehiculoId, status, lineas, saving, operacion, resultado, mensaje, error];
}
