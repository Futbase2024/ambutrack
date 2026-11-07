import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Estado editable de una ubicación (origen o destino) de un trayecto
class TrayectoUbicacion {
  TrayectoUbicacion({required this.tipo, required this.value}) {
    if (esDomicilio(tipo)) {
      direccion = TextEditingController(text: value ?? '');
    }
  }

  static const String domicilioPaciente = 'domicilio_paciente';
  static const String otroDomicilio = 'otro_domicilio';
  static const String centroHospitalario = 'centro_hospitalario';

  String? tipo;

  /// Dirección (domicilios) o ID del centro hospitalario
  String? value;
  TextEditingController? direccion;
  CentroHospitalarioEntity? centro;

  static bool esDomicilio(String? tipo) => tipo == domicilioPaciente || tipo == otroDomicilio;

  /// Cambia el tipo y limpia el valor anterior
  void setTipo(String? nuevo) {
    tipo = nuevo;
    value = null;
    centro = null;
    direccion?.dispose();
    direccion = esDomicilio(nuevo) ? TextEditingController() : null;
  }

  void setCentro(CentroHospitalarioEntity? nuevo) {
    centro = nuevo;
    value = nuevo?.id;
  }

  /// Localiza el centro guardado por ID o, en datos antiguos, por nombre
  void resolverCentro(List<CentroHospitalarioEntity> centros, String etiqueta) {
    if (tipo != centroHospitalario || value == null) {
      debugPrint('ℹ️ $etiqueta no es centro hospitalario: tipo=$tipo, valor=$value');
      return;
    }
    centro = centros.where((CentroHospitalarioEntity c) => c.id == value).firstOrNull;
    if (centro != null) {
      debugPrint('✅ Centro $etiqueta encontrado por ID: ${centro!.nombre}');
      return;
    }
    centro = centros.where((CentroHospitalarioEntity c) => c.nombre == value).firstOrNull;
    if (centro != null) {
      debugPrint('✅ Centro $etiqueta encontrado por NOMBRE: ${centro!.nombre} → ID ${centro!.id}');
      value = centro!.id; // Actualiza al ID correcto para futuras actualizaciones
    } else {
      debugPrint('❌ Centro $etiqueta NO encontrado ni por ID ni por nombre: $value');
    }
  }

  void dispose() => direccion?.dispose();
}

/// Selector de ubicación: tipo + dirección o centro hospitalario
class TrayectoUbicacionField extends StatelessWidget {
  const TrayectoUbicacionField({
    required this.ubicacion,
    required this.centros,
    required this.onChanged,
    super.key,
  });

  final TrayectoUbicacion ubicacion;
  final List<CentroHospitalarioEntity> centros;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  static const List<GestionOption<String>> _tipos = <GestionOption<String>>[
    GestionOption<String>(TrayectoUbicacion.domicilioPaciente, 'Domicilio paciente', color: AppColors.info),
    GestionOption<String>(TrayectoUbicacion.otroDomicilio, 'Otro domicilio', color: AppColors.warning),
    GestionOption<String>(TrayectoUbicacion.centroHospitalario, 'Centro hospitalario', color: AppColors.error),
  ];

  static String? _validarDireccion(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Por favor ingrese la dirección' : null;

  @override
  Widget build(BuildContext context) {
    final String? tipo = ubicacion.tipo;
    final bool tipoValido = _tipos.any((GestionOption<String> o) => o.value == tipo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormRow(
          label: 'Tipo',
          child: GestionDropdownField<String>(
            value: tipoValido ? tipo : null,
            options: _tipos,
            hint: 'Seleccione tipo',
            onChanged: (String? v) {
              ubicacion.setTipo(v);
              onChanged();
            },
          ),
        ),
        if (TrayectoUbicacion.esDomicilio(tipo))
          GestionFormRow(
            label: 'Dirección',
            required: true,
            multiline: true,
            child: GestionTextField(
              key: ValueKey<String>('direccion_$tipo'),
              controller: ubicacion.direccion!,
              hint: tipo == TrayectoUbicacion.domicilioPaciente
                  ? 'Dirección del domicilio del paciente'
                  : 'Ingrese dirección',
              maxLines: 2,
              validator: _validarDireccion,
              onChanged: (String v) => ubicacion.value = v,
            ),
          )
        else if (tipo == TrayectoUbicacion.centroHospitalario)
          GestionFormRow(
            label: 'Centro',
            child: GestionSearchField<String>(
              value: ubicacion.centro?.id,
              hint: 'Buscar centro por nombre',
              options: centros
                  .map((CentroHospitalarioEntity c) => GestionOption<String>(c.id, c.nombre))
                  .toList(),
              onChanged: (String? id) {
                ubicacion.setCentro(centros.where((CentroHospitalarioEntity c) => c.id == id).firstOrNull);
                onChanged();
              },
            ),
          )
        else
          const GestionFormRow(
            label: 'Ubicación',
            child: GestionFormReadOnly(value: 'Seleccione un tipo de ubicación'),
          ),
      ],
    );
  }
}
