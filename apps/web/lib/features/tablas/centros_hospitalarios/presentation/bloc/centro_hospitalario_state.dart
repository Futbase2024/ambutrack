import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Centros Hospitalarios
abstract class CentroHospitalarioState extends Equatable {
  const CentroHospitalarioState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class CentroHospitalarioInitial extends CentroHospitalarioState {
  const CentroHospitalarioInitial();
}

/// Estado de carga
class CentroHospitalarioLoading extends CentroHospitalarioState {
  const CentroHospitalarioLoading();
}

/// Estado de datos cargados exitosamente
class CentroHospitalarioLoaded extends CentroHospitalarioState {
  const CentroHospitalarioLoaded(this.centros);

  final List<CentroHospitalarioEntity> centros;

  @override
  List<Object?> get props => <Object?>[centros];
}

/// Estado de error
class CentroHospitalarioError extends CentroHospitalarioState {
  const CentroHospitalarioError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
