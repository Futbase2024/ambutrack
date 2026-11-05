import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Convierte texto a double admitiendo coma decimal. Vacío → null
double? parseDecimal(String text) {
  final String v = text.trim().replaceAll(',', '.');
  return v.isEmpty ? null : double.tryParse(v);
}

/// Convierte texto a entero. Vacío → null
int? parseEntero(String text) {
  final String v = text.trim();
  return v.isEmpty ? null : int.tryParse(v);
}

/// Formatea un número para un campo de texto (sin decimales si es entero)
String numeroATexto(num? value) {
  if (value == null || value == 0) {
    return '';
  }
  return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}

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
    kmEntrada.text = o.kilometrajeEntrada?.toString() ?? '';
    kmSalida.text = o.kilometrajeSalida?.toString() ?? '';
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

/// Campo numérico (entero o decimal) con validación >= 0
class OrdenNumberField extends StatelessWidget {
  const OrdenNumberField({required this.controller, required this.label, this.integer = false, super.key});

  final TextEditingController controller;
  final String label;
  final bool integer;

  String? _validate(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final num? parsed = integer ? parseEntero(text) : parseDecimal(text);
    if (parsed == null) {
      return 'Número no válido';
    }
    return parsed < 0 ? 'Debe ser ≥ 0' : null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(integer ? RegExp('[0-9]') : RegExp('[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
      validator: _validate,
    );
  }
}

/// Campo de solo lectura que abre un selector de fecha
class OrdenFechaField extends StatelessWidget {
  const OrdenFechaField({required this.label, required this.fecha, required this.onTap, super.key});

  final String label;
  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        child: Text(formatFecha(fecha)),
      ),
    );
  }
}

/// Mensaje de error bajo un campo personalizado
class OrdenFieldError extends StatelessWidget {
  const OrdenFieldError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.error)),
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
    required this.onPickFecha,
    required this.onSeguro,
  });

  final ValueChanged<String?> onVehiculo;
  final ValueChanged<String?> onTaller;
  final ValueChanged<OrigenOrdenReparacion> onOrigen;
  final ValueChanged<PrioridadOrdenReparacion> onPrioridad;
  final VoidCallback onPickFecha;
  final ValueChanged<bool> onSeguro;
}
