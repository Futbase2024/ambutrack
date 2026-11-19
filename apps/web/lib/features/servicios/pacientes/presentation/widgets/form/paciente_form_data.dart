import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Estado editable del formulario de paciente (crear y editar)
class PacienteFormData {
  PacienteFormData({PacienteEntity? original})
      : nombre = TextEditingController(text: original?.nombre ?? ''),
        primerApellido = TextEditingController(text: original?.primerApellido ?? ''),
        segundoApellido = TextEditingController(text: original?.segundoApellido ?? ''),
        documento = TextEditingController(text: original?.documento ?? ''),
        seguridadSocial = TextEditingController(text: original?.seguridadSocial ?? ''),
        numHistoria = TextEditingController(text: original?.numHistoria ?? ''),
        profesion = TextEditingController(text: original?.profesion ?? ''),
        tipoDocumento = original?.tipoDocumento ?? 'DNI',
        sexo = original?.sexo ?? 'HOMBRE',
        fechaNacimiento = original?.fechaNacimiento,
        paisOrigen = original?.paisOrigen ?? 'España',
        telefonoMovil = TextEditingController(text: original?.telefonoMovil ?? ''),
        telefonoFijo = TextEditingController(text: original?.telefonoFijo ?? ''),
        email = TextEditingController(text: original?.email ?? ''),
        provinciaId = original?.provinciaId,
        localidadId = original?.localidadId,
        domicilioDireccion = TextEditingController(text: original?.domicilioDireccion ?? ''),
        recogidaDireccion = TextEditingController(text: original?.recogidaInformacionAdicional ?? ''),
        mutuaAseguradora = TextEditingController(text: original?.mutuaAseguradora ?? ''),
        numPoliza = TextEditingController(text: original?.numPoliza ?? ''),
        observaciones = TextEditingController(text: original?.observaciones ?? ''),
        consentimientoInformado = original?.consentimientoInformado ?? false,
        consentimientoRgpd = original?.consentimientoRgpd ?? false;

  // Datos personales
  final TextEditingController nombre;
  final TextEditingController primerApellido;
  final TextEditingController segundoApellido;
  final TextEditingController documento;
  final TextEditingController seguridadSocial;
  final TextEditingController numHistoria;
  final TextEditingController profesion;
  String tipoDocumento;
  String sexo;
  DateTime? fechaNacimiento;
  String paisOrigen;

  // Contacto y dirección
  final TextEditingController telefonoMovil;
  final TextEditingController telefonoFijo;
  final TextEditingController email;
  String? provinciaId;
  String? localidadId;
  final TextEditingController domicilioDireccion;
  final TextEditingController recogidaDireccion;

  // Administrativo
  final TextEditingController mutuaAseguradora;
  final TextEditingController numPoliza;
  final TextEditingController observaciones;
  bool consentimientoInformado;
  bool consentimientoRgpd;

  /// Texto recortado o null si está vacío
  static String? valueOf(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  List<TextEditingController> get _controllers => <TextEditingController>[
        nombre,
        primerApellido,
        segundoApellido,
        documento,
        seguridadSocial,
        numHistoria,
        profesion,
        telefonoMovil,
        telefonoFijo,
        email,
        domicilioDireccion,
        recogidaDireccion,
        mutuaAseguradora,
        numPoliza,
        observaciones,
      ];

  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
  }
}

/// Opciones de los desplegables del formulario de paciente
class PacienteFormOptions {
  const PacienteFormOptions._();

  static const List<GestionOption<String>> tiposDocumento = <GestionOption<String>>[
    GestionOption<String>('DNI', 'DNI'),
    GestionOption<String>('NIE', 'NIE'),
    GestionOption<String>('PASAPORTE', 'Pasaporte'),
    GestionOption<String>('OTROS', 'Otros'),
  ];

  static const List<GestionOption<String>> sexos = <GestionOption<String>>[
    GestionOption<String>('HOMBRE', 'Hombre', color: AppColors.primary),
    GestionOption<String>('MUJER', 'Mujer', color: AppColors.secondary),
  ];

  static const List<GestionOption<String>> paises = <GestionOption<String>>[
    GestionOption<String>('España', 'España'),
    GestionOption<String>('Francia', 'Francia'),
    GestionOption<String>('Portugal', 'Portugal'),
    GestionOption<String>('Italia', 'Italia'),
    GestionOption<String>('Marruecos', 'Marruecos'),
    GestionOption<String>('Otro', 'Otro'),
  ];

  /// Garantiza que el valor guardado aparece entre las opciones
  static List<GestionOption<String>> withValue(List<GestionOption<String>> options, String value) {
    if (options.any((GestionOption<String> o) => o.value == value)) {
      return options;
    }
    return <GestionOption<String>>[GestionOption<String>(value, value), ...options];
  }
}

/// Convierte a mayúsculas lo que se escribe
class PacienteUpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
