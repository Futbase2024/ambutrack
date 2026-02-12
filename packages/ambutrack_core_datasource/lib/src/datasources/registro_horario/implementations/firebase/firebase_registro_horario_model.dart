import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/registro_horario_entity.dart';
import '../../../../core/base_model.dart';

/// Modelo específico de Firebase para [RegistroHorarioEntity]
///
/// Maneja la conversión entre documentos de Firestore y objetos [RegistroHorarioEntity]
class FirebaseRegistroHorarioModel extends BaseModel<RegistroHorarioEntity> {
  final RegistroHorarioEntity _entity;

  FirebaseRegistroHorarioModel(this._entity);

  /// Crea un [FirebaseRegistroHorarioModel] desde un [RegistroHorarioEntity]
  factory FirebaseRegistroHorarioModel.fromEntity(RegistroHorarioEntity entity) {
    return FirebaseRegistroHorarioModel(entity);
  }

  /// Crea un [FirebaseRegistroHorarioModel] desde un documento de Firestore
  factory FirebaseRegistroHorarioModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) {
      throw ArgumentError('El documento no existe');
    }

    final data = doc.data()!;
    final entity = RegistroHorarioEntity(
      id: doc.id,
      personalId: data['personalId'] as String,
      nombrePersonal: data['nombrePersonal'] as String?,
      tipo: data['tipo'] as String,
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
      ubicacion: data['ubicacion'] as String?,
      latitud: data['latitud'] != null
          ? (data['latitud'] as num).toDouble()
          : null,
      longitud: data['longitud'] != null
          ? (data['longitud'] as num).toDouble()
          : null,
      notas: data['notas'] as String?,
      estado: data['estado'] as String? ?? 'normal',
      esManual: data['esManual'] as bool? ?? false,
      usuarioManualId: data['usuarioManualId'] as String?,
      vehiculoId: data['vehiculoId'] as String?,
      turno: data['turno'] as String?,
      horasTrabajadas: data['horasTrabajadas'] != null
          ? (data['horasTrabajadas'] as num).toDouble()
          : null,
      activo: data['activo'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );

    return FirebaseRegistroHorarioModel(entity);
  }

  /// Crea un [FirebaseRegistroHorarioModel] desde datos JSON
  factory FirebaseRegistroHorarioModel.fromJson(Map<String, dynamic> json) {
    final entity = RegistroHorarioEntity.fromJson(json);
    return FirebaseRegistroHorarioModel(entity);
  }

  @override
  RegistroHorarioEntity toEntity() => _entity;

  @override
  Map<String, dynamic> toJson() => _entity.toJson();

  /// Convierte el modelo a datos de documento de Firestore
  ///
  /// Este método maneja tipos de datos específicos de Firestore como [Timestamp]
  /// y excluye el ID del documento (que se maneja por separado)
  Map<String, dynamic> toFirestore() {
    return {
      'personalId': _entity.personalId,
      'nombrePersonal': _entity.nombrePersonal,
      'tipo': _entity.tipo,
      'fechaHora': Timestamp.fromDate(_entity.fechaHora),
      'ubicacion': _entity.ubicacion,
      'latitud': _entity.latitud,
      'longitud': _entity.longitud,
      'notas': _entity.notas,
      'estado': _entity.estado,
      'esManual': _entity.esManual,
      'usuarioManualId': _entity.usuarioManualId,
      'vehiculoId': _entity.vehiculoId,
      'turno': _entity.turno,
      'horasTrabajadas': _entity.horasTrabajadas,
      'activo': _entity.activo,
      'createdAt': Timestamp.fromDate(_entity.createdAt),
      'updatedAt': Timestamp.fromDate(_entity.updatedAt),
    };
  }

  /// Convierte el modelo a datos de documento de Firestore para creación
  ///
  /// Usa timestamps del servidor para createdAt y updatedAt
  Map<String, dynamic> toFirestoreForCreate() {
    return {
      'personalId': _entity.personalId,
      'nombrePersonal': _entity.nombrePersonal,
      'tipo': _entity.tipo,
      'fechaHora': Timestamp.fromDate(_entity.fechaHora),
      'ubicacion': _entity.ubicacion,
      'latitud': _entity.latitud,
      'longitud': _entity.longitud,
      'notas': _entity.notas,
      'estado': _entity.estado,
      'esManual': _entity.esManual,
      'usuarioManualId': _entity.usuarioManualId,
      'vehiculoId': _entity.vehiculoId,
      'turno': _entity.turno,
      'horasTrabajadas': _entity.horasTrabajadas,
      'activo': _entity.activo,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convierte el modelo a datos de documento de Firestore para actualizaciones
  ///
  /// Usa timestamp del servidor solo para updatedAt
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'personalId': _entity.personalId,
      'nombrePersonal': _entity.nombrePersonal,
      'tipo': _entity.tipo,
      'fechaHora': Timestamp.fromDate(_entity.fechaHora),
      'ubicacion': _entity.ubicacion,
      'latitud': _entity.latitud,
      'longitud': _entity.longitud,
      'notas': _entity.notas,
      'estado': _entity.estado,
      'esManual': _entity.esManual,
      'usuarioManualId': _entity.usuarioManualId,
      'vehiculoId': _entity.vehiculoId,
      'turno': _entity.turno,
      'horasTrabajadas': _entity.horasTrabajadas,
      'activo': _entity.activo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'FirebaseRegistroHorarioModel(entity: $_entity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirebaseRegistroHorarioModel && other._entity == _entity;
  }

  @override
  int get hashCode => _entity.hashCode;
}
