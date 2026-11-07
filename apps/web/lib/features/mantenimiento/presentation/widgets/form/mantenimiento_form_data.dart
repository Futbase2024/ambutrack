import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de programación de mantenimiento
class MantenimientoCreateFormData {
  MantenimientoCreateFormData({MantenimientoEntity? original})
      : fecha = original?.fecha ?? DateTime.now(),
        fechaProgramada = original?.fechaProgramada,
        tipo = original?.tipoMantenimiento ?? TipoMantenimiento.basico,
        km = TextEditingController(
          text: original == null ? '' : GestionFormParse.formatEntero(original.kmVehiculo),
        ),
        descripcion = TextEditingController(text: original?.descripcion ?? ''),
        coste = TextEditingController(text: GestionFormParse.formatDecimal(original?.costoTotal ?? 0));

  /// En edición no se precarga (se mantiene el comportamiento original)
  VehiculoEntity? vehiculo;

  /// El taller se guarda por nombre en la entidad
  String? taller;
  DateTime fecha;
  DateTime? fechaProgramada;
  TipoMantenimiento tipo;

  final TextEditingController km;
  final TextEditingController descripcion;
  final TextEditingController coste;

  double get kmValue => (GestionFormParse.entero(km.text) ?? 0).toDouble();
  double get costeValue => GestionFormParse.decimal(coste.text) ?? 0;

  void dispose() {
    km.dispose();
    descripcion.dispose();
    coste.dispose();
  }
}

/// Estado editable del formulario de edición completa de mantenimiento
class MantenimientoEditFormData {
  MantenimientoEditFormData(MantenimientoEntity m)
      : fecha = m.fecha,
        fechaProgramada = m.fechaProgramada,
        fechaInicio = m.fechaInicio,
        fechaFin = m.fechaFin,
        proximaFechaSugerida = m.proximaFechaSugerida,
        tipo = m.tipoMantenimiento,
        estado = m.estado,
        taller = m.taller,
        km = TextEditingController(text: GestionFormParse.formatEntero(m.kmVehiculo)),
        descripcion = TextEditingController(text: m.descripcion),
        trabajos = TextEditingController(text: m.trabajosRealizados ?? ''),
        mecanico = TextEditingController(text: m.mecanicoResponsable ?? ''),
        numeroOrden = TextEditingController(text: m.numeroOrden ?? ''),
        costeManoObra = TextEditingController(text: GestionFormParse.formatDecimal(m.costoManoObra)),
        costeRepuestos = TextEditingController(text: GestionFormParse.formatDecimal(m.costoRepuestos)),
        costeTotal = TextEditingController(text: GestionFormParse.formatDecimal(m.costoTotal)),
        horasInoperativo = TextEditingController(text: GestionFormParse.formatDecimal(m.tiempoInoperativoHoras)),
        proximoKm = TextEditingController(text: GestionFormParse.formatEntero(m.proximoKmSugerido));

  DateTime fecha;
  DateTime? fechaProgramada;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  DateTime? proximaFechaSugerida;
  TipoMantenimiento tipo;
  EstadoMantenimiento estado;

  /// Nombre del taller (la entidad lo guarda por nombre)
  String? taller;

  final TextEditingController km;
  final TextEditingController descripcion;
  final TextEditingController trabajos;
  final TextEditingController mecanico;
  final TextEditingController numeroOrden;
  final TextEditingController costeManoObra;
  final TextEditingController costeRepuestos;
  final TextEditingController costeTotal;
  final TextEditingController horasInoperativo;
  final TextEditingController proximoKm;

  static String? textOrNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
  static double? decimalOrNull(TextEditingController c) =>
      c.text.isEmpty ? null : GestionFormParse.decimal(c.text);

  List<TextEditingController> get _controllers => <TextEditingController>[
        km,
        descripcion,
        trabajos,
        mecanico,
        numeroOrden,
        costeManoObra,
        costeRepuestos,
        costeTotal,
        horasInoperativo,
        proximoKm,
      ];

  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
  }
}

/// Opciones de los desplegables de mantenimiento
class MantenimientoFormOptions {
  const MantenimientoFormOptions._();

  static const List<GestionOption<TipoMantenimiento>> tipos = <GestionOption<TipoMantenimiento>>[
    GestionOption<TipoMantenimiento>(TipoMantenimiento.basico, 'Básico', color: AppColors.info),
    GestionOption<TipoMantenimiento>(TipoMantenimiento.completo, 'Completo', color: AppColors.warning),
    GestionOption<TipoMantenimiento>(TipoMantenimiento.especial, 'Especial', color: AppColors.secondary),
    GestionOption<TipoMantenimiento>(TipoMantenimiento.urgente, 'Urgente', color: AppColors.error),
  ];

  static const List<GestionOption<EstadoMantenimiento>> estados = <GestionOption<EstadoMantenimiento>>[
    GestionOption<EstadoMantenimiento>(EstadoMantenimiento.programado, 'Programado', color: AppColors.info),
    GestionOption<EstadoMantenimiento>(EstadoMantenimiento.enProceso, 'En proceso', color: AppColors.warning),
    GestionOption<EstadoMantenimiento>(EstadoMantenimiento.completado, 'Completado', color: AppColors.success),
    GestionOption<EstadoMantenimiento>(EstadoMantenimiento.cancelado, 'Cancelado', color: AppColors.error),
  ];
}
