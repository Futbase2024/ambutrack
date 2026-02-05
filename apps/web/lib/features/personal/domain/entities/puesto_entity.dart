import 'package:equatable/equatable.dart';

/// Entidad de puesto de trabajo
class PuestoEntity extends Equatable {
  const PuestoEntity({
    required this.id,
    required this.nombre,
  });

  /// Crea una PuestoEntity desde un Map (Supabase)
  factory PuestoEntity.fromMap(Map<String, dynamic> map) {
    return PuestoEntity(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
    );
  }

  final String id;
  final String nombre;

  /// Convierte la PuestoEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, nombre];
}
