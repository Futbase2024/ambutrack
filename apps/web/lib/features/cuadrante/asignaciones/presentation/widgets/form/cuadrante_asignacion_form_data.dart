import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de asignación de cuadrante
class CuadranteAsignacionFormData {
  CuadranteAsignacionFormData({CuadranteAsignacionEntity? original, DateTime? fechaInicial})
      : fecha = original?.fecha ?? fechaInicial ?? DateTime.now(),
        horaInicio = TextEditingController(text: original?.horaInicio ?? '08:00'),
        horaFin = TextEditingController(text: original?.horaFin ?? '16:00'),
        numeroUnidad = TextEditingController(text: (original?.numeroUnidad ?? 1).toString()),
        observaciones = TextEditingController(text: original?.observaciones ?? ''),
        cruzaMedianoche = original?.cruzaMedianoche ?? false,
        tipoTurno = original?.tipoTurno ?? TipoTurnoAsignacion.manana,
        estado = original?.estado ?? EstadoAsignacion.planificada;

  DateTime fecha;
  final TextEditingController horaInicio;
  final TextEditingController horaFin;
  final TextEditingController numeroUnidad;
  final TextEditingController observaciones;
  bool cruzaMedianoche;
  TipoTurnoAsignacion tipoTurno;
  EstadoAsignacion estado;

  PersonalEntity? personal;
  VehiculoEntity? vehiculo;
  DotacionEntity? dotacion;

  int get numeroUnidadValue => int.tryParse(numeroUnidad.text) ?? 1;
  String? get observacionesValue => observaciones.text.trim().isEmpty ? null : observaciones.text.trim();

  void dispose() {
    horaInicio.dispose();
    horaFin.dispose();
    numeroUnidad.dispose();
    observaciones.dispose();
  }

  /// Hora HH:mm obligatoria y dentro de rango
  static String? validarHora(String? value) {
    if (value == null || value.isEmpty) {
      return 'La hora es obligatoria';
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
      return 'Formato inválido (HH:mm)';
    }
    final List<String> partes = value.split(':');
    final int h = int.parse(partes[0]);
    final int m = int.parse(partes[1]);
    if (h > 23 || m > 59) {
      return 'Hora inválida';
    }
    return null;
  }

  /// Número de unidad >= 1
  static String? validarUnidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }
    final int? num = int.tryParse(value);
    if (num == null || num < 1) {
      return 'Debe ser >= 1';
    }
    return null;
  }
}

/// Opciones de los desplegables de asignación de cuadrante
class CuadranteAsignacionFormOptions {
  const CuadranteAsignacionFormOptions._();

  static const List<GestionOption<TipoTurnoAsignacion>> tiposTurno = <GestionOption<TipoTurnoAsignacion>>[
    GestionOption<TipoTurnoAsignacion>(TipoTurnoAsignacion.manana, 'Mañana'),
    GestionOption<TipoTurnoAsignacion>(TipoTurnoAsignacion.tarde, 'Tarde'),
    GestionOption<TipoTurnoAsignacion>(TipoTurnoAsignacion.noche, 'Noche'),
    GestionOption<TipoTurnoAsignacion>(TipoTurnoAsignacion.personalizado, 'Personalizado'),
  ];

  static const List<GestionOption<EstadoAsignacion>> estados = <GestionOption<EstadoAsignacion>>[
    GestionOption<EstadoAsignacion>(EstadoAsignacion.planificada, 'Planificada', color: AppColors.info),
    GestionOption<EstadoAsignacion>(EstadoAsignacion.confirmada, 'Confirmada', color: AppColors.primary),
    GestionOption<EstadoAsignacion>(EstadoAsignacion.activa, 'Activa', color: AppColors.success),
    GestionOption<EstadoAsignacion>(EstadoAsignacion.completada, 'Completada', color: AppColors.textSecondaryLight),
    GestionOption<EstadoAsignacion>(EstadoAsignacion.cancelada, 'Cancelada', color: AppColors.error),
  ];
}
