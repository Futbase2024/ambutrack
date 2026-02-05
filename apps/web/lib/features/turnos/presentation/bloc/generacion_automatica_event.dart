import 'package:ambutrack_web/features/turnos/domain/entities/configuracion_generacion_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GeneracionAutomaticaEvent extends Equatable {
  const GeneracionAutomaticaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita generar cuadrante automáticamente
class GeneracionAutomaticaSolicitada extends GeneracionAutomaticaEvent {
  const GeneracionAutomaticaSolicitada({
    required this.fechaInicio,
    required this.fechaFin,
    required this.idsPersonal,
    required this.configuracion,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<String> idsPersonal; // IDs del personal a incluir
  final ConfiguracionGeneracionEntity configuracion;

  @override
  List<Object?> get props => <Object?>[fechaInicio, fechaFin, idsPersonal, configuracion];
}

/// Confirma y guarda los turnos generados
class GeneracionAutomaticaConfirmada extends GeneracionAutomaticaEvent {
  const GeneracionAutomaticaConfirmada();
}

/// Cancela la generación (descarta turnos generados)
class GeneracionAutomaticaCancelada extends GeneracionAutomaticaEvent {
  const GeneracionAutomaticaCancelada();
}
