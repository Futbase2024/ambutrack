import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:equatable/equatable.dart';

/// Eventos del AuditoriaBloc
abstract class AuditoriaEvent extends Equatable {
  const AuditoriaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga (o recarga) el primer bloque con los filtros actuales
class AuditoriaLoadRequested extends AuditoriaEvent {
  const AuditoriaLoadRequested();
}

/// Cambian los filtros de servidor: se recarga desde el primer bloque
class AuditoriaFiltrosChanged extends AuditoriaEvent {
  const AuditoriaFiltrosChanged(this.filtros);

  final AuditoriaFiltros filtros;

  @override
  List<Object?> get props => <Object?>[filtros];
}

/// Carga el siguiente bloque de registros
class AuditoriaLoadMoreRequested extends AuditoriaEvent {
  const AuditoriaLoadMoreRequested();
}
