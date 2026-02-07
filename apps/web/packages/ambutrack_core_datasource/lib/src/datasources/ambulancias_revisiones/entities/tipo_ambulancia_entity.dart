/// Entity para Tipo de Ambulancia
class TipoAmbulanciaEntity {
  const TipoAmbulanciaEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.nivelEquipamiento,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String codigo; // 'A1', 'A2', 'B', 'C', 'A1EE'
  final String nombre;
  final String? descripcion;
  final String nivelEquipamiento; // 'basico', 'avanzado', 'minimo'
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Crea una copia con los campos modificados
  TipoAmbulanciaEntity copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? nivelEquipamiento,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoAmbulanciaEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      nivelEquipamiento: nivelEquipamiento ?? this.nivelEquipamiento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
