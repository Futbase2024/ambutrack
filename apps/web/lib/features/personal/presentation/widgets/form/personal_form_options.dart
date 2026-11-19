import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';

/// Opciones comunes para los formularios del módulo de Personal
class PersonalFormOptions {
  const PersonalFormOptions._();

  /// "NOMBRE APELLIDOS (DNI)" (el DNI solo si [conDni] y existe)
  static String etiqueta(PersonalEntity p, {bool conDni = false}) {
    final String dni = conDni && p.dni != null && p.dni!.isNotEmpty ? ' (${p.dni})' : '';
    return '${p.nombre} ${p.apellidos}$dni';
  }

  /// Opciones de búsqueda de personal por id (verde = activo)
  static List<GestionOption<String>> personal(List<PersonalEntity> lista, {bool conDni = false}) {
    return lista
        .map(
          (PersonalEntity p) => GestionOption<String>(
            p.id,
            etiqueta(p, conDni: conDni),
            color: p.activo ? AppColors.success : AppColors.gray400,
          ),
        )
        .toList();
  }

  /// Busca un empleado por id en la lista
  static PersonalEntity? buscar(List<PersonalEntity> lista, String? id) {
    if (id == null) {
      return null;
    }
    return lista.where((PersonalEntity p) => p.id == id).firstOrNull;
  }
}
