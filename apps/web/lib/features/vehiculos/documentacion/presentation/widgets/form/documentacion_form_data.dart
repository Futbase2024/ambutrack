import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de documentación de vehículo
class DocumentacionFormData {
  DocumentacionFormData({DocumentacionVehiculoEntity? original})
      // Valor por defecto para crear nuevo documento: 'seguro_rc'
      : tipoDocumentoId = original?.tipoDocumentoId ?? 'seguro_rc',
        fechaEmision = original?.fechaEmision,
        fechaVencimiento = original?.fechaVencimiento,
        estado = original?.estado ?? 'vigente',
        requiereRenovacion = original?.requiereRenovacion ?? false,
        diasAlerta = original?.diasAlerta ?? 30,
        nombreArchivoExistente1 = original?.documentoUrl,
        nombreArchivoExistente2 = original?.documentoUrl2,
        numeroPoliza = TextEditingController(text: original?.numeroPoliza ?? ''),
        compania = TextEditingController(text: original?.compania ?? ''),
        costeAnual = TextEditingController(
          text: original?.costeAnual == null ? '' : GestionFormParse.formatDecimal(original!.costeAnual),
        ),
        observaciones = TextEditingController(text: original?.observaciones ?? ''),
        diasAlertaCtrl = TextEditingController(text: (original?.diasAlerta ?? 30).toString());

  String? tipoDocumentoId;
  DateTime? fechaEmision;
  DateTime? fechaVencimiento;
  String estado;
  bool requiereRenovacion;
  int diasAlerta;

  // Archivos adjuntos (nuevos seleccionados / URLs existentes)
  PlatformFile? archivoSeleccionado1;
  PlatformFile? archivoSeleccionado2;
  String? nombreArchivoExistente1;
  String? nombreArchivoExistente2;

  final TextEditingController numeroPoliza;
  final TextEditingController compania;
  final TextEditingController costeAnual;
  final TextEditingController observaciones;
  final TextEditingController diasAlertaCtrl;

  double? get costeAnualValue => GestionFormParse.decimal(costeAnual.text);
  String? get observacionesValue => observaciones.text.trim().isEmpty ? null : observaciones.text.trim();

  PlatformFile? archivo(int numero) => numero == 1 ? archivoSeleccionado1 : archivoSeleccionado2;
  String? existente(int numero) => numero == 1 ? nombreArchivoExistente1 : nombreArchivoExistente2;

  void setArchivo(int numero, PlatformFile file) {
    if (numero == 1) {
      archivoSeleccionado1 = file;
    } else {
      archivoSeleccionado2 = file;
    }
  }

  void eliminarArchivo(int numero) {
    if (numero == 1) {
      archivoSeleccionado1 = null;
      nombreArchivoExistente1 = null;
    } else {
      archivoSeleccionado2 = null;
      nombreArchivoExistente2 = null;
    }
  }

  void dispose() {
    numeroPoliza.dispose();
    compania.dispose();
    costeAnual.dispose();
    observaciones.dispose();
    diasAlertaCtrl.dispose();
  }
}

/// Opciones de los desplegables de documentación
class DocumentacionFormOptions {
  const DocumentacionFormOptions._();

  static const List<GestionOption<String>> tipos = <GestionOption<String>>[
    GestionOption<String>('seguro_rc', 'Seguro RC'),
    GestionOption<String>('seguro_todo_riesgo', 'Seguro Todo Riesgo'),
    GestionOption<String>('itv', 'ITV'),
    GestionOption<String>('permiso_municipal', 'Permiso Municipal'),
    GestionOption<String>('tarjeta_transporte', 'Tarjeta de Transporte'),
  ];

  static const List<GestionOption<String>> estados = <GestionOption<String>>[
    GestionOption<String>('vigente', 'Vigente', color: AppColors.success),
    GestionOption<String>('proxima_vencer', 'Próxima a vencer', color: AppColors.warning),
    GestionOption<String>('vencida', 'Vencida', color: AppColors.error),
  ];

  /// Añade el valor actual si no está entre las opciones (evita fallos del desplegable)
  static List<GestionOption<String>> withValue(List<GestionOption<String>> options, String? value) {
    if (value == null || options.any((GestionOption<String> o) => o.value == value)) {
      return options;
    }
    return <GestionOption<String>>[GestionOption<String>(value, value), ...options];
  }
}
