import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Convierte texto a double admitiendo formato español ("1.234,50"). Vacío → null
double? parseDecimal(String text) => GestionFormParse.decimal(text);

/// Convierte texto a entero admitiendo separador de miles ("12.500"). Vacío → null
int? parseEntero(String text) => GestionFormParse.entero(text);

/// Formatea un decimal en formato español para un campo de texto (0 o null → vacío)
String numeroATexto(num? value) {
  if (value == null || value == 0) {
    return '';
  }
  return GestionFormParse.formatDecimal(value.toDouble());
}

/// Formatea un entero con separador de miles para un campo de texto (null → vacío)
String enteroATexto(num? value) => GestionFormParse.formatEntero(value);

/// Controllers de texto del formulario de orden
class OrdenFormControllers {
  final TextEditingController kmEntrada = TextEditingController();
  final TextEditingController kmSalida = TextEditingController();
  final TextEditingController diagnostico = TextEditingController();
  final TextEditingController trabajos = TextEditingController();
  final TextEditingController mecanico = TextEditingController();
  final TextEditingController horas = TextEditingController();
  final TextEditingController costeManoObra = TextEditingController();
  final TextEditingController costeGrua = TextEditingController();
  final TextEditingController garantia = TextEditingController();
  final TextEditingController observaciones = TextEditingController();

  List<TextEditingController> get _all => <TextEditingController>[
    kmEntrada,
    kmSalida,
    diagnostico,
    trabajos,
    mecanico,
    horas,
    costeManoObra,
    costeGrua,
    garantia,
    observaciones,
  ];

  void populate(OrdenReparacionEntity o) {
    kmEntrada.text = enteroATexto(o.kilometrajeEntrada);
    kmSalida.text = enteroATexto(o.kilometrajeSalida);
    diagnostico.text = o.diagnostico ?? '';
    trabajos.text = o.trabajosRealizados ?? '';
    mecanico.text = o.mecanicoNombre ?? '';
    horas.text = numeroATexto(o.manoObraHoras);
    costeManoObra.text = numeroATexto(o.costoManoObra);
    costeGrua.text = numeroATexto(o.costoGrua);
    garantia.text = o.garantiaMeses?.toString() ?? '';
    observaciones.text = o.observaciones ?? '';
  }

  void dispose() {
    for (final TextEditingController c in _all) {
      c.dispose();
    }
  }
}

/// Campo decimal (p.ej. horas) en formato español con validación >= 0
class OrdenDecimalField extends StatelessWidget {
  const OrdenDecimalField({required this.controller, this.unit, super.key});

  final TextEditingController controller;
  final String? unit;

  static String? _validate(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final double? parsed = parseDecimal(text);
    if (parsed == null) {
      return 'Número no válido';
    }
    return parsed < 0 ? 'Debe ser ≥ 0' : null;
  }

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: '0,00',
      suffixText: unit,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      validator: _validate,
    );
  }
}

/// Selecciones no textuales del formulario de orden
class OrdenFormSelection {
  const OrdenFormSelection({
    required this.vehiculoId,
    required this.tallerId,
    required this.origen,
    required this.prioridad,
    required this.fechaEntrada,
    required this.cubiertoSeguro,
  });

  final String? vehiculoId;
  final String? tallerId;
  final OrigenOrdenReparacion origen;
  final PrioridadOrdenReparacion prioridad;
  final DateTime fechaEntrada;
  final bool cubiertoSeguro;
}

/// Callbacks de cambio de las selecciones
class OrdenFormCallbacks {
  const OrdenFormCallbacks({
    required this.onVehiculo,
    required this.onTaller,
    required this.onOrigen,
    required this.onPrioridad,
    required this.onFecha,
    required this.onSeguro,
  });

  final ValueChanged<String?> onVehiculo;
  final ValueChanged<String?> onTaller;
  final ValueChanged<OrigenOrdenReparacion> onOrigen;
  final ValueChanged<PrioridadOrdenReparacion> onPrioridad;
  final ValueChanged<DateTime> onFecha;
  final ValueChanged<bool> onSeguro;
}
