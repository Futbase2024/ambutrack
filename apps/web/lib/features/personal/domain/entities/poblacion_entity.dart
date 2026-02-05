import 'package:equatable/equatable.dart';

/// Entidad de población
class PoblacionEntity extends Equatable {
  const PoblacionEntity({
    required this.id,
    required this.nombre,
    this.provinciaId,
    this.codigoPostal,
  });

  /// Crea una PoblacionEntity desde un Map (Supabase)
  factory PoblacionEntity.fromMap(Map<String, dynamic> map) {
    return PoblacionEntity(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      provinciaId: map['provincia_id']?.toString(),
      codigoPostal: map['codigo_postal']?.toString(),
    );
  }

  final String id;
  final String nombre;
  final String? provinciaId;
  final String? codigoPostal;

  /// Convierte la PoblacionEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'provincia_id': provinciaId,
      'codigo_postal': codigoPostal,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, nombre, provinciaId, codigoPostal];
}
