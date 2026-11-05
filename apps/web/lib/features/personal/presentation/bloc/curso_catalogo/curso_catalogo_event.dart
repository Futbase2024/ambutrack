import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

sealed class CursoCatalogoEvent extends Equatable {
  const CursoCatalogoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class CursoCatalogoLoadRequested extends CursoCatalogoEvent {
  const CursoCatalogoLoadRequested();
}

final class CursoCatalogoCreateRequested extends CursoCatalogoEvent {
  const CursoCatalogoCreateRequested(this.entity);

  final CursoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

final class CursoCatalogoUpdateRequested extends CursoCatalogoEvent {
  const CursoCatalogoUpdateRequested(this.entity);

  final CursoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

final class CursoCatalogoDeleteRequested extends CursoCatalogoEvent {
  const CursoCatalogoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
