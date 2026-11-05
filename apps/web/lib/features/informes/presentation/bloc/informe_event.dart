import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:equatable/equatable.dart';

/// Eventos comunes de los BLoCs de informes
abstract class InformeEvent extends Equatable {
  const InformeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Recarga los datos desde Supabase con el filtro actual
class InformeRefreshRequested extends InformeEvent {
  const InformeRefreshRequested();
}

/// Cambia el filtro. Si el rango de fechas no cambia, se recalcula sobre
/// los datos ya cargados sin volver a consultar.
class InformeFiltroChanged extends InformeEvent {
  const InformeFiltroChanged(this.filtro);

  final InformeFiltro filtro;

  @override
  List<Object?> get props => <Object?>[filtro];
}
