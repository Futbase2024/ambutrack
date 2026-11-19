import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de ausencia (crear y editar)
class AusenciaFormData {
  AusenciaFormData({AusenciaEntity? original})
      : motivo = TextEditingController(text: original?.motivo ?? ''),
        observaciones = TextEditingController(text: original?.observaciones ?? ''),
        documentoAdjunto = TextEditingController(text: original?.documentoAdjunto ?? ''),
        fechaInicio = original?.fechaInicio,
        fechaFin = original?.fechaFin,
        estado = original?.estado ?? EstadoAusencia.pendiente,
        nombreArchivoExistente = original?.documentoAdjunto;

  final TextEditingController motivo;
  final TextEditingController observaciones;
  final TextEditingController documentoAdjunto;

  DateTime? fechaInicio;
  DateTime? fechaFin;
  EstadoAusencia estado;
  TipoAusenciaEntity? tipo;
  List<TipoAusenciaEntity> tipos = <TipoAusenciaEntity>[];
  PersonalEntity? personal;
  List<PersonalEntity> personalList = <PersonalEntity>[];
  int diasCalculados = 0;

  /// Archivo nuevo seleccionado (pendiente de subir)
  PlatformFile? archivo;

  /// Documento ya guardado (URL) en edición
  String? nombreArchivoExistente;

  String? get nombreArchivo => archivo?.name ?? nombreArchivoExistente;

  /// Personal activo de la empresa del usuario actual (o todo el activo si no
  /// se encuentra su empresa), ordenado por nombre
  static List<PersonalEntity> filtrarPersonal(List<PersonalEntity> todosPersonal, String? currentUserId) {
    // Buscar el personal del usuario actual para obtener su empresaId
    String? empresaIdFiltro;
    if (currentUserId != null) {
      try {
        final PersonalEntity personalActual =
            todosPersonal.firstWhere((PersonalEntity p) => p.usuarioId == currentUserId);
        empresaIdFiltro = personalActual.empresaId;
        debugPrint('👤 Personal actual: ${personalActual.nombreCompleto} (Empresa: $empresaIdFiltro)');
      } catch (e) {
        debugPrint('⚠️ No se encontró personal para usuario actual. Se mostrará todo el personal.');
      }
    }

    // Filtrar personal por empresa (si se encontró empresaId)
    final List<PersonalEntity> personalFiltrado;
    if (empresaIdFiltro != null && empresaIdFiltro.isNotEmpty) {
      personalFiltrado = todosPersonal
          .where((PersonalEntity p) => p.activo == true && p.empresaId == empresaIdFiltro)
          .toList();
      debugPrint('🏢 Personal filtrado por empresa $empresaIdFiltro: ${personalFiltrado.length} empleados');
    } else {
      // Si no se encontró empresa, mostrar todos los activos
      personalFiltrado = todosPersonal.where((PersonalEntity p) => p.activo == true).toList();
      debugPrint('⚠️ Mostrando todo el personal activo: ${personalFiltrado.length} empleados');
    }

    // Ordenar por nombre
    personalFiltrado.sort((PersonalEntity a, PersonalEntity b) => a.nombreCompleto.compareTo(b.nombreCompleto));
    return personalFiltrado;
  }

  void dispose() {
    motivo.dispose();
    observaciones.dispose();
    documentoAdjunto.dispose();
  }
}

/// Opciones y etiquetas del formulario de ausencia
class AusenciaFormOptions {
  const AusenciaFormOptions._();

  static const List<GestionOption<EstadoAusencia>> estados = <GestionOption<EstadoAusencia>>[
    GestionOption<EstadoAusencia>(EstadoAusencia.pendiente, 'Pendiente', color: AppColors.warning),
    GestionOption<EstadoAusencia>(EstadoAusencia.aprobada, 'Aprobada', color: AppColors.success),
    GestionOption<EstadoAusencia>(EstadoAusencia.rechazada, 'Rechazada', color: AppColors.error),
    GestionOption<EstadoAusencia>(EstadoAusencia.cancelada, 'Cancelada', color: AppColors.gray400),
  ];

  /// Etiqueta del estado en el diálogo de gestión
  static String estadoGestionLabel(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return 'Pendiente de aprobación';
      case EstadoAusencia.aprobada:
        return 'Aprobada';
      case EstadoAusencia.rechazada:
        return 'Rechazada';
      case EstadoAusencia.cancelada:
        return 'Cancelada';
    }
  }

  static Color estadoColor(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return AppColors.warning;
      case EstadoAusencia.aprobada:
        return AppColors.success;
      case EstadoAusencia.rechazada:
        return AppColors.error;
      case EstadoAusencia.cancelada:
        return AppColors.gray400;
    }
  }

  /// Color del tipo de ausencia guardado como "#RRGGBB"
  static Color? colorTipo(String color) {
    final int? v = int.tryParse(color.replaceFirst('#', '0xFF'));
    return v == null ? null : Color(v);
  }
}
