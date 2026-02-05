import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear o editar una plantilla de turno
class PlantillaTurnoFormDialog extends StatefulWidget {
  const PlantillaTurnoFormDialog({
    super.key,
    this.plantilla,
    required this.onSave,
  });

  final PlantillaTurnoEntity? plantilla;
  final void Function(PlantillaTurnoEntity) onSave;

  @override
  State<PlantillaTurnoFormDialog> createState() =>
      _PlantillaTurnoFormDialogState();
}

class _PlantillaTurnoFormDialogState extends State<PlantillaTurnoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _horaFinController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  TipoTurno _tipoTurno = TipoTurno.manana;
  int _duracionDias = 1;
  bool _activo = true;
  bool _useCustomColor = false;

  @override
  void initState() {
    super.initState();

    if (widget.plantilla != null) {
      final PlantillaTurnoEntity p = widget.plantilla!;
      _nombreController.text = p.nombre;
      _descripcionController.text = p.descripcion ?? '';
      _horaInicioController.text = p.horaInicio;
      _horaFinController.text = p.horaFin;
      _colorController.text = p.color ?? '';
      _observacionesController.text = p.observaciones ?? '';
      _tipoTurno = p.tipoTurno;
      _duracionDias = p.duracionDias;
      _activo = p.activo;
      _useCustomColor = p.color != null && p.color!.isNotEmpty;
    } else {
      // Valores por defecto para nueva plantilla
      _horaInicioController.text = _tipoTurno.horaInicio;
      _horaFinController.text = _tipoTurno.horaFin;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _colorController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Título
            Text(
              widget.plantilla == null
                  ? 'Nueva Plantilla de Turno'
                  : 'Editar Plantilla',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Formulario
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej: Turno Mañana Estándar',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 2,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Descripción de la plantilla (opcional)',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Tipo de turno
                      AppDropdown<TipoTurno>(
                        value: _tipoTurno,
                        label: 'Tipo de Turno',
                        hint: 'Selecciona el tipo',
                        prefixIcon: Icons.access_time,
                        items: TipoTurno.values.map((TipoTurno tipo) {
                          return AppDropdownItem<TipoTurno>(
                            value: tipo,
                            label: tipo.nombre,
                            icon: Icons.circle,
                            iconColor: Color(
                              int.parse(tipo.colorHex.substring(1), radix: 16) +
                                  0xFF000000,
                            ),
                          );
                        }).toList(),
                        onChanged: (TipoTurno? value) {
                          if (value != null) {
                            setState(() {
                              _tipoTurno = value;
                              // Actualizar horarios por defecto
                              if (_horaInicioController.text.isEmpty ||
                                  _horaFinController.text.isEmpty) {
                                _horaInicioController.text = value.horaInicio;
                                _horaFinController.text = value.horaFin;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Horarios
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _horaInicioController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Hora Inicio *',
                                hintText: 'HH:mm',
                                prefixIcon: Icon(Icons.schedule),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                                  return 'Formato HH:mm';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            child: TextFormField(
                              controller: _horaFinController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Hora Fin *',
                                hintText: 'HH:mm',
                                prefixIcon: Icon(Icons.schedule),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                                  return 'Formato HH:mm';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Duración en días
                      AppDropdown<int>(
                        value: _duracionDias,
                        label: 'Duración',
                        hint: 'Días que dura el turno',
                        prefixIcon: Icons.calendar_today,
                        items: List<int>.generate(7, (int i) => i + 1)
                            .map((int dias) {
                          return AppDropdownItem<int>(
                            value: dias,
                            label: dias == 1 ? '1 día' : '$dias días',
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() => _duracionDias = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Color personalizado (opcional)
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _useCustomColor,
                            onChanged: (bool? value) {
                              setState(() => _useCustomColor = value ?? false);
                            },
                          ),
                          Text(
                            'Usar color personalizado',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      if (_useCustomColor) ...<Widget>[
                        const SizedBox(height: AppSizes.spacingSmall),
                        TextFormField(
                          controller: _colorController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Color (Hex)',
                            hintText: '#RRGGBB',
                            prefixIcon: Icon(Icons.color_lens),
                          ),
                          validator: (String? value) {
                            if (_useCustomColor &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Requerido si usa color personalizado';
                            }
                            if (_useCustomColor &&
                                !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value!)) {
                              return 'Formato: #RRGGBB';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppSizes.spacing),

                      // Observaciones
                      TextFormField(
                        controller: _observacionesController,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          hintText: 'Notas adicionales (opcional)',
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Estado
                      SwitchListTile(
                        title: Text(
                          'Activo',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        value: _activo,
                        onChanged: (bool value) {
                          setState(() => _activo = value);
                        },
                        activeTrackColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.plantilla == null ? 'Crear' : 'Guardar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Guarda la plantilla
  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final PlantillaTurnoEntity plantilla = PlantillaTurnoEntity(
      id: widget.plantilla?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      tipoTurno: _tipoTurno,
      horaInicio: _horaInicioController.text.trim(),
      horaFin: _horaFinController.text.trim(),
      color: _useCustomColor && _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      duracionDias: _duracionDias,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      activo: _activo,
    );

    widget.onSave(plantilla);
    Navigator.of(context).pop();
  }
}
