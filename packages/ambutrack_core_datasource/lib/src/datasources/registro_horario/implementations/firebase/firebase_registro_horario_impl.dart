import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../registro_horario_contract.dart';
import '../../entities/registro_horario_entity.dart';
import '../../../../utils/exceptions/datasource_exception.dart';
import '../../../../utils/mixins/cache_mixin.dart';
import '../../../../utils/mixins/error_handler_mixin.dart';
import 'firebase_registro_horario_model.dart';

/// Implementación de Firebase para [RegistroHorarioDataSource]
///
/// Proporciona operaciones de gestión de registro horario usando Cloud Firestore
class FirebaseRegistroHorarioDataSource
    with CacheMixin<RegistroHorarioEntity>, ErrorHandlerMixin
    implements RegistroHorarioDataSource {
  final FirebaseFirestore _firestore;
  final String _collectionName;

  /// Crea un nuevo [FirebaseRegistroHorarioDataSource]
  ///
  /// [firestore] - Instancia de Firestore a usar (por defecto usa la instancia predeterminada)
  /// [collectionName] - Nombre de la colección de registros (por defecto 'registros_horarios')
  FirebaseRegistroHorarioDataSource({
    FirebaseFirestore? firestore,
    String collectionName = 'registros_horarios',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _collectionName = collectionName;

  /// Referencia a la colección de registros horarios
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<RegistroHorarioEntity> create(RegistroHorarioEntity entity) async {
    return withRetry(
      () async {
        try {
          final model = FirebaseRegistroHorarioModel.fromEntity(entity);
          final docRef = _collection.doc(entity.id);

          await docRef.set(model.toFirestoreForCreate());

          final createdDoc = await docRef.get();
          final createdModel = FirebaseRegistroHorarioModel.fromFirestore(createdDoc);
          final createdEntity = createdModel.toEntity();

          saveToCache(createEntityCacheKey('getById', entity.id), createdEntity);
          invalidateCachePattern('getAll:.*');
          invalidateCachePattern('getByPersonalId:.*');

          return createdEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'create');
        }
      },
      operationName: 'create',
    );
  }

  @override
  Future<RegistroHorarioEntity?> getById(String id) async {
    final cached = getFromCache(createEntityCacheKey('getById', id));
    if (cached != null) return cached;

    return withRetry(
      () async {
        try {
          final doc = await _collection.doc(id).get();
          if (!doc.exists) return null;

          final model = FirebaseRegistroHorarioModel.fromFirestore(doc);
          final entity = model.toEntity();

          saveToCache(createEntityCacheKey('getById', id), entity);

          return entity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getById');
        }
      },
      operationName: 'getById',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getAll({int? limit, int? offset}) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection.get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          var result = entities;
          if (offset != null) {
            result = result.skip(offset).toList();
          }
          if (limit != null) {
            result = result.take(limit).toList();
          }

          for (final entity in result) {
            saveToCache(createEntityCacheKey('getById', entity.id), entity);
          }

          return result;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getAll');
        }
      },
      operationName: 'getAll',
    );
  }

  @override
  Future<RegistroHorarioEntity> update(RegistroHorarioEntity entity) async {
    return withRetry(
      () async {
        try {
          final model = FirebaseRegistroHorarioModel.fromEntity(entity);
          final docRef = _collection.doc(entity.id);

          final exists = await docRef.get();
          if (!exists.exists) {
            throw EntityNotFoundException(
              entityType: 'RegistroHorario',
              identifier: entity.id,
            );
          }

          await docRef.update(model.toFirestoreForUpdate());

          final updatedDoc = await docRef.get();
          final updatedModel = FirebaseRegistroHorarioModel.fromFirestore(updatedDoc);
          final updatedEntity = updatedModel.toEntity();

          saveToCache(createEntityCacheKey('getById', entity.id), updatedEntity);
          invalidateCachePattern('getAll:.*');
          invalidateCachePattern('getByPersonalId:${entity.personalId}');

          return updatedEntity;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'update');
        }
      },
      operationName: 'update',
    );
  }

  @override
  Future<void> delete(String id) async {
    return withRetry(
      () async {
        try {
          final docRef = _collection.doc(id);

          final exists = await docRef.get();
          if (!exists.exists) {
            throw EntityNotFoundException(
              entityType: 'RegistroHorario',
              identifier: id,
            );
          }

          await docRef.delete();

          clearCache();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'delete');
        }
      },
      operationName: 'delete',
    );
  }

  @override
  Future<bool> exists(String id) async {
    return withRetry(
      () async {
        try {
          final doc = await _collection.doc(id).get();
          return doc.exists;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'exists');
        }
      },
      operationName: 'exists',
    );
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchAll() {
    try {
      return _collection.snapshots().map((snapshot) {
        final entities = snapshot.docs
            .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
            .toList();

        entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

        return entities;
      });
    } catch (error, stackTrace) {
      throw handleError(error, stackTrace, 'watchAll');
    }
  }

  @override
  Stream<RegistroHorarioEntity?> watchById(String id) {
    try {
      return _collection.doc(id).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        final model = FirebaseRegistroHorarioModel.fromFirestore(snapshot);
        return model.toEntity();
      });
    } catch (error, stackTrace) {
      throw handleError(error, stackTrace, 'watchById');
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> createBatch(List<RegistroHorarioEntity> entities) async {
    return withRetry(
      () async {
        try {
          final batch = _firestore.batch();
          final createdEntities = <RegistroHorarioEntity>[];

          for (final entity in entities) {
            final model = FirebaseRegistroHorarioModel.fromEntity(entity);
            final docRef = _collection.doc(entity.id);
            batch.set(docRef, model.toFirestoreForCreate());
            createdEntities.add(entity);
          }

          await batch.commit();

          clearCache();

          return createdEntities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'createBatch');
        }
      },
      operationName: 'createBatch',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> updateBatch(List<RegistroHorarioEntity> entities) async {
    return withRetry(
      () async {
        try {
          final batch = _firestore.batch();
          final updatedEntities = <RegistroHorarioEntity>[];

          for (final entity in entities) {
            final model = FirebaseRegistroHorarioModel.fromEntity(entity);
            final docRef = _collection.doc(entity.id);
            batch.update(docRef, model.toFirestoreForUpdate());
            updatedEntities.add(entity);
          }

          await batch.commit();

          clearCache();

          return updatedEntities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'updateBatch');
        }
      },
      operationName: 'updateBatch',
    );
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    return withRetry(
      () async {
        try {
          final batch = _firestore.batch();

          for (final id in ids) {
            final docRef = _collection.doc(id);
            batch.delete(docRef);
          }

          await batch.commit();

          clearCache();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'deleteBatch');
        }
      },
      operationName: 'deleteBatch',
    );
  }

  @override
  Future<int> count() async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection.count().get();
          return snapshot.count ?? 0;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'count');
        }
      },
      operationName: 'count',
    );
  }

  @override
  Future<void> clear() async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection.get();
          final batch = _firestore.batch();

          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();

          clearCache();
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'clear');
        }
      },
      operationName: 'clear',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalId(String personalId) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('personalId', isEqualTo: personalId)
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getByPersonalId');
        }
      },
      operationName: 'getByPersonalId',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByPersonalIdAndDateRange(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('personalId', isEqualTo: personalId)
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .where((e) =>
                  e.fechaHora.isAfter(fechaInicio) &&
                  e.fechaHora.isBefore(fechaFin))
              .toList();

          entities.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getByPersonalIdAndDateRange');
        }
      },
      operationName: 'getByPersonalIdAndDateRange',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByFecha(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));
    return getByDateRange(inicio, fin);
  }

  @override
  Future<List<RegistroHorarioEntity>> getByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .where((e) =>
                  e.fechaHora.isAfter(fechaInicio) &&
                  e.fechaHora.isBefore(fechaFin))
              .toList();

          entities.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getByDateRange');
        }
      },
      operationName: 'getByDateRange',
    );
  }

  @override
  Future<RegistroHorarioEntity?> getUltimoRegistro(String personalId) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('personalId', isEqualTo: personalId)
              .where('activo', isEqualTo: true)
              .get();

          if (snapshot.docs.isEmpty) return null;

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities.first;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getUltimoRegistro');
        }
      },
      operationName: 'getUltimoRegistro',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByTipo(String tipo) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('tipo', isEqualTo: tipo)
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getByTipo');
        }
      },
      operationName: 'getByTipo',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> getByEstado(String estado) async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('estado', isEqualTo: estado)
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getByEstado');
        }
      },
      operationName: 'getByEstado',
    );
  }

  @override
  Future<RegistroHorarioEntity> registrarEntrada({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? turno,
    String? notas,
  }) async {
    final now = DateTime.now();
    final entity = RegistroHorarioEntity(
      id: _collection.doc().id,
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      tipo: 'entrada',
      fechaHora: now,
      ubicacion: ubicacion,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      vehiculoId: vehiculoId,
      vehiculoMatricula: vehiculoMatricula,
      turno: turno,
      notas: notas,
      estado: 'normal',
      esManual: false,
      activo: true,
      createdAt: now,
      updatedAt: now,
    );

    return create(entity);
  }

  @override
  Future<RegistroHorarioEntity> registrarSalida({
    required String personalId,
    String? nombrePersonal,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? notas,
  }) async {
    final now = DateTime.now();

    // Calcular horas trabajadas si hay entrada activa
    final fichajeActivo = await getFichajeActivo(personalId);
    double? horasTrabajadas;
    if (fichajeActivo != null) {
      horasTrabajadas = calcularHorasTrabajadas(fichajeActivo,
        RegistroHorarioEntity(
          id: '',
          personalId: personalId,
          tipo: 'salida',
          fechaHora: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final entity = RegistroHorarioEntity(
      id: _collection.doc().id,
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      tipo: 'salida',
      fechaHora: now,
      ubicacion: ubicacion,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      vehiculoId: vehiculoId,
      vehiculoMatricula: vehiculoMatricula,
      horasTrabajadas: horasTrabajadas,
      notas: notas,
      estado: 'normal',
      esManual: false,
      activo: true,
      createdAt: now,
      updatedAt: now,
    );

    return create(entity);
  }

  @override
  Future<RegistroHorarioEntity> registrarManual({
    required String personalId,
    String? nombrePersonal,
    required String tipo,
    required DateTime fechaHora,
    required String usuarioManualId,
    String? ubicacion,
    String? vehiculoId,
    String? turno,
    String? notas,
  }) async {
    final now = DateTime.now();
    final entity = RegistroHorarioEntity(
      id: _collection.doc().id,
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      tipo: tipo,
      fechaHora: fechaHora,
      ubicacion: ubicacion,
      vehiculoId: vehiculoId,
      turno: turno,
      notas: notas,
      estado: 'normal',
      esManual: true,
      usuarioManualId: usuarioManualId,
      activo: true,
      createdAt: now,
      updatedAt: now,
    );

    return create(entity);
  }

  @override
  double calcularHorasTrabajadas(
    RegistroHorarioEntity registroEntrada,
    RegistroHorarioEntity registroSalida,
  ) {
    final diferencia = registroSalida.fechaHora.difference(registroEntrada.fechaHora);
    return diferencia.inMinutes / 60.0;
  }

  @override
  Future<double> getHorasTrabajadasPorFecha(String personalId, DateTime fecha) async {
    final registros = await getByPersonalIdAndDateRange(
      personalId,
      DateTime(fecha.year, fecha.month, fecha.day),
      DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59),
    );

    double totalHoras = 0.0;
    RegistroHorarioEntity? ultimaEntrada;

    for (final registro in registros) {
      if (registro.tipo == 'entrada') {
        ultimaEntrada = registro;
      } else if (registro.tipo == 'salida' && ultimaEntrada != null) {
        totalHoras += calcularHorasTrabajadas(ultimaEntrada, registro);
        ultimaEntrada = null;
      }
    }

    return totalHoras;
  }

  @override
  Future<double> getHorasTrabajadasPorRango(
    String personalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final registros = await getByPersonalIdAndDateRange(
      personalId,
      fechaInicio,
      fechaFin,
    );

    double totalHoras = 0.0;
    RegistroHorarioEntity? ultimaEntrada;

    for (final registro in registros) {
      if (registro.tipo == 'entrada') {
        ultimaEntrada = registro;
      } else if (registro.tipo == 'salida' && ultimaEntrada != null) {
        totalHoras += calcularHorasTrabajadas(ultimaEntrada, registro);
        ultimaEntrada = null;
      }
    }

    return totalHoras;
  }

  @override
  Future<bool> tieneFichajeActivo(String personalId) async {
    final fichajeActivo = await getFichajeActivo(personalId);
    return fichajeActivo != null;
  }

  @override
  Future<RegistroHorarioEntity?> getFichajeActivo(String personalId) async {
    final registros = await getByPersonalId(personalId);

    RegistroHorarioEntity? ultimaEntrada;

    for (final registro in registros) {
      if (registro.tipo == 'entrada') {
        ultimaEntrada = registro;
      } else if (registro.tipo == 'salida') {
        ultimaEntrada = null;
      }
    }

    return ultimaEntrada;
  }

  @override
  Future<List<RegistroHorarioEntity>> getRegistrosManuales() async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('esManual', isEqualTo: true)
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getRegistrosManuales');
        }
      },
      operationName: 'getRegistrosManuales',
    );
  }

  @override
  Future<Map<String, dynamic>> getEstadisticas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    return withRetry(
      () async {
        try {
          List<RegistroHorarioEntity> registros;

          if (fechaInicio != null && fechaFin != null) {
            registros = await getByDateRange(fechaInicio, fechaFin);
          } else {
            registros = await getAll();
          }

          final totalRegistros = registros.length;
          final entradas = registros.where((r) => r.tipo == 'entrada').length;
          final salidas = registros.where((r) => r.tipo == 'salida').length;
          final manuales = registros.where((r) => r.esManual).length;

          return {
            'totalRegistros': totalRegistros,
            'entradas': entradas,
            'salidas': salidas,
            'manuales': manuales,
          };
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getEstadisticas');
        }
      },
      operationName: 'getEstadisticas',
    );
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByPersonalId(String personalId) {
    try {
      return _collection
          .where('personalId', isEqualTo: personalId)
          .where('activo', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final entities = snapshot.docs
            .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
            .toList();

        entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

        return entities;
      });
    } catch (error, stackTrace) {
      throw handleError(error, stackTrace, 'watchByPersonalId');
    }
  }

  @override
  Stream<List<RegistroHorarioEntity>> watchByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    try {
      return _collection
          .where('activo', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final entities = snapshot.docs
            .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
            .where((e) =>
                e.fechaHora.isAfter(fechaInicio) &&
                e.fechaHora.isBefore(fechaFin))
            .toList();

        entities.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

        return entities;
      });
    } catch (error, stackTrace) {
      throw handleError(error, stackTrace, 'watchByDateRange');
    }
  }

  @override
  Future<RegistroHorarioEntity> deactivateRegistro(String registroId) async {
    final registro = await getById(registroId);
    if (registro == null) {
      throw EntityNotFoundException(
        entityType: 'RegistroHorario',
        identifier: registroId,
      );
    }

    final updated = registro.copyWith(activo: false);
    return update(updated);
  }

  @override
  Future<RegistroHorarioEntity> reactivateRegistro(String registroId) async {
    final registro = await getById(registroId);
    if (registro == null) {
      throw EntityNotFoundException(
        entityType: 'RegistroHorario',
        identifier: registroId,
      );
    }

    final updated = registro.copyWith(activo: true);
    return update(updated);
  }

  @override
  Future<List<RegistroHorarioEntity>> getActivos() async {
    return withRetry(
      () async {
        try {
          final snapshot = await _collection
              .where('activo', isEqualTo: true)
              .get();

          final entities = snapshot.docs
              .map((doc) => FirebaseRegistroHorarioModel.fromFirestore(doc).toEntity())
              .toList();

          entities.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

          return entities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'getActivos');
        }
      },
      operationName: 'getActivos',
    );
  }

  @override
  Future<Map<String, dynamic>> exportRegistros({
    String? personalId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    return withRetry(
      () async {
        try {
          List<RegistroHorarioEntity> registros;

          if (personalId != null && fechaInicio != null && fechaFin != null) {
            registros = await getByPersonalIdAndDateRange(personalId, fechaInicio, fechaFin);
          } else if (personalId != null) {
            registros = await getByPersonalId(personalId);
          } else if (fechaInicio != null && fechaFin != null) {
            registros = await getByDateRange(fechaInicio, fechaFin);
          } else {
            registros = await getAll();
          }

          return {
            'registros': registros.map((e) => e.toJson()).toList(),
            'exportDate': DateTime.now().toIso8601String(),
            'totalRegistros': registros.length,
          };
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'exportRegistros');
        }
      },
      operationName: 'exportRegistros',
    );
  }

  @override
  Future<List<RegistroHorarioEntity>> importRegistros(
    Map<String, dynamic> registroData, {
    bool updateExisting = false,
  }) async {
    return withRetry(
      () async {
        try {
          final registrosJson = registroData['registros'] as List<dynamic>;
          final importedEntities = <RegistroHorarioEntity>[];

          for (final json in registrosJson) {
            final entity = RegistroHorarioEntity.fromJson(json as Map<String, dynamic>);

            final existing = await getById(entity.id);

            if (existing == null) {
              final created = await create(entity);
              importedEntities.add(created);
            } else if (updateExisting) {
              final updated = await update(entity);
              importedEntities.add(updated);
            }
          }

          return importedEntities;
        } catch (error, stackTrace) {
          throw handleError(error, stackTrace, 'importRegistros');
        }
      },
      operationName: 'importRegistros',
    );
  }
}
