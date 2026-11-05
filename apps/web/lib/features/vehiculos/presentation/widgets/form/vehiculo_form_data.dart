import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de vehículo (crear y editar)
class VehiculoFormData {
  VehiculoFormData({VehiculoEntity? original})
      : estado = original?.estado ?? VehiculoEstado.activo,
        fechaAdquisicion = original?.fechaAdquisicion,
        fechaProximaItv = original?.proximaItv,
        fechaUltimoMantenimiento = original?.ultimoMantenimiento,
        proximoMantenimiento = original?.proximoMantenimiento,
        matricula = TextEditingController(text: original?.matricula ?? ''),
        tipo = TextEditingController(text: original?.tipoVehiculo ?? ''),
        marca = TextEditingController(text: original?.marca ?? ''),
        modelo = TextEditingController(text: original?.modelo ?? ''),
        anio = TextEditingController(
          text: original?.anioFabricacion.toString() ?? DateTime.now().year.toString(),
        ),
        numeroSerie = TextEditingController(text: original?.numeroBastidor ?? ''),
        conductor = TextEditingController(),
        ubicacion = TextEditingController(text: original?.ubicacionActual ?? ''),
        kmActual = TextEditingController(
          text: original?.kmActual == null ? '0' : GestionFormParse.formatEntero(original!.kmActual),
        ),
        camillas = TextEditingController(text: original?.capacidadCamilla?.toString() ?? ''),
        sillaRuedas = TextEditingController(),
        sentados = TextEditingController(text: original?.capacidadPasajeros?.toString() ?? ''),
        kmProxMantenimiento = TextEditingController(
          text: GestionFormParse.formatEntero(original?.kmProximoMantenimiento),
        ),
        observaciones = TextEditingController(text: original?.observaciones ?? '');

  VehiculoEstado estado;
  bool activo = true;
  DateTime? fechaAdquisicion;
  DateTime? fechaProximaItv;
  DateTime? fechaUltimoMantenimiento;
  DateTime? proximoMantenimiento;

  final TextEditingController matricula;
  final TextEditingController tipo;
  final TextEditingController marca;
  final TextEditingController modelo;
  final TextEditingController anio;
  final TextEditingController numeroSerie;
  final TextEditingController conductor;
  final TextEditingController ubicacion;
  final TextEditingController kmActual;
  final TextEditingController camillas;
  final TextEditingController sillaRuedas;
  final TextEditingController sentados;
  final TextEditingController kmProxMantenimiento;
  final TextEditingController observaciones;

  int? get camillasValue => GestionFormParse.entero(camillas.text);
  int? get sentadosValue => GestionFormParse.entero(sentados.text);
  double? get kmActualValue => GestionFormParse.entero(kmActual.text)?.toDouble();
  int? get kmProxMantenimientoValue => GestionFormParse.entero(kmProxMantenimiento.text);
  String? get ubicacionValue => _nullIfEmpty(ubicacion.text);
  String? get observacionesValue => _nullIfEmpty(observaciones.text);

  static String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      matricula,
      tipo,
      marca,
      modelo,
      anio,
      numeroSerie,
      conductor,
      ubicacion,
      kmActual,
      camillas,
      sillaRuedas,
      sentados,
      kmProxMantenimiento,
      observaciones,
    ]) {
      c.dispose();
    }
  }
}

/// Opciones de los desplegables del formulario de vehículo
class VehiculoFormOptions {
  const VehiculoFormOptions._();

  static const List<GestionOption<VehiculoEstado>> estados = <GestionOption<VehiculoEstado>>[
    GestionOption<VehiculoEstado>(VehiculoEstado.activo, 'Activo', color: AppColors.success),
    GestionOption<VehiculoEstado>(VehiculoEstado.mantenimiento, 'Mantenimiento', color: AppColors.warning),
    GestionOption<VehiculoEstado>(VehiculoEstado.reparacion, 'Reparación', color: AppColors.error),
    GestionOption<VehiculoEstado>(VehiculoEstado.baja, 'Baja', color: AppColors.inactive),
  ];
}
