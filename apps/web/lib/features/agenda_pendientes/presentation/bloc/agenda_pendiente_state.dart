import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Agenda de Pendientes
abstract class AgendaPendienteState extends Equatable {
  const AgendaPendienteState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class AgendaPendienteInitial extends AgendaPendienteState {
  const AgendaPendienteInitial();
}

/// Cargando datos
class AgendaPendienteLoading extends AgendaPendienteState {
  const AgendaPendienteLoading();
}

/// Datos cargados correctamente
class AgendaPendienteLoaded extends AgendaPendienteState {
  const AgendaPendienteLoaded({
    this.pendientes = const <AgendaPendienteEntity>[],
    required this.pendientesHoy,
    this.searchQuery = '',
    this.isSaving = false,
    this.message,
  });

  /// Lista completa de pendientes de la empresa
  final List<AgendaPendienteEntity> pendientes;

  /// Pendientes programados para hoy (no completados)
  final List<AgendaPendienteEntity> pendientesHoy;

  /// Filtro de búsqueda actual
  final String searchQuery;

  /// Indica si se está guardando (creando/editando)
  final bool isSaving;

  /// Mensaje de éxito o error
  final String? message;

  /// Pendientes filtrados por búsqueda
  List<AgendaPendienteEntity> get filteredPendientes {
    if (searchQuery.isEmpty) {
      return pendientes;
    }

    final String query = searchQuery.toLowerCase();
    return pendientes
        .where((AgendaPendienteEntity p) {
          final bool matchNombre =
              p.nombreApellidos.toLowerCase().contains(query);
          final bool matchDomicilio =
              p.domicilio?.toLowerCase().contains(query) ?? false;
          final bool matchLocalidad =
              p.localidad?.toLowerCase().contains(query) ?? false;
          final bool matchDesc =
              p.descripcion.toLowerCase().contains(query);
          return matchNombre ||
              matchDomicilio ||
              matchLocalidad ||
              matchDesc;
        })
        .toList();
  }

  /// Total de pendientes no completados
  int get totalPendientes =>
      pendientes.where((AgendaPendienteEntity p) => !p.completado).length;

  /// Total de completados
  int get totalCompletados =>
      pendientes.where((AgendaPendienteEntity p) => p.completado).length;

  @override
  List<Object?> get props => <Object?>[
        pendientes,
        pendientesHoy,
        searchQuery,
        isSaving,
        message,
      ];

  AgendaPendienteLoaded copyWith({
    List<AgendaPendienteEntity>? pendientes,
    List<AgendaPendienteEntity>? pendientesHoy,
    String? searchQuery,
    bool? isSaving,
    String? message,
  }) {
    return AgendaPendienteLoaded(
      pendientes: pendientes ?? this.pendientes,
      pendientesHoy: pendientesHoy ?? this.pendientesHoy,
      searchQuery: searchQuery ?? this.searchQuery,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }
}

/// Estado de error
class AgendaPendienteError extends AgendaPendienteState {
  const AgendaPendienteError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
