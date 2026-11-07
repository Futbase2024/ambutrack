import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de vacaciones (crear y editar)
class VacacionFormData {
  VacacionFormData({VacacionesEntity? original})
      : observaciones = TextEditingController(text: original?.observaciones ?? ''),
        documentoAdjunto = TextEditingController(text: original?.documentoAdjunto ?? ''),
        fechaInicio = original?.fechaInicio,
        fechaFin = original?.fechaFin,
        estado = original?.estado ?? 'pendiente',
        nombreArchivoExistente = original?.documentoAdjunto;

  final TextEditingController observaciones;
  final TextEditingController documentoAdjunto;

  DateTime? fechaInicio;
  DateTime? fechaFin;
  String estado;
  PersonalEntity? personal;
  List<PersonalEntity> personalList = <PersonalEntity>[];

  /// Archivo nuevo seleccionado (pendiente de subir)
  PlatformFile? archivo;

  /// Documento ya guardado (URL) en edición
  String? nombreArchivoExistente;

  String? get nombreArchivo => archivo?.name ?? nombreArchivoExistente;

  void dispose() {
    observaciones.dispose();
    documentoAdjunto.dispose();
  }
}

/// Opciones y etiquetas de vacaciones
class VacacionFormOptions {
  const VacacionFormOptions._();

  static const List<GestionOption<String>> estados = <GestionOption<String>>[
    GestionOption<String>('pendiente', 'Pendiente', color: AppColors.warning),
    GestionOption<String>('aprobada', 'Aprobada', color: AppColors.success),
    GestionOption<String>('rechazada', 'Rechazada', color: AppColors.error),
    GestionOption<String>('cancelada', 'Cancelada', color: AppColors.gray400),
  ];

  static String personalLabel(PersonalEntity p) => '${p.nombre} ${p.apellidos} (${p.dni})';

  /// Etiqueta del estado en el diálogo de gestión
  static String estadoGestionLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente de aprobación';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return estado;
    }
  }

  static Color estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.warning;
      case 'aprobada':
        return AppColors.success;
      case 'rechazada':
        return AppColors.error;
      default:
        return AppColors.gray400;
    }
  }
}
