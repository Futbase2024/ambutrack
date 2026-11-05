import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del RepuestoOrdenBloc
abstract class RepuestoOrdenEvent extends Equatable {
  const RepuestoOrdenEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class RepuestoOrdenLoadRequested extends RepuestoOrdenEvent {
  const RepuestoOrdenLoadRequested({required this.ordenId});

  final String ordenId;

  @override
  List<Object?> get props => <Object?>[ordenId];
}

class RepuestoOrdenCreateRequested extends RepuestoOrdenEvent {
  const RepuestoOrdenCreateRequested({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  List<Object?> get props => <Object?>[repuesto];
}

class RepuestoOrdenUpdateRequested extends RepuestoOrdenEvent {
  const RepuestoOrdenUpdateRequested({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  List<Object?> get props => <Object?>[repuesto];
}

class RepuestoOrdenDeleteRequested extends RepuestoOrdenEvent {
  const RepuestoOrdenDeleteRequested({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  List<Object?> get props => <Object?>[repuesto];
}
