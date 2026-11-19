import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:flutter/foundation.dart';

/// Nombres de usuarios, certificaciones y cursos para mostrar la formación
class FormacionCatalogos {
  const FormacionCatalogos({
    this.usuarios = const <String, String>{},
    this.certificaciones = const <String, String>{},
    this.cursos = const <String, String>{},
  });

  /// id de usuario → nombre visible
  final Map<String, String> usuarios;

  /// id de certificación → "CÓDIGO - Nombre"
  final Map<String, String> certificaciones;

  /// id de curso → nombre
  final Map<String, String> cursos;

  /// Carga los catálogos desde los repositorios existentes
  static Future<FormacionCatalogos> load() async {
    try {
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        getIt<UsersDataSource>().getAll(),
        getIt<CertificacionRepository>().getAll(),
        getIt<CursoRepository>().getAll(),
      ]);
      final List<UserEntity> users = results[0] as List<UserEntity>? ?? <UserEntity>[];
      final List<CertificacionEntity> certs =
          results[1] as List<CertificacionEntity>? ?? <CertificacionEntity>[];
      final List<CursoEntity> cursos = results[2] as List<CursoEntity>? ?? <CursoEntity>[];
      return FormacionCatalogos(
        usuarios: <String, String>{
          for (final UserEntity u in users) u.id: u.displayName ?? u.email,
        },
        certificaciones: <String, String>{
          for (final CertificacionEntity c in certs) c.id: '${c.codigo} - ${c.nombre}',
        },
        cursos: <String, String>{for (final CursoEntity c in cursos) c.id: c.nombre},
      );
    } catch (e) {
      debugPrint('❌ FormacionCatalogos: error al cargar catálogos: $e');
      return const FormacionCatalogos();
    }
  }

  /// Nombre del empleado de un registro de formación
  String personal(FormacionPersonalEntity f) => usuarios[f.personalId] ?? f.personalId;

  /// Nombre de la certificación o curso de un registro de formación
  String formacion(FormacionPersonalEntity f) {
    if (f.certificacionId != null) {
      return certificaciones[f.certificacionId] ?? f.certificacionId!;
    }
    if (f.cursoId != null) {
      return cursos[f.cursoId] ?? f.cursoId!;
    }
    return GestionFormatters.vacio;
  }
}
