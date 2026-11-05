import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de Dotación (crear y editar)
class DotacionFormData {
  DotacionFormData({DotacionEntity? original})
      : nombre = TextEditingController(text: original?.nombre ?? ''),
        descripcion = TextEditingController(text: original?.descripcion ?? ''),
        cantidadUnidades = TextEditingController(text: original?.cantidadUnidades.toString() ?? '1'),
        prioridad = TextEditingController(text: original?.prioridad.toString() ?? '5'),
        activo = original?.activo ?? true,
        fechaInicio = original?.fechaInicio ?? DateTime.now(),
        fechaFin = original?.fechaFin,
        baseId = original?.baseId,
        contratoId = original?.contratoId,
        tipoVehiculoId = original?.tipoVehiculoId,
        dias = original == null
            ? <bool>[true, true, true, true, true, false, false]
            : <bool>[
                original.aplicaLunes,
                original.aplicaMartes,
                original.aplicaMiercoles,
                original.aplicaJueves,
                original.aplicaViernes,
                original.aplicaSabado,
                original.aplicaDomingo,
              ];

  final TextEditingController nombre;
  final TextEditingController descripcion;
  final TextEditingController cantidadUnidades;
  final TextEditingController prioridad;

  bool activo;
  DateTime fechaInicio;
  DateTime? fechaFin;

  String? baseId;
  String? contratoId;
  String? tipoVehiculoId;

  /// Lunes..Domingo
  final List<bool> dias;

  bool get tieneDias => dias.any((bool d) => d);

  void setFechaInicio(DateTime value) {
    fechaInicio = value;
    // Si la fecha fin es anterior a la nueva fecha inicio, limpiarla
    if (fechaFin != null && fechaFin!.isBefore(fechaInicio)) {
      fechaFin = null;
    }
  }

  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    cantidadUnidades.dispose();
    prioridad.dispose();
  }

  static String? validarCantidad(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cantidad es requerida';
    }
    final int? cantidad = int.tryParse(value);
    if (cantidad == null || cantidad < 1) {
      return 'Debe ser mayor a 0';
    }
    return null;
  }

  static String? validarPrioridad(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La prioridad es requerida';
    }
    final int? prioridad = int.tryParse(value);
    if (prioridad == null || prioridad < 1 || prioridad > 10) {
      return 'Debe estar entre 1 y 10';
    }
    return null;
  }
}
