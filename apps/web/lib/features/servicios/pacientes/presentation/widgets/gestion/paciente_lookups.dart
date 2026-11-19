import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/facultativos/domain/repositories/facultativo_repository.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:ambutrack_web/features/tablas/provincias/domain/repositories/provincia_repository.dart';
import 'package:flutter/foundation.dart';

/// Nombres de las tablas maestras referenciadas por el paciente (id → texto)
class PacienteLookups {
  const PacienteLookups({
    this.provincias = const <String, String>{},
    this.localidades = const <String, String>{},
    this.centros = const <String, String>{},
    this.facultativos = const <String, String>{},
  });

  final Map<String, String> provincias;
  final Map<String, String> localidades;
  final Map<String, String> centros;
  final Map<String, String> facultativos;

  static Future<PacienteLookups>? _cache;

  /// Carga (una sola vez por sesión) las tablas maestras necesarias para la ficha
  static Future<PacienteLookups> load() => _cache ??= _load();

  static Future<PacienteLookups> _load() async {
    final List<Map<String, String>> r = await Future.wait(<Future<Map<String, String>>>[
      _safe('provincias', () async => <String, String>{
            for (final ProvinciaEntity p in await getIt<ProvinciaRepository>().getAll()) p.id: p.nombre,
          }),
      _safe('localidades', () async => <String, String>{
            for (final LocalidadEntity l in await getIt<LocalidadRepository>().getAll()) l.id: l.nombre,
          }),
      _safe('centros hospitalarios', () async => <String, String>{
            for (final CentroHospitalarioEntity c in await getIt<CentroHospitalarioRepository>().getAll())
              c.id: c.nombre,
          }),
      _safe('facultativos', () async => <String, String>{
            for (final FacultativoEntity f in await getIt<FacultativoRepository>().getAll())
              f.id: f.nombreCompleto,
          }),
    ]);
    if (r.every((Map<String, String> m) => m.isEmpty)) {
      // Nada cargado: permitir reintentar en la próxima apertura de ficha
      _cache = null;
    }
    return PacienteLookups(provincias: r[0], localidades: r[1], centros: r[2], facultativos: r[3]);
  }

  static Future<Map<String, String>> _safe(String nombre, Future<Map<String, String>> Function() loader) async {
    try {
      return await loader();
    } catch (e) {
      debugPrint('❌ PacienteLookups: error al cargar $nombre: $e');
      return <String, String>{};
    }
  }

  /// Nombre del id en [mapa]; si no se encuentra devuelve el propio id (o null)
  static String? nombre(Map<String, String> mapa, String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    return mapa[id] ?? id;
  }
}
