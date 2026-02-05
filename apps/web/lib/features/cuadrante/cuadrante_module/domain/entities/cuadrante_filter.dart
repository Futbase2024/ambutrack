import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:equatable/equatable.dart';

/// Filtros aplicables al cuadrante de personal
class CuadranteFilter extends Equatable {
  const CuadranteFilter({
    this.categoriaServicio,
    this.puestoId,
    this.fechaInicio,
    this.fechaFin,
    this.soloConTurnos = false,
    this.searchQuery = '',
    this.contratoId,
    this.dotacionId,
  });

  /// Categoría de servicio (Urgencias/Programado)
  final CategoriaServicio? categoriaServicio;

  /// ID del puesto de trabajo
  final String? puestoId;

  /// Fecha de inicio del rango
  final DateTime? fechaInicio;

  /// Fecha de fin del rango
  final DateTime? fechaFin;

  /// Mostrar solo personal con turnos asignados
  final bool soloConTurnos;

  /// Texto de búsqueda para filtrar por nombre de personal
  final String searchQuery;

  /// ID del contrato para filtrar
  final String? contratoId;

  /// ID de la dotación para filtrar
  final String? dotacionId;

  @override
  List<Object?> get props => <Object?>[
        categoriaServicio,
        puestoId,
        fechaInicio,
        fechaFin,
        soloConTurnos,
        searchQuery,
        contratoId,
        dotacionId,
      ];

  /// Copia con modificaciones
  CuadranteFilter copyWith({
    CategoriaServicio? categoriaServicio,
    String? puestoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? soloConTurnos,
    String? searchQuery,
    String? contratoId,
    String? dotacionId,
  }) {
    return CuadranteFilter(
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      puestoId: puestoId ?? this.puestoId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      soloConTurnos: soloConTurnos ?? this.soloConTurnos,
      searchQuery: searchQuery ?? this.searchQuery,
      contratoId: contratoId ?? this.contratoId,
      dotacionId: dotacionId ?? this.dotacionId,
    );
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters =>
      categoriaServicio != null ||
      puestoId != null ||
      fechaInicio != null ||
      fechaFin != null ||
      soloConTurnos ||
      searchQuery.isNotEmpty ||
      contratoId != null ||
      dotacionId != null;

  /// Limpia todos los filtros
  CuadranteFilter clear() {
    return const CuadranteFilter();
  }
}
