import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga
enum PlantillasStatus { initial, loading, loaded, failure }

/// Resultado de la última escritura
enum PlantillasResultado { ninguno, exito, error }

/// Estado del BLoC de plantillas de equipamiento
///
/// [operacion] se incrementa al terminar cada escritura (listenWhen).
class PlantillasEquipamientoState extends Equatable {
  const PlantillasEquipamientoState({
    this.status = PlantillasStatus.initial,
    this.plantillas = const <PlantillaEquipamientoEntity>[],
    this.plantillaId,
    this.items = const <PlantillaEquipamientoItemEntity>[],
    this.cargandoItems = false,
    this.saving = false,
    this.operacion = 0,
    this.resultado = PlantillasResultado.ninguno,
    this.mensaje,
    this.error,
  });

  final PlantillasStatus status;
  final List<PlantillaEquipamientoEntity> plantillas;

  /// Plantilla seleccionada
  final String? plantillaId;
  final List<PlantillaEquipamientoItemEntity> items;
  final bool cargandoItems;
  final bool saving;
  final int operacion;
  final PlantillasResultado resultado;
  final String? mensaje;
  final String? error;

  PlantillaEquipamientoEntity? get plantilla {
    for (final PlantillaEquipamientoEntity p in plantillas) {
      if (p.id == plantillaId) {
        return p;
      }
    }
    return null;
  }

  PlantillasEquipamientoState copyWith({
    PlantillasStatus? status,
    List<PlantillaEquipamientoEntity>? plantillas,
    String? plantillaId,
    bool clearPlantilla = false,
    List<PlantillaEquipamientoItemEntity>? items,
    bool? cargandoItems,
    bool? saving,
    int? operacion,
    PlantillasResultado? resultado,
    String? mensaje,
    String? error,
    bool clearError = false,
  }) {
    return PlantillasEquipamientoState(
      status: status ?? this.status,
      plantillas: plantillas ?? this.plantillas,
      plantillaId: clearPlantilla ? null : (plantillaId ?? this.plantillaId),
      items: items ?? this.items,
      cargandoItems: cargandoItems ?? this.cargandoItems,
      saving: saving ?? this.saving,
      operacion: operacion ?? this.operacion,
      resultado: resultado ?? this.resultado,
      mensaje: mensaje ?? this.mensaje,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        plantillas,
        plantillaId,
        items,
        cargandoItems,
        saving,
        operacion,
        resultado,
        mensaje,
        error,
      ];
}
