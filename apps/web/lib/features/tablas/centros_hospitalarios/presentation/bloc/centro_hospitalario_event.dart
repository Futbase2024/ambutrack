import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Centros Hospitalarios
abstract class CentroHospitalarioEvent extends Equatable {
  const CentroHospitalarioEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los centros hospitalarios
class CentroHospitalarioLoadAllRequested extends CentroHospitalarioEvent {
  const CentroHospitalarioLoadAllRequested();
}

/// Evento para crear un nuevo centro hospitalario
class CentroHospitalarioCreateRequested extends CentroHospitalarioEvent {
  const CentroHospitalarioCreateRequested(this.centro);

  final CentroHospitalarioEntity centro;

  @override
  List<Object?> get props => <Object?>[centro];
}

/// Evento para actualizar un centro hospitalario existente
class CentroHospitalarioUpdateRequested extends CentroHospitalarioEvent {
  const CentroHospitalarioUpdateRequested(this.centro);

  final CentroHospitalarioEntity centro;

  @override
  List<Object?> get props => <Object?>[centro];
}

/// Evento para eliminar un centro hospitalario
class CentroHospitalarioDeleteRequested extends CentroHospitalarioEvent {
  const CentroHospitalarioDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
