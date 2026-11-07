import 'package:equatable/equatable.dart';

/// Eventos del PermisosAccesoBloc
abstract class PermisosAccesoEvent extends Equatable {
  const PermisosAccesoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga (o recarga) los usuarios para cruzarlos con los roles
class PermisosAccesoLoadRequested extends PermisosAccesoEvent {
  const PermisosAccesoLoadRequested();
}
