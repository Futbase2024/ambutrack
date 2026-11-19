import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity;
// ignore: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/movimiento_stock_entity.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_repository.dart';
import 'package:ambutrack_web/features/usuarios/domain/repositories/usuarios_repository.dart';
import 'package:flutter/foundation.dart';

/// Nombres legibles de las referencias de un movimiento de stock
class MovimientoNombres {
  const MovimientoNombres({this.almacenOrigen, this.almacenDestino, this.servicio, this.usuario});

  final String? almacenOrigen;
  final String? almacenDestino;
  final String? servicio;
  final String? usuario;
}

/// Resuelve (con caché en memoria) los nombres de almacenes, servicios y usuarios
/// referenciados por los movimientos de stock. Si algo falla, devuelve el id original.
class MovimientoLookups {
  MovimientoLookups._();

  static Future<Map<String, String>>? _almacenes;
  static Future<Map<String, String>>? _usuarios;
  static final Map<String, Future<String?>> _servicios = <String, Future<String?>>{};

  /// Resuelve todos los nombres del movimiento [m]
  static Future<MovimientoNombres> resolve(MovimientoStockEntity m) async {
    final List<Object?> r = await Future.wait<Object?>(<Future<Object?>>[
      _almacenesMap(),
      _usuariosMap(),
      _servicio(m.idServicio),
    ]);
    final Map<String, String> almacenes = r[0]! as Map<String, String>;
    final Map<String, String> usuarios = r[1]! as Map<String, String>;
    return MovimientoNombres(
      almacenOrigen: _nombre(almacenes, m.idAlmacenOrigen),
      almacenDestino: _nombre(almacenes, m.idAlmacenDestino),
      servicio: (r[2] as String?) ?? m.idServicio,
      usuario: _nombre(usuarios, m.usuarioId),
    );
  }

  static String? _nombre(Map<String, String> mapa, String? id) => id == null ? null : (mapa[id] ?? id);

  static Future<Map<String, String>> _almacenesMap() {
    return _almacenes ??= _loadAlmacenes();
  }

  static Future<Map<String, String>> _loadAlmacenes() async {
    try {
      final List<AlmacenEntity> lista = await AlmacenDataSourceFactory.createSupabase().getAll();
      return <String, String>{
        for (final AlmacenEntity a in lista) a.id: a.codigo.isEmpty ? a.nombre : '${a.nombre} (${a.codigo})',
      };
    } catch (e) {
      debugPrint('❌ MovimientoLookups: error al cargar almacenes: $e');
      _almacenes = null;
      return <String, String>{};
    }
  }

  static Future<Map<String, String>> _usuariosMap() {
    return _usuarios ??= _loadUsuarios();
  }

  /// Mapa id de usuario (auth) → nombre. Prioriza la ficha de personal vinculada.
  static Future<Map<String, String>> _loadUsuarios() async {
    final Map<String, String> mapa = <String, String>{};
    try {
      final List<UserEntity> usuarios = await getIt<UsuariosRepository>().getAll();
      for (final UserEntity u in usuarios) {
        final String? nombre = u.displayName?.trim().isNotEmpty ?? false ? u.displayName : u.email;
        if (nombre != null && nombre.isNotEmpty) {
          mapa[u.id] = nombre;
        }
      }
    } catch (e) {
      debugPrint('⚠️ MovimientoLookups: no se pudieron cargar usuarios: $e');
    }
    try {
      final List<PersonalEntity> personal = await getIt<PersonalRepository>().getAll();
      for (final PersonalEntity p in personal) {
        final String? uid = p.usuarioId;
        if (uid != null && uid.isNotEmpty) {
          mapa[uid] = p.nombreCompleto;
        }
      }
    } catch (e) {
      debugPrint('⚠️ MovimientoLookups: no se pudo cargar personal: $e');
    }
    if (mapa.isEmpty) {
      _usuarios = null;
    }
    return mapa;
  }

  static Future<String?> _servicio(String? id) {
    if (id == null || id.isEmpty) {
      return Future<String?>.value();
    }
    return _servicios[id] ??= _loadServicio(id);
  }

  static Future<String?> _loadServicio(String id) async {
    try {
      final ServicioEntity? s = await getIt<ServicioRepository>().getById(id);
      if (s == null) {
        return null;
      }
      final String? paciente = s.paciente?.nombreCompleto;
      final String codigo = s.codigo ?? '';
      if (paciente == null || paciente.isEmpty) {
        return codigo.isEmpty ? null : codigo;
      }
      return codigo.isEmpty ? paciente : '$codigo · $paciente';
    } catch (e) {
      debugPrint('⚠️ MovimientoLookups: no se pudo cargar el servicio $id: $e');
      unawaited(_servicios.remove(id));
      return null;
    }
  }
}
