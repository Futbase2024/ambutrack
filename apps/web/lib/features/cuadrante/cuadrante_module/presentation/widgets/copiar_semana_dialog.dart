import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Resultado del diálogo de copiar semana
class CopiarSemanaResult {
  const CopiarSemanaResult({
    required this.semanaDestino,
    this.idPersonal,
  });

  final String semanaDestino;
  final List<String>? idPersonal; // null = todos, lista = varios seleccionados
}

/// Diálogo para copiar turnos de la semana actual a otra semana
class CopiarSemanaDialog extends StatefulWidget {
  const CopiarSemanaDialog({
    required this.semanaActual,
    required this.personalConTurnos,
    super.key,
  });

  /// Fecha de inicio de la semana actual
  final DateTime semanaActual;

  /// Lista de personal disponible
  final List<PersonalConTurnosEntity> personalConTurnos;

  @override
  State<CopiarSemanaDialog> createState() => _CopiarSemanaDialogState();
}

enum _ModoSeleccion { todos, uno, varios }

class _CopiarSemanaDialogState extends State<CopiarSemanaDialog> {
  String? _semanaDestinoSeleccionada;
  _ModoSeleccion _modoSeleccion = _ModoSeleccion.todos;
  String? _personalSeleccionado; // Para modo "uno"
  final Set<String> _personalSeleccionadoVarios = <String>{}; // Para modo "varios"
  final List<_SemanaOption> _semanasDisponibles = <_SemanaOption>[];

  @override
  void initState() {
    super.initState();
    _generarSemanasDisponibles();
  }

  /// Genera lista de las próximas 8 semanas disponibles
  void _generarSemanasDisponibles() {
    final DateFormat formatter = DateFormat('d MMM', 'es_ES');

    for (int i = 1; i <= 8; i++) {
      final DateTime inicioSemana = widget.semanaActual.add(Duration(days: 7 * i));
      final DateTime finSemana = inicioSemana.add(const Duration(days: 6));

      final String label = '${formatter.format(inicioSemana)} - ${formatter.format(finSemana)}';
      final String value = inicioSemana.toIso8601String();

      _semanasDisponibles.add(_SemanaOption(label: label, value: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Copiar Semana de Turnos',
      icon: Icons.content_copy,
      type: AppDialogType.create,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Semana actual (info)
            _buildInfoRow(
              'Semana de origen:',
              _getSemanaActualTexto(),
              Icons.calendar_today,
            ),

            const SizedBox(height: AppSizes.spacingLarge),

            // Selector de modo
            Text(
              '¿Qué trabajadores deseas copiar?',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildModoChip(
                    label: 'Todos',
                    icon: Icons.groups,
                    modo: _ModoSeleccion.todos,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: _buildModoChip(
                    label: 'Uno',
                    icon: Icons.person,
                    modo: _ModoSeleccion.uno,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: _buildModoChip(
                    label: 'Varios',
                    icon: Icons.people,
                    modo: _ModoSeleccion.varios,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacing),

            // Selector de personal (solo si modo == uno)
            if (_modoSeleccion == _ModoSeleccion.uno) ...<Widget>[
              AppDropdown<String>(
                value: _personalSeleccionado,
                hint: 'Selecciona un trabajador',
                prefixIcon: Icons.person_outline,
                items: widget.personalConTurnos.map((PersonalConTurnosEntity p) {
                  return AppDropdownItem<String>(
                    value: p.personal.id,
                    label: p.personal.nombreCompleto,
                    icon: Icons.person_outline,
                    iconColor: AppColors.secondaryLight,
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _personalSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: AppSizes.spacing),
            ],

            // Lista de checkboxes (solo si modo == varios)
            if (_modoSeleccion == _ModoSeleccion.varios) ...<Widget>[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: widget.personalConTurnos.map((PersonalConTurnosEntity p) {
                    return CheckboxListTile(
                      title: Text(
                        p.personal.nombreCompleto,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      value: _personalSeleccionadoVarios.contains(p.personal.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _personalSeleccionadoVarios.add(p.personal.id);
                          } else {
                            _personalSeleccionadoVarios.remove(p.personal.id);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),

              // Mostrar lista de seleccionados
              if (_personalSeleccionadoVarios.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Text(
                            'Seleccionados (${_personalSeleccionadoVarios.length}):',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingSmall),
                      Wrap(
                        spacing: AppSizes.spacingSmall,
                        runSpacing: AppSizes.spacingSmall,
                        children: _getPersonalSeleccionadosNombres().map((String nombre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingSmall,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  nombre,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSizes.spacing),
            ],

            const SizedBox(height: AppSizes.spacing),

            // Selector de semana destino
            Text(
              'Semana de destino',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            AppDropdown<String>(
              value: _semanaDestinoSeleccionada,
              hint: 'Selecciona la semana destino',
              prefixIcon: Icons.event_available,
              items: _semanasDisponibles.map((_SemanaOption opt) {
                return AppDropdownItem<String>(
                  value: opt.value,
                  label: opt.label,
                  icon: Icons.calendar_month,
                  iconColor: AppColors.primary,
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _semanaDestinoSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: AppSizes.spacingLarge),

            // Advertencia
            if (_semanaDestinoSeleccionada != null)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Text(
                        'Los turnos existentes en la semana destino no se eliminarán.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _puedeConfirmar() ? _confirmar : null,
          label: 'Copiar Semana',
          icon: Icons.content_copy,
        ),
      ],
    );
  }

  Widget _buildModoChip({
    required String label,
    required IconData icon,
    required _ModoSeleccion modo,
  }) {
    final bool isSelected = _modoSeleccion == modo;

    return InkWell(
      onTap: () {
        setState(() {
          _modoSeleccion = modo;
          // Limpiar selecciones al cambiar de modo
          _personalSeleccionado = null;
          _personalSeleccionadoVarios.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene la lista de nombres del personal seleccionado
  List<String> _getPersonalSeleccionadosNombres() {
    return widget.personalConTurnos
        .where((PersonalConTurnosEntity p) => _personalSeleccionadoVarios.contains(p.personal.id))
        .map((PersonalConTurnosEntity p) => p.personal.nombreCompleto)
        .toList();
  }

  bool _puedeConfirmar() {
    if (_semanaDestinoSeleccionada == null) {
      return false;
    }

    switch (_modoSeleccion) {
      case _ModoSeleccion.todos:
        return true;
      case _ModoSeleccion.uno:
        return _personalSeleccionado != null;
      case _ModoSeleccion.varios:
        return _personalSeleccionadoVarios.isNotEmpty;
    }
  }

  void _confirmar() {
    List<String>? idPersonal;

    switch (_modoSeleccion) {
      case _ModoSeleccion.todos:
        idPersonal = null; // null = todos
      case _ModoSeleccion.uno:
        idPersonal = _personalSeleccionado != null ? <String>[_personalSeleccionado!] : null;
      case _ModoSeleccion.varios:
        idPersonal = _personalSeleccionadoVarios.toList();
    }

    Navigator.of(context).pop(
      CopiarSemanaResult(
        semanaDestino: _semanaDestinoSeleccionada!,
        idPersonal: idPersonal,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondaryLight),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  String _getSemanaActualTexto() {
    final DateFormat formatter = DateFormat('d MMM', 'es_ES');
    final DateTime fin = widget.semanaActual.add(const Duration(days: 6));
    return '${formatter.format(widget.semanaActual)} - ${formatter.format(fin)}';
  }
}

/// Clase helper para las opciones de semana
class _SemanaOption {
  _SemanaOption({required this.label, required this.value});

  final String label;
  final String value;
}
