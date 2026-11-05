import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Estado editable del formulario de consumo de combustible
class ConsumoFormData {
  ConsumoFormData({ConsumoCombustibleEntity? original})
      : vehiculoId = original?.vehiculoId,
        fecha = original?.fecha ?? DateTime.now(),
        tipoCombustible = original?.tipoCombustible,
        kilometraje = TextEditingController(
          text: original == null ? '' : GestionFormParse.formatEntero(original.kmVehiculo),
        ),
        litros = TextEditingController(text: original == null ? '' : GestionFormParse.formatDecimal(original.litros)),
        precio = TextEditingController(
          text: original?.precioLitro == null ? '' : _precioFmt.format(original!.precioLitro),
        ),
        costo = TextEditingController(
          text: original == null ? '' : GestionFormParse.formatDecimal(original.costoTotal),
        ),
        estacion = TextEditingController(text: original?.estacion ?? ''),
        ubicacion = TextEditingController(text: original?.ubicacion ?? '') {
    precio.addListener(_actualizarCostoTotal);
    litros.addListener(_actualizarCostoTotal);
  }

  static final NumberFormat _precioFmt = NumberFormat('#,##0.000', 'es_ES');

  String? vehiculoId;
  DateTime? fecha;
  String? tipoCombustible;

  final TextEditingController kilometraje;
  final TextEditingController litros;
  final TextEditingController precio;
  final TextEditingController costo;
  final TextEditingController estacion;
  final TextEditingController ubicacion;

  double? get kilometrajeValue => GestionFormParse.entero(kilometraje.text)?.toDouble();
  double? get litrosValue => GestionFormParse.decimal(litros.text);
  double? get precioValue => GestionFormParse.decimal(precio.text);
  double? get costoValue => GestionFormParse.decimal(costo.text);
  String? get estacionValue => _nullIfEmpty(estacion.text);
  String? get ubicacionValue => _nullIfEmpty(ubicacion.text);

  static String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  /// Coste total = litros × precio (si ambos son válidos y > 0)
  void _actualizarCostoTotal() {
    final double? l = litrosValue;
    final double? p = precioValue;
    if (l != null && p != null && l > 0 && p > 0) {
      costo.text = GestionFormParse.formatDecimal(l * p);
    }
  }

  void dispose() {
    precio.removeListener(_actualizarCostoTotal);
    litros.removeListener(_actualizarCostoTotal);
    kilometraje.dispose();
    litros.dispose();
    precio.dispose();
    costo.dispose();
    estacion.dispose();
    ubicacion.dispose();
  }
}

/// Opciones de tipo de combustible
class ConsumoFormOptions {
  const ConsumoFormOptions._();

  static String label(TipoCombustible tipo) {
    switch (tipo) {
      case TipoCombustible.gasolina95:
        return 'Gasolina 95';
      case TipoCombustible.gasolina98:
        return 'Gasolina 98';
      case TipoCombustible.diesel:
        return 'Diesel';
      case TipoCombustible.electrico:
        return 'Eléctrico';
      case TipoCombustible.hibrido:
        return 'Híbrido';
      case TipoCombustible.glp:
        return 'GLP';
      case TipoCombustible.gnc:
        return 'GNC';
      case TipoCombustible.gnl:
        return 'GNL';
    }
  }

  /// Opciones de combustible; añade el valor actual si no está en la lista
  static List<GestionOption<String>> tipos(String? actual) {
    final List<GestionOption<String>> options = TipoCombustible.values
        .map((TipoCombustible t) => GestionOption<String>(t.name, label(t)))
        .toList();
    if (actual != null && !options.any((GestionOption<String> o) => o.value == actual)) {
      options.insert(0, GestionOption<String>(actual, actual));
    }
    return options;
  }
}
