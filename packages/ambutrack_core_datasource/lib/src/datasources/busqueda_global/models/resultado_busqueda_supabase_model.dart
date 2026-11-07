import '../entities/resultado_busqueda_entity.dart';

/// Fila devuelta por `fn_buscar_global` (tipo, id, titulo, subtitulo)
class ResultadoBusquedaSupabaseModel {
  const ResultadoBusquedaSupabaseModel({
    required this.tipo,
    required this.id,
    required this.titulo,
    this.subtitulo,
  });

  factory ResultadoBusquedaSupabaseModel.fromJson(Map<String, dynamic> json) {
    return ResultadoBusquedaSupabaseModel(
      tipo: json['tipo'] as String? ?? '',
      id: json['id'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      subtitulo: json['subtitulo'] as String?,
    );
  }

  final String tipo;
  final String id;
  final String titulo;
  final String? subtitulo;

  ResultadoBusquedaEntity toEntity() => ResultadoBusquedaEntity(
        tipo: TipoResultadoBusqueda.fromCode(tipo),
        id: id,
        titulo: titulo,
        subtitulo: (subtitulo == null || subtitulo!.isEmpty) ? null : subtitulo,
      );
}
