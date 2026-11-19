import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

sealed class CursoCatalogoState extends Equatable {
  const CursoCatalogoState();

  @override
  List<Object?> get props => <Object?>[];
}

final class CursoCatalogoInitial extends CursoCatalogoState {
  const CursoCatalogoInitial();
}

final class CursoCatalogoLoading extends CursoCatalogoState {
  const CursoCatalogoLoading();
}

final class CursoCatalogoLoaded extends CursoCatalogoState {
  const CursoCatalogoLoaded(this.items);

  final List<CursoEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

final class CursoCatalogoError extends CursoCatalogoState {
  const CursoCatalogoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
