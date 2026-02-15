import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de formación personal
sealed class FormacionEvent extends Equatable {
  const FormacionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los registros
final class FormacionLoadRequested extends FormacionEvent {
  const FormacionLoadRequested();
}

/// Solicita cargar por personal
final class FormacionLoadByPersonalRequested extends FormacionEvent {
  const FormacionLoadByPersonalRequested(this.personalId);

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Solicita cargar formación vigente
final class FormacionLoadVigentesRequested extends FormacionEvent {
  const FormacionLoadVigentesRequested();
}

/// Solicita cargar formación próxima a vencer
final class FormacionLoadProximasVencerRequested extends FormacionEvent {
  const FormacionLoadProximasVencerRequested();
}

/// Solicita cargar formación vencida
final class FormacionLoadVencidasRequested extends FormacionEvent {
  const FormacionLoadVencidasRequested();
}

/// Solicita cargar por estado
final class FormacionLoadByEstadoRequested extends FormacionEvent {
  const FormacionLoadByEstadoRequested(this.estado);

  final String estado;

  @override
  List<Object?> get props => <Object?>[estado];
}

/// Solicita crear un registro
final class FormacionCreateRequested extends FormacionEvent {
  const FormacionCreateRequested(this.entity);

  final FormacionPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita actualizar un registro
final class FormacionUpdateRequested extends FormacionEvent {
  const FormacionUpdateRequested(this.entity);

  final FormacionPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita eliminar un registro
final class FormacionDeleteRequested extends FormacionEvent {
  const FormacionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
