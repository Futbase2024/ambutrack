import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Documentación de Vehículos
abstract class DocumentacionVehiculosEvent extends Equatable {
  const DocumentacionVehiculosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los documentos de vehículos
class DocumentacionVehiculosLoadRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosLoadRequested();
}

/// Solicita refrescar los documentos
class DocumentacionVehiculosRefreshRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosRefreshRequested();
}

/// Solicita cargar documentos por vehículo
class DocumentacionVehiculosByVehiculoRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosByVehiculoRequested(this.vehiculoId);

  final String vehiculoId;

  @override
  List<Object?> get props => <Object?>[vehiculoId];
}

/// Solicita cargar documentos por estado
class DocumentacionVehiculosByEstadoRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosByEstadoRequested(this.estado);

  final String estado;

  @override
  List<Object?> get props => <Object?>[estado];
}

/// Solicita cargar documentos próximos a vencer
class DocumentacionVehiculosProximosVencerRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosProximosVencerRequested();
}

/// Solicita cargar documentos vencidos
class DocumentacionVehiculosVencidosRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosVencidosRequested();
}

/// Solicita crear un nuevo documento
class DocumentacionVehiculoCreateRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculoCreateRequested(this.documento);

  final DocumentacionVehiculoEntity documento;

  @override
  List<Object?> get props => <Object?>[documento];
}

/// Solicita actualizar un documento existente
class DocumentacionVehiculoUpdateRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculoUpdateRequested(this.documento);

  final DocumentacionVehiculoEntity documento;

  @override
  List<Object?> get props => <Object?>[documento];
}

/// Solicita eliminar un documento
class DocumentacionVehiculoDeleteRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculoDeleteRequested(this.documentoId);

  final String documentoId;

  @override
  List<Object?> get props => <Object?>[documentoId];
}

/// Solicita actualizar el estado de un documento
class DocumentacionVehiculoActualizarEstadoRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculoActualizarEstadoRequested(this.documentoId);

  final String documentoId;

  @override
  List<Object?> get props => <Object?>[documentoId];
}

/// Solicita buscar documentos por número de póliza
class DocumentacionVehiculosBuscarPorPolizaRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosBuscarPorPolizaRequested(this.numeroPoliza);

  final String numeroPoliza;

  @override
  List<Object?> get props => <Object?>[numeroPoliza];
}

/// Solicita buscar documentos por compañía
class DocumentacionVehiculosBuscarPorCompaniaRequested extends DocumentacionVehiculosEvent {
  const DocumentacionVehiculosBuscarPorCompaniaRequested(this.compania);

  final String compania;

  @override
  List<Object?> get props => <Object?>[compania];
}
