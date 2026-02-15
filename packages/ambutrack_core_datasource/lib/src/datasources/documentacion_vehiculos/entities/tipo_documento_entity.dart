import 'package:equatable/equatable.dart';

/// Entidad de dominio para Tipos de Documento de Vehículo
/// Representa el catálogo de tipos de documentación (seguros, ITV, permisos, licencias)
class TipoDocumentoEntity extends Equatable {
  const TipoDocumentoEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.vigenciaMeses,
    required this.obligatorio,
    required this.activo,
    this.fechaBaja,
    this.createdAt,
    this.updatedAt,
  });

  // IDENTIFICACIÓN ÚNICA
  final String id;
  final String codigo; // 'SEGURO_RC', 'ITV', 'PERMISO_MUNICIPAL', 'TARJETA_TRANSPORTE'

  // DATOS DEL TIPO
  final String nombre; // 'Seguro Responsabilidad Civil'
  final String? descripcion; // Descripción detallada
  final String categoria; // 'seguro', 'itv', 'permiso', 'licencia', 'otro'
  final int vigenciaMeses; // Vigencia recomendada en meses (12, 6, 24, etc.)
  final bool obligatorio; // Si es obligatorio para vehículos activos

  // ESTADO
  final bool activo; // Si está activo en el sistema
  final DateTime? fechaBaja; // Fecha de baja (si aplica)

  // AUDITORÍA
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Getter para nombre formateado de la categoría
  String get categoriaFormateada {
    switch (categoria) {
      case 'seguro':
        return 'Seguro';
      case 'itv':
        return 'ITV';
      case 'permiso':
        return 'Permiso';
      case 'licencia':
        return 'Licencia';
      case 'otro':
        return 'Otro';
      default:
        return categoria;
    }
  }

  /// Método copyWith para crear copias inmutables
  TipoDocumentoEntity copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? categoria,
    int? vigenciaMeses,
    bool? obligatorio,
    bool? activo,
    DateTime? fechaBaja,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoDocumentoEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      vigenciaMeses: vigenciaMeses ?? this.vigenciaMeses,
      obligatorio: obligatorio ?? this.obligatorio,
      activo: activo ?? this.activo,
      fechaBaja: fechaBaja ?? this.fechaBaja,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        descripcion,
        categoria,
        vigenciaMeses,
        obligatorio,
        activo,
        fechaBaja,
        createdAt,
        updatedAt,
      ];
}
