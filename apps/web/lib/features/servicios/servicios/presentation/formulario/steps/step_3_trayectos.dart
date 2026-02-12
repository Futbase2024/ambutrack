import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/tipo_ubicacion.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/trayecto_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget del Paso 3: Configuración de Trayectos
class Step3Trayectos extends StatefulWidget {
  const Step3Trayectos({
    required this.formKey,
    required this.trayectos,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.loadingCentros,
    required this.pacienteNombreCompleto,
    required this.onTrayectosChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final List<TrayectoData> trayectos;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final bool loadingCentros;
  final String? pacienteNombreCompleto;
  final void Function(List<TrayectoData>) onTrayectosChanged;

  @override
  State<Step3Trayectos> createState() => _Step3TrayectosState();
}

class _Step3TrayectosState extends State<Step3Trayectos> {
  void _agregarTrayecto() {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos)..add(TrayectoData());
    widget.onTrayectosChanged(newTrayectos);
  }

  void _eliminarTrayecto(int index) {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos)..removeAt(index);
    widget.onTrayectosChanged(newTrayectos);
  }

  void _updateTrayecto(int index, TrayectoData trayecto) {
    final List<TrayectoData> newTrayectos = List<TrayectoData>.from(widget.trayectos);
    newTrayectos[index] = trayecto;
    widget.onTrayectosChanged(newTrayectos);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Trayectos del Servicio',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Define el origen, destino y horario de cada trayecto',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                onPressed: _agregarTrayecto,
                label: 'Agregar Trayecto',
                icon: Icons.add,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),

          // Lista de trayectos
          ...List<Widget>.generate(widget.trayectos.length, (int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing),
              child: _TrayectoCard(
                index: index,
                trayecto: widget.trayectos[index],
                loadingCentros: widget.loadingCentros,
                centrosHospitalarios: widget.centrosHospitalarios,
                centrosDropdownItems: widget.centrosDropdownItems,
                pacienteNombreCompleto: widget.pacienteNombreCompleto,
                canDelete: widget.trayectos.length > 1,
                onDelete: () => _eliminarTrayecto(index),
                onUpdate: (TrayectoData trayecto) => _updateTrayecto(index, trayecto),
              ),
            );
          }),

          if (widget.trayectos.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  'Agrega al menos un trayecto',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card de trayecto individual
class _TrayectoCard extends StatefulWidget {
  const _TrayectoCard({
    required this.index,
    required this.trayecto,
    required this.loadingCentros,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.pacienteNombreCompleto,
    required this.canDelete,
    required this.onDelete,
    required this.onUpdate,
  });

  final int index;
  final TrayectoData trayecto;
  final bool loadingCentros;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final String? pacienteNombreCompleto;
  final bool canDelete;
  final VoidCallback onDelete;
  final void Function(TrayectoData) onUpdate;

  @override
  State<_TrayectoCard> createState() => _TrayectoCardState();
}

class _TrayectoCardState extends State<_TrayectoCard> {
  late TrayectoData _trayecto;

  @override
  void initState() {
    super.initState();
    _trayecto = widget.trayecto;
  }

  void _updateField(void Function() update) {
    setState(() {
      update();
    });
    widget.onUpdate(_trayecto);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Trayecto ${widget.index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (widget.canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: widget.onDelete,
                  tooltip: 'Eliminar trayecto',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Layout horizontal: Origen | Destino | Hora
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // === ORIGEN ===
              Expanded(
                child: _UbicacionSelector(
                  label: 'Origen *',
                  tipoUbicacion: _trayecto.tipoOrigen,
                  domicilio: _trayecto.origenDomicilio,
                  centroNombre: _trayecto.origenCentro,
                  loadingCentros: widget.loadingCentros,
                  centrosHospitalarios: widget.centrosHospitalarios,
                  centrosDropdownItems: widget.centrosDropdownItems,
                  pacienteNombreCompleto: widget.pacienteNombreCompleto,
                  onTipoChanged: (TipoUbicacion tipo) => _updateField(() => _trayecto.tipoOrigen = tipo),
                  onDomicilioChanged: (String? value) => _updateField(() => _trayecto.origenDomicilio = value),
                  onCentroChanged: (String? nombre) => _updateField(() => _trayecto.origenCentro = nombre),
                ),
              ),
              const SizedBox(width: 12),

              // === DESTINO ===
              Expanded(
                child: _UbicacionSelector(
                  label: 'Destino *',
                  tipoUbicacion: _trayecto.tipoDestino,
                  domicilio: _trayecto.destinoDomicilio,
                  centroNombre: _trayecto.destinoCentro,
                  loadingCentros: widget.loadingCentros,
                  centrosHospitalarios: widget.centrosHospitalarios,
                  centrosDropdownItems: widget.centrosDropdownItems,
                  pacienteNombreCompleto: widget.pacienteNombreCompleto,
                  onTipoChanged: (TipoUbicacion tipo) => _updateField(() => _trayecto.tipoDestino = tipo),
                  onDomicilioChanged: (String? value) => _updateField(() => _trayecto.destinoDomicilio = value),
                  onCentroChanged: (String? nombre) => _updateField(() => _trayecto.destinoCentro = nombre),
                ),
              ),
              const SizedBox(width: 12),

              // === HORA ===
              SizedBox(
                width: 130,
                child: _HoraField(
                  controller: _trayecto.horaController ?? (_trayecto.horaController = TextEditingController()),
                  onChanged: (TimeOfDay? hora) => _updateField(() => _trayecto.hora = hora),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selector de ubicación (origen/destino)
class _UbicacionSelector extends StatelessWidget {
  const _UbicacionSelector({
    required this.label,
    required this.tipoUbicacion,
    required this.domicilio,
    required this.centroNombre,
    required this.loadingCentros,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.pacienteNombreCompleto,
    required this.onTipoChanged,
    required this.onDomicilioChanged,
    required this.onCentroChanged,
  });

  final String label;
  final TipoUbicacion tipoUbicacion;
  final String? domicilio;
  final String? centroNombre;
  final bool loadingCentros;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final String? pacienteNombreCompleto;
  final void Function(TipoUbicacion) onTipoChanged;
  final void Function(String?) onDomicilioChanged;
  final void Function(String?) onCentroChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        // Botones de tipo (compactos)
        Row(
          children: <Widget>[
            _UbicacionOptionButton(
              icon: Icons.home,
              tooltip: 'Domicilio paciente',
              isSelected: tipoUbicacion == TipoUbicacion.domicilioPaciente,
              onTap: () => onTipoChanged(TipoUbicacion.domicilioPaciente),
            ),
            const SizedBox(width: 4),
            _UbicacionOptionButton(
              icon: Icons.location_on,
              tooltip: 'Otro domicilio',
              isSelected: tipoUbicacion == TipoUbicacion.otroDomicilio,
              onTap: () => onTipoChanged(TipoUbicacion.otroDomicilio),
            ),
            const SizedBox(width: 4),
            _UbicacionOptionButton(
              icon: Icons.local_hospital,
              tooltip: 'Centro hospitalario',
              isSelected: tipoUbicacion == TipoUbicacion.centroHospitalario,
              onTap: () => onTipoChanged(TipoUbicacion.centroHospitalario),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Campo dinámico según tipo
        _buildDynamicField(context),
      ],
    );
  }

  Widget _buildDynamicField(BuildContext context) {
    // Domicilio paciente
    if (tipoUbicacion == TipoUbicacion.domicilioPaciente) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pacienteNombreCompleto != null ? 'Domicilio de $pacienteNombreCompleto' : 'Domicilio del paciente',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Otro domicilio
    if (tipoUbicacion == TipoUbicacion.otroDomicilio) {
      return TextFormField(
        initialValue: domicilio,
        decoration: InputDecoration(
          hintText: 'Escribe la dirección',
          prefixIcon: const Icon(Icons.edit_location, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
        style: GoogleFonts.inter(fontSize: 13),
        onChanged: onDomicilioChanged,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa la dirección';
          }
          return null;
        },
      );
    }

    // Centro hospitalario
    if (tipoUbicacion == TipoUbicacion.centroHospitalario) {
      if (loadingCentros) {
        return Container(
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: const Row(
            children: <Widget>[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Cargando...', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }

      return AppSearchableDropdown<CentroHospitalarioEntity>(
        value: centroNombre != null
            ? centrosHospitalarios.firstWhere(
                (CentroHospitalarioEntity c) => c.nombre == centroNombre,
                orElse: () => centrosHospitalarios.first,
              )
            : null,
        items: centrosDropdownItems,
        onChanged: (CentroHospitalarioEntity? centro) {
          onCentroChanged(centro?.nombre);
        },
        hint: centrosHospitalarios.isEmpty ? 'Sin centros' : 'Buscar centro...',
        prefixIcon: Icons.local_hospital,
        enabled: centrosHospitalarios.isNotEmpty,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Botón compacto de opción de ubicación
class _UbicacionOptionButton extends StatelessWidget {
  const _UbicacionOptionButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.gray400,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// Campo de hora del trayecto
class _HoraField extends StatefulWidget {
  const _HoraField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final void Function(TimeOfDay?) onChanged;

  @override
  State<_HoraField> createState() => _HoraFieldState();
}

class _HoraFieldState extends State<_HoraField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hora *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'HHMM',
            prefixIcon: const Icon(Icons.access_time, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (String value) {
            final String cleaned = value.replaceAll(RegExp('[^0-9:]'), '');

            if (cleaned.contains(':') && cleaned.length >= 5) {
              if (cleaned.length > 5) {
                widget.controller.text = cleaned.substring(0, 5);
                widget.controller.selection = TextSelection.fromPosition(
                  const TextPosition(offset: 5),
                );
              }
              return;
            }

            if (!cleaned.contains(':') && cleaned.length > 4) {
              widget.controller.text = cleaned.substring(0, 4);
              widget.controller.selection = TextSelection.fromPosition(
                const TextPosition(offset: 4),
              );
              return;
            }

            if (cleaned.length == 4 && !cleaned.contains(':')) {
              final String horas = cleaned.substring(0, 2);
              final String minutos = cleaned.substring(2, 4);
              final int h = int.tryParse(horas) ?? 0;
              final int m = int.tryParse(minutos) ?? 0;

              if (h >= 0 && h < 24 && m >= 0 && m < 60) {
                widget.onChanged(TimeOfDay(hour: h, minute: m));
                widget.controller.text = '$horas:$minutos';
                widget.controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.controller.text.length),
                );
                setState(() {});
              }
            }
          },
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa hora';
            }

            if (value.contains(':')) {
              final List<String> parts = value.split(':');
              if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
                return 'Formato: HHMM';
              }
              final int? h = int.tryParse(parts[0]);
              final int? m = int.tryParse(parts[1]);
              if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
                return 'Hora inválida';
              }
              return null;
            }

            if (value.length != 4) {
              return 'Formato: HHMM';
            }

            final int? h = int.tryParse(value.substring(0, 2));
            final int? m = int.tryParse(value.substring(2, 4));
            if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
              return 'Hora inválida';
            }

            return null;
          },
        ),
      ],
    );
  }
}
