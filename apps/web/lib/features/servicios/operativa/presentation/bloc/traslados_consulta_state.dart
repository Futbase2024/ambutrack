import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:equatable/equatable.dart';

/// Estados del TrasladosConsultaBloc
abstract class TrasladosConsultaState extends Equatable {
  const TrasladosConsultaState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TrasladosConsultaInitial extends TrasladosConsultaState {
  const TrasladosConsultaInitial();
}

/// Consulta en curso
class TrasladosConsultaLoading extends TrasladosConsultaState {
  const TrasladosConsultaLoading();
}

/// Traslados cargados
class TrasladosConsultaLoaded extends TrasladosConsultaState {
  const TrasladosConsultaLoaded({
    required this.consulta,
    required this.traslados,
    required this.personal,
    required this.actualizadoEn,
  });

  final TrasladosConsulta consulta;
  final List<TrasladoEntity> traslados;

  /// Nombre del personal por ID (para mostrar conductor/sanitarios)
  final Map<String, String> personal;

  /// Momento de la última carga
  final DateTime actualizadoEn;

  @override
  List<Object?> get props => <Object?>[consulta, traslados, personal, actualizadoEn];
}

/// Error en la consulta
class TrasladosConsultaError extends TrasladosConsultaState {
  const TrasladosConsultaError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
