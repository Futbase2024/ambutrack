import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/foundation.dart';

/// Utilidades compartidas por los diálogos "Gestionar" de ausencias y vacaciones
class SolicitudGestionUtils {
  const SolicitudGestionUtils._();

  static const List<String> _meses = <String>[
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic', //
  ];

  /// "5 Ene 2025"
  static String formatDate(DateTime date) => '${date.day} ${_meses[date.month - 1]} ${date.year}';

  /// "5 Ene 2025 - 9 Ene 2025"
  static String periodo(DateTime inicio, DateTime fin) => '${formatDate(inicio)} - ${formatDate(fin)}';

  /// Ficha de Personal del usuario autenticado (quien aprueba/rechaza)
  static Future<PersonalEntity> obtenerPersonalAprobador() async {
    final String? userId = getIt<AuthService>().currentUser?.id;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }
    debugPrint('👤 Usuario autenticado: $userId');

    final List<PersonalEntity> todosPersonal = await getIt<PersonalRepository>().getAll();
    final PersonalEntity personalAprobador = todosPersonal.firstWhere(
      (PersonalEntity p) => p.usuarioId == userId,
      orElse: () => throw Exception(
        'No se encontró un registro de Personal asociado al usuario autenticado. '
        'Por favor, contacte al administrador para vincular su usuario con su ficha de personal.',
      ),
    );
    debugPrint('👤 Personal encontrado: ${personalAprobador.nombreCompleto} (${personalAprobador.id})');
    return personalAprobador;
  }
}
