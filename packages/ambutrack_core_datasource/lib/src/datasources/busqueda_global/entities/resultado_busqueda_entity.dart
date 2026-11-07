import 'package:equatable/equatable.dart';

/// Tipo de registro encontrado por la búsqueda global
enum TipoResultadoBusqueda {
  vehiculo('vehiculo', 'Vehículo'),
  paciente('paciente', 'Paciente'),
  personal('personal', 'Personal'),
  orden('orden', 'Orden de reparación'),
  otro('otro', 'Registro');

  const TipoResultadoBusqueda(this.code, this.label);

  final String code;
  final String label;

  static TipoResultadoBusqueda fromCode(String? code) =>
      values.firstWhere((TipoResultadoBusqueda t) => t.code == code, orElse: () => otro);
}

/// Registro encontrado por la búsqueda global (Ctrl+K)
class ResultadoBusquedaEntity extends Equatable {
  const ResultadoBusquedaEntity({
    required this.tipo,
    required this.id,
    required this.titulo,
    this.subtitulo,
  });

  final TipoResultadoBusqueda tipo;
  final String id;
  final String titulo;
  final String? subtitulo;

  @override
  List<Object?> get props => <Object?>[tipo, id, titulo, subtitulo];
}
