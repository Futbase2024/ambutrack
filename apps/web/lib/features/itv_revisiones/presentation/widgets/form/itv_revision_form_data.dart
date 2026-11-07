import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de ITV/Revisión (crear y editar)
class ItvRevisionFormData {
  ItvRevisionFormData({ItvRevisionEntity? original})
      : vehiculoId = original?.vehiculoId,
        tipo = original?.tipo ?? TipoItvRevision.itv,
        resultado = original?.resultado ?? ResultadoItvRevision.pendiente,
        estado = original?.estado ?? EstadoItvRevision.pendiente,
        fecha = original?.fecha ?? DateTime.now(),
        fechaVencimiento = original?.fechaVencimiento,
        taller = original?.taller,
        km = TextEditingController(text: GestionFormParse.formatEntero(original?.kmVehiculo)),
        coste = TextEditingController(text: GestionFormParse.formatDecimal(original?.costoTotal ?? 0)),
        documento = TextEditingController(text: original?.numeroDocumento ?? ''),
        observaciones = TextEditingController(text: original?.observaciones ?? '');

  String? vehiculoId;
  TipoItvRevision tipo;
  ResultadoItvRevision resultado;
  EstadoItvRevision estado;
  DateTime? fecha;
  DateTime? fechaVencimiento;

  /// El taller se guarda por nombre en la entidad
  String? taller;

  final TextEditingController km;
  final TextEditingController coste;
  final TextEditingController documento;
  final TextEditingController observaciones;

  double get kmValue => (GestionFormParse.entero(km.text) ?? 0).toDouble();
  double get costeValue => GestionFormParse.decimal(coste.text) ?? 0;
  String? get documentoValue => _nullIfEmpty(documento.text);
  String? get observacionesValue => _nullIfEmpty(observaciones.text);

  static String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  void dispose() {
    km.dispose();
    coste.dispose();
    documento.dispose();
    observaciones.dispose();
  }
}

/// Opciones de los desplegables de ITV/Revisión
class ItvRevisionFormOptions {
  const ItvRevisionFormOptions._();

  static const List<GestionOption<TipoItvRevision>> tipos = <GestionOption<TipoItvRevision>>[
    GestionOption<TipoItvRevision>(TipoItvRevision.itv, 'ITV', color: AppColors.info),
    GestionOption<TipoItvRevision>(TipoItvRevision.revisionTecnica, 'Revisión técnica', color: AppColors.secondary),
    GestionOption<TipoItvRevision>(TipoItvRevision.inspeccionAnual, 'Inspección anual', color: AppColors.warning),
    GestionOption<TipoItvRevision>(TipoItvRevision.inspeccionEspecial, 'Inspección especial', color: AppColors.primary),
  ];

  static const List<GestionOption<ResultadoItvRevision>> resultados = <GestionOption<ResultadoItvRevision>>[
    GestionOption<ResultadoItvRevision>(ResultadoItvRevision.pendiente, 'Pendiente', color: AppColors.gray500),
    GestionOption<ResultadoItvRevision>(ResultadoItvRevision.favorable, 'Favorable', color: AppColors.success),
    GestionOption<ResultadoItvRevision>(ResultadoItvRevision.desfavorable, 'Desfavorable', color: AppColors.warning),
    GestionOption<ResultadoItvRevision>(ResultadoItvRevision.negativo, 'Negativo', color: AppColors.error),
  ];

  static const List<GestionOption<EstadoItvRevision>> estados = <GestionOption<EstadoItvRevision>>[
    GestionOption<EstadoItvRevision>(EstadoItvRevision.pendiente, 'Pendiente', color: AppColors.gray500),
    GestionOption<EstadoItvRevision>(EstadoItvRevision.realizada, 'Realizada', color: AppColors.success),
    GestionOption<EstadoItvRevision>(EstadoItvRevision.vencida, 'Vencida', color: AppColors.error),
    GestionOption<EstadoItvRevision>(EstadoItvRevision.cancelada, 'Cancelada', color: AppColors.gray400),
  ];
}
