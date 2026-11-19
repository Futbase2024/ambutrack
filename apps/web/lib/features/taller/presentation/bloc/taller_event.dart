import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del TallerBloc
abstract class TallerEvent extends Equatable {
  const TallerEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todos los talleres
class TallerLoadRequested extends TallerEvent {
  const TallerLoadRequested();
}

/// Crear un nuevo taller
class TallerCreateRequested extends TallerEvent {
  const TallerCreateRequested({required this.taller});

  final TallerEntity taller;

  @override
  List<Object?> get props => <Object?>[taller];
}

/// Actualizar un taller
class TallerUpdateRequested extends TallerEvent {
  const TallerUpdateRequested({required this.taller});

  final TallerEntity taller;

  @override
  List<Object?> get props => <Object?>[taller];
}

/// Eliminar un taller
class TallerDeleteRequested extends TallerEvent {
  const TallerDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
