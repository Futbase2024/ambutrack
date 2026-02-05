import 'package:equatable/equatable.dart';

/// Entidad de empresa
class EmpresaEntity extends Equatable {
  const EmpresaEntity({
    required this.id,
    required this.nombre,
  });

  /// Crea una EmpresaEntity desde un Map (Supabase)
  factory EmpresaEntity.fromMap(Map<String, dynamic> map) {
    return EmpresaEntity(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
    );
  }

  final String id;
  final String nombre;

  /// Convierte la EmpresaEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, nombre];
}
