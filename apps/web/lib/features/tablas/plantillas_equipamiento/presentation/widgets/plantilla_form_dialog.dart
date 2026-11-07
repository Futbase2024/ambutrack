import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_form_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tipos de vehículo de la flota (valores de `tvehiculos.tipo_vehiculo`)
const List<String> tiposVehiculoFlota = <String>['COLECTIVA', 'CONVENCIONAL', 'UVI MÓVIL'];

/// Formulario de alta / edición de una plantilla de equipamiento
class PlantillaFormDialog extends StatefulWidget {
  const PlantillaFormDialog({this.plantilla, super.key});

  final PlantillaEquipamientoEntity? plantilla;

  @override
  State<PlantillaFormDialog> createState() => _PlantillaFormDialogState();
}

class _PlantillaFormDialogState extends State<PlantillaFormDialog> with PlantillaFormSave<PlantillaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final Set<String> _tipos;
  DateTime? _fechaVersion;
  bool _activo = true;

  @override
  String get entityName => 'Plantilla';

  @override
  bool get isEditing => widget.plantilla != null;

  @override
  void initState() {
    super.initState();
    final PlantillaEquipamientoEntity? p = widget.plantilla;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _tipos = <String>{...?p?.tiposVehiculo};
    _fechaVersion = p?.fechaVersion;
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String descripcion = _descripcion.text.trim();
    final PlantillaEquipamientoEntity plantilla = PlantillaEquipamientoEntity(
      id: widget.plantilla?.id ?? '',
      nombre: _nombre.text.trim().toUpperCase(),
      descripcion: descripcion.isEmpty ? null : descripcion,
      tiposVehiculo: tiposVehiculoFlota.where(_tipos.contains).toList(),
      fechaVersion: _fechaVersion,
      activo: _activo,
      empresaId: widget.plantilla?.empresaId,
    );
    guardar(PlantillaSaveRequested(plantilla, esNueva: !isEditing));
  }

  void _toggleTipo(String tipo, {required bool seleccionado}) => setState(() {
        if (seleccionado) {
          _tipos.add(tipo);
        } else {
          _tipos.remove(tipo);
        }
      });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantillasEquipamientoBloc, PlantillasEquipamientoState>(
      listenWhen: listenWhen,
      listener: onBlocState,
      child: GestionFormDialog(
        title: isEditing ? 'Editar plantilla' : 'Nueva plantilla',
        subtitle: widget.plantilla?.nombre,
        icon: Icons.inventory_outlined,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: isEditing,
        isSaving: isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Datos', first: true),
          GestionFormRow(
            label: 'Nombre',
            required: true,
            child: GestionTextField(
              controller: _nombre,
              hint: 'Ej: DOTACIÓN AMBULANCIA A1/A2',
              inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
          ),
          GestionFormRow(
            label: 'Descripción',
            multiline: true,
            child: GestionTextField(controller: _descripcion, hint: 'Protocolo de origen...', maxLines: 3),
          ),
          GestionFormRow(
            label: 'Versión',
            child: GestionDateField(value: _fechaVersion, onChanged: (DateTime? v) => setState(() => _fechaVersion = v)),
          ),
          const GestionFormSection(title: 'Se aplica a'),
          for (final String tipo in tiposVehiculoFlota)
            GestionFormRow(
              label: '',
              child: GestionCheckField(
                value: _tipos.contains(tipo),
                text: tipo,
                onChanged: (bool v) => _toggleTipo(tipo, seleccionado: v),
              ),
            ),
          GestionFormRow(
            label: 'Estado',
            child: GestionSwitchField(
              value: _activo,
              text: _activo ? 'Activa (se aplica a los vehículos)' : 'Inactiva',
              onChanged: (bool v) => setState(() => _activo = v),
            ),
          ),
        ],
      ),
    );
  }
}
