import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de formación personal
sealed class FormacionState extends Equatable {
  const FormacionState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
final class FormacionInitial extends FormacionState {
  const FormacionInitial();
}

/// Estado de carga
final class FormacionLoading extends FormacionState {
  const FormacionLoading();
}

/// Estado de carga exitosa
final class FormacionLoaded extends FormacionState {
  const FormacionLoaded(this.items);

  final List<FormacionPersonalEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
final class FormacionError extends FormacionState {
  const FormacionError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
