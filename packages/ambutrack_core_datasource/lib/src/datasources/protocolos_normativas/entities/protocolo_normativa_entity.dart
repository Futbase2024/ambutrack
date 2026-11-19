import 'package:equatable/equatable.dart';

/// Categoría de un protocolo o normativa (columna `categoria` de tprotocolos_normativas)
enum CategoriaProtocolo {
  protocoloAsistencial('protocolo_asistencial', 'Protocolo asistencial'),
  procedimientoOperativo('procedimiento_operativo', 'Procedimiento operativo'),
  normativaLegal('normativa_legal', 'Normativa legal'),
  seguridad('seguridad', 'Seguridad'),
  calidad('calidad', 'Calidad'),
  otro('otro', 'Otro');

  const CategoriaProtocolo(this.value, this.label);

  /// Valor almacenado en BD
  final String value;

  /// Texto para mostrar en la UI
  final String label;

  static CategoriaProtocolo fromValue(String? value) {
    for (final CategoriaProtocolo c in CategoriaProtocolo.values) {
      if (c.value == value) {
        return c;
      }
    }
    return CategoriaProtocolo.otro;
  }
}

/// Entity: Protocolo o normativa (tabla maestra)
class ProtocoloNormativaEntity extends Equatable {
  const ProtocoloNormativaEntity({
    required this.id,
    required this.titulo,
    this.codigo,
    this.categoria = CategoriaProtocolo.protocoloAsistencial,
    this.version,
    this.fechaVigencia,
    this.descripcion,
    this.urlDocumento,
    this.activo = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String titulo;
  final String? codigo;
  final CategoriaProtocolo categoria;
  final String? version;
  final DateTime? fechaVigencia;
  final String? descripcion;
  final String? urlDocumento;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        titulo,
        codigo,
        categoria,
        version,
        fechaVigencia,
        descripcion,
        urlDocumento,
        activo,
        createdAt,
        updatedAt,
      ];
}
