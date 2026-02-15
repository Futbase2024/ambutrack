import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Documentación de Vehículos
abstract class DocumentacionVehiculosState extends Equatable {
  const DocumentacionVehiculosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class DocumentacionVehiculosInitial extends DocumentacionVehiculosState {
  const DocumentacionVehiculosInitial();
}

/// Cargando documentos
class DocumentacionVehiculosLoading extends DocumentacionVehiculosState {
  const DocumentacionVehiculosLoading();
}

/// Documentos cargados correctamente
class DocumentacionVehiculosLoaded extends DocumentacionVehiculosState {
  const DocumentacionVehiculosLoaded({
    required this.documentos,
    this.filtroVehiculoId,
    this.filtroEstado,
    this.isRefreshing = false,
  });

  final List<DocumentacionVehiculoEntity> documentos;
  final String? filtroVehiculoId;
  final String? filtroEstado;
  final bool isRefreshing;

  @override
  List<Object?> get props => <Object?>[documentos, filtroVehiculoId, filtroEstado, isRefreshing];
}

/// Error al cargar documentos
class DocumentacionVehiculosError extends DocumentacionVehiculosState {
  const DocumentacionVehiculosError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
