import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar turnos
class TurnoFormDialog extends StatefulWidget {
  const TurnoFormDialog({
    super.key,
    this.turno,
    this.personal,
    this.fechaInicio,
  });

  final TurnoEntity? turno;
  final PersonalEntity? personal;
  final DateTime? fechaInicio;

  @override
  State<TurnoFormDialog> createState() => _TurnoFormDialogState();
}

class _TurnoFormDialogState extends State<TurnoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nombrePersonalController;
  late TextEditingController _observacionesController;
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFinController;

  late FocusNode _horaInicioFocusNode;
  late FocusNode _horaFinFocusNode;

  // State
  String _idPersonal = '';
  TipoTurno _tipoTurno = TipoTurno.manana;
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  bool _activo = true;
  bool _isCustomTime = false;
  bool _isSaving = false;

  // Plantilla seleccionada
  String? _idPlantillaSeleccionada;

  // Vehículo seleccionado
  String? _idVehiculo;
  List<VehiculoEntity> _vehiculosDisponibles = <VehiculoEntity>[];
  bool _isLoadingVehiculos = false;

  // Contrato seleccionado
  String? _idContrato;
  List<ContratoEntity> _contratosDisponibles = <ContratoEntity>[];
  bool _isLoadingContratos = false;

  // Base seleccionada (opcional)
  String? _idBase;
  List<BaseCentroEntity> _basesDisponibles = <BaseCentroEntity>[];
  bool _isLoadingBases = false;

  // Categoría/Función del personal
  String? _categoriaPersonal;

  // Dotación seleccionada
  String? _idDotacion;
  List<DotacionEntity> _dotacionesDisponibles = <DotacionEntity>[];
  bool _isLoadingDotaciones = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controllers
    _nombrePersonalController = TextEditingController(
      text: widget.turno?.nombrePersonal ?? widget.personal?.nombreCompleto ?? '',
    );
    _observacionesController = TextEditingController(
      text: widget.turno?.observaciones ?? '',
    );
    _horaInicioController = TextEditingController(
      text: _formatTimeInput(widget.turno?.horaInicio ?? TipoTurno.manana.horaInicio),
    );
    _horaFinController = TextEditingController(
      text: _formatTimeInput(widget.turno?.horaFin ?? TipoTurno.manana.horaFin),
    );

    // Inicializar FocusNodes
    _horaInicioFocusNode = FocusNode();
    _horaFinFocusNode = FocusNode();

    // Agregar listeners para detectar cuando los campos pierden el foco
    _horaInicioFocusNode.addListener(_onHoraFocusChanged);
    _horaFinFocusNode.addListener(_onHoraFocusChanged);

    // Inicializar estado desde turno existente
    if (widget.turno != null) {
      _idPersonal = widget.turno!.idPersonal;
      _tipoTurno = widget.turno!.tipoTurno;
      _fechaInicio = widget.turno!.fechaInicio;
      _fechaFin = widget.turno!.fechaFin;
      _activo = widget.turno!.activo;
      _isCustomTime = _tipoTurno == TipoTurno.personalizado;
      _idVehiculo = widget.turno!.idVehiculo;
      _idContrato = widget.turno!.idContrato;
      _idBase = widget.turno!.idBase;
      _categoriaPersonal = widget.turno!.categoriaPersonal;
      _idDotacion = widget.turno!.idDotacion;
    } else {
      // Si se pasa personal, usar su ID
      if (widget.personal != null) {
        _idPersonal = widget.personal!.id;
      }

      // Si se pasa fecha de inicio, usarla
      if (widget.fechaInicio != null) {
        // Establecer fechaInicio con la hora de inicio del turno seleccionado
        final List<String> partesHoraInicio = _tipoTurno.horaInicio.split(':');
        final int horaInicioInt = int.parse(partesHoraInicio[0]);
        final int minutoInicioInt = int.parse(partesHoraInicio[1]);

        _fechaInicio = DateTime(
          widget.fechaInicio!.year,
          widget.fechaInicio!.month,
          widget.fechaInicio!.day,
          horaInicioInt,
          minutoInicioInt,
        );

        // Calcular fechaFin basándose en horaFin
        final List<String> partesHoraFin = _tipoTurno.horaFin.split(':');
        final int horaFinInt = int.parse(partesHoraFin[0]);
        final int minutoFinInt = int.parse(partesHoraFin[1]);

        // Verificar si cruza medianoche
        if (_cruzaMedianoche(_tipoTurno.horaInicio, _tipoTurno.horaFin)) {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
        } else {
          _fechaFin = DateTime(
            _fechaInicio.year,
            _fechaInicio.month,
            _fechaInicio.day,
            horaFinInt,
            minutoFinInt,
          );
        }
      }
    }

    // Cargar datos disponibles
    _loadContratos();
    _loadBases();
    _loadVehiculos();
    _loadDotaciones();
  }

  /// Listener para detectar cuando un campo de hora pierde el foco
  void _onHoraFocusChanged() {
    // Solo procesar cuando el campo pierde el foco
    if (_horaInicioFocusNode.hasFocus || _horaFinFocusNode.hasFocus) {
      return;
    }

    // Autoformatear las horas cuando pierden el foco
    final String horaInicioFormatted = _formatTimeInput(_horaInicioController.text);
    final String horaFinFormatted = _formatTimeInput(_horaFinController.text);

    if (horaInicioFormatted != _horaInicioController.text) {
      _horaInicioController.value = TextEditingValue(
        text: horaInicioFormatted,
        selection: TextSelection.collapsed(offset: horaInicioFormatted.length),
      );
    }

    if (horaFinFormatted != _horaFinController.text) {
      _horaFinController.value = TextEditingValue(
        text: horaFinFormatted,
        selection: TextSelection.collapsed(offset: horaFinFormatted.length),
      );
    }

    // Procesar ambos campos si tienen valores válidos
    final String horaInicio = _horaInicioController.text;
    final String horaFin = _horaFinController.text;

    // Validar formato básico HH:mm antes de procesar
    final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(horaInicio) || !regex.hasMatch(horaFin)) {
      return;
    }

    // Detectar si cruza medianoche
    if (_cruzaMedianoche(horaInicio, horaFin)) {
      if (_fechaFin == _fechaInicio || _fechaFin.isBefore(_fechaInicio.add(const Duration(days: 1)))) {
        setState(() {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
          debugPrint('🌙 Turno cruza medianoche: $horaInicio-$horaFin | Ajustando fechaFin');
        });
      }
    } else {
      if (_fechaFin != _fechaInicio) {
        setState(() {
          _fechaFin = _fechaInicio;
          debugPrint('☀️ Turno mismo día: $horaInicio-$horaFin');
        });
      }
    }
  }

  @override
  void dispose() {
    // Remover listeners
    _horaInicioFocusNode.removeListener(_onHoraFocusChanged);
    _horaFinFocusNode.removeListener(_onHoraFocusChanged);

    // Disponer FocusNodes
    _horaInicioFocusNode.dispose();
    _horaFinFocusNode.dispose();

    // Disponer controllers
    _nombrePersonalController.dispose();
    _observacionesController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.turno != null;

    return BlocListener<TurnosBloc, TurnosState>(
      listener: (BuildContext context, TurnosState state) async {
        // ✅ Patrón ResultDialog con cierre de formulario
        if (state is TurnoCreated || state is TurnoUpdated) {
          debugPrint('✅ TurnoFormDialog: Operación exitosa');

          if (!mounted) {
            return;
          }

          // 1. Cerrar loading overlay
          Navigator.of(context).pop();
          await Future<void>.delayed(Duration.zero);

          // 2. Resetear estado
          if (mounted) {
            setState(() => _isSaving = false);
          }

          // 3. Cerrar el formulario
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          await Future<void>.delayed(Duration.zero);

          // 4. Mostrar ResultDialog de éxito (desde contexto padre)
          if (context.mounted) {
            await showResultDialog(
              context: context,
              title: isEditing ? 'Turno Actualizado' : 'Turno Creado',
              message: isEditing
                  ? 'El turno se ha actualizado exitosamente.'
                  : 'El nuevo turno se ha creado exitosamente.',
              type: ResultType.success,
            );
          }
        } else if (state is TurnosError) {
          if (!mounted) {
            return;
          }

          // 1. Cerrar loading overlay
          Navigator.of(context).pop();
          await Future<void>.delayed(Duration.zero);

          // 2. Resetear estado
          if (mounted) {
            setState(() => _isSaving = false);
          }

          // 3. Mostrar ResultDialog de error (NO cerrar formulario para permitir corrección)
          if (context.mounted) {
            await showResultDialog(
              context: context,
              title: 'Error al Guardar',
              message: isEditing
                  ? 'No se pudo actualizar el turno.'
                  : 'No se pudo crear el turno.',
              type: ResultType.error,
              details: state.message,
            );
          }
        }
      },
      child: AppDialog(
      title: isEditing ? 'Editar Turno' : 'Nuevo Turno',
      icon: isEditing ? Icons.edit : Icons.schedule,
      maxWidth: 900,
      type: isEditing ? AppDialogType.edit : AppDialogType.create,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Personal (readonly)
            _buildPersonalField(),
            const SizedBox(height: AppSizes.spacing),
            // 2. Contrato + Base (en la misma fila)
            _buildContratoBaseRow(),
            const SizedBox(height: AppSizes.spacing),
            // 2.5. Dotación (ocupa todo el ancho)
            _buildDotacionSelector(),
            const SizedBox(height: AppSizes.spacing),
            // 3. Función + Vehículo (en la misma fila)
            _buildCategoriaVehiculoRow(),
            const SizedBox(height: AppSizes.spacing),
            // 4. Tipo de Turno + Plantilla (en la misma fila)
            _buildTipoTurnoPlantillaRow(),
            const SizedBox(height: AppSizes.spacing),
            // 7. Fechas
            _buildFechaFields(),
            const SizedBox(height: AppSizes.spacing),
            // 6. Horario
            _buildHoraFields(),
            const SizedBox(height: AppSizes.spacing),
            // 7. Observaciones
            _buildObservacionesField(),
            const SizedBox(height: AppSizes.spacing),
            // 11. Activo
            _buildActivoSwitch(),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _isSaving ? null : _handleSave,
          label: _isSaving
              ? 'Guardando...'
              : (isEditing ? 'Actualizar' : 'Crear Turno'),
          variant: isEditing ? AppButtonVariant.secondary : AppButtonVariant.primary,
        ),
      ],
      ),
    );
  }

  Widget _buildPersonalField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Personal',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall + 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  _nombrePersonalController.text.isEmpty
                      ? 'No asignado'
                      : _nombrePersonalController.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _nombrePersonalController.text.isEmpty
                        ? AppColors.textSecondaryLight
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Selector de tipo de turno con badges (Mañana, Tarde, Noche, Personalizado)
  Widget _buildTipoTurnoSelector() {
    // Deshabilitar badges si hay una plantilla seleccionada
    final bool badgesEnabled = _idPlantillaSeleccionada == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de Turno *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: TipoTurno.values.map((TipoTurno tipo) {
            final bool isSelected = _tipoTurno == tipo;
            final Color backgroundColor = badgesEnabled
                ? (isSelected ? _getTipoColor(tipo) : Colors.transparent)
                : AppColors.gray200;
            final Color textColor = badgesEnabled
                ? (isSelected ? Colors.white : _getTipoColor(tipo))
                : AppColors.gray400;
            final Color borderColor = badgesEnabled
                ? _getTipoColor(tipo)
                : AppColors.gray300;

            return InkWell(
              onTap: badgesEnabled
                  ? () {
                      setState(() {
                        _tipoTurno = tipo;
                        _isCustomTime = tipo == TipoTurno.personalizado;

                        // Si no es personalizado, aplicar horas del tipo
                        if (!_isCustomTime) {
                          _horaInicioController.text = tipo.horaInicio;
                          _horaFinController.text = tipo.horaFin;

                          // Detectar si cruza medianoche
                          if (_cruzaMedianoche(tipo.horaInicio, tipo.horaFin)) {
                            _fechaFin = _fechaInicio.add(const Duration(days: 1));
                            debugPrint('🌙 Tipo de turno ${tipo.nombre} cruza medianoche | Ajustando fechaFin');
                          } else {
                            _fechaFin = _fechaInicio;
                          }
                        }

                        // Limpiar plantilla seleccionada
                        _idPlantillaSeleccionada = null;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  tipo.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!badgesEnabled)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
            child: Text(
              'Plantilla seleccionada. Los tipos de turno están deshabilitados.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Selector de plantilla de turno
  Widget _buildPlantillaSelector() {
    const List<Map<String, dynamic>> plantillasPredefinidas = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '12h_dia',
        'nombre': '☀️ 12h Día',
        'horaInicio': '08:00',
        'horaFin': '20:00',
        'color': AppColors.turnoTurquesa,
      },
      <String, dynamic>{
        'id': '12h_noche',
        'nombre': '🌙 12h Noche',
        'horaInicio': '20:00',
        'horaFin': '08:00',
        'color': AppColors.turnoAzul,
      },
      <String, dynamic>{
        'id': '24h',
        'nombre': '🚨 24 Horas',
        'horaInicio': '08:00',
        'horaFin': '08:00',
        'color': AppColors.turnoMorado,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Plantilla Rápida (Opcional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppDropdown<String?>(
          value: _idPlantillaSeleccionada,
          hint: 'Selecciona una plantilla (opcional)',
          prefixIcon: Icons.auto_awesome,
          items: <AppDropdownItem<String?>>[
            const AppDropdownItem<String?>(
              value: null,
              label: 'Sin plantilla',
            ),
            ...plantillasPredefinidas.map((Map<String, dynamic> plantilla) {
              return AppDropdownItem<String?>(
                value: plantilla['id'] as String,
                label: plantilla['nombre'] as String,
                icon: Icons.circle,
                iconColor: plantilla['color'] as Color,
              );
            }),
          ],
          onChanged: (String? id) {
            if (id == null) {
              // Si se limpia la plantilla, habilitar de nuevo los badges
              setState(() {
                _idPlantillaSeleccionada = null;
              });
              return;
            }

            final Map<String, dynamic>? plantilla = plantillasPredefinidas
                .cast<Map<String, dynamic>?>()
                .firstWhere(
                  (Map<String, dynamic>? p) => p?['id'] == id,
                  orElse: () => null,
                );

            if (plantilla != null) {
              setState(() {
                _idPlantillaSeleccionada = id;
                _horaInicioController.text = plantilla['horaInicio'] as String;
                _horaFinController.text = plantilla['horaFin'] as String;

                // Detectar si cruza medianoche
                if (_cruzaMedianoche(
                  plantilla['horaInicio'] as String,
                  plantilla['horaFin'] as String,
                )) {
                  _fechaFin = _fechaInicio.add(const Duration(days: 1));
                  debugPrint('🌙 Turno cruza medianoche: ${plantilla['nombre']} | Ajustando fechaFin');
                } else {
                  _fechaFin = _fechaInicio;
                }

                // Ajustar tipoTurno según la plantilla
                if (id == '12h_noche' || id == '24h') {
                  _tipoTurno = TipoTurno.noche;
                } else {
                  _tipoTurno = TipoTurno.personalizado;
                }

                // Habilitar edición de horas cuando se selecciona plantilla
                _isCustomTime = true;

                debugPrint('✅ Plantilla aplicada: ${plantilla['nombre']} | Badges deshabilitados');
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFechaFields() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(
            label: 'Fecha Inicio *',
            value: _fechaInicio,
            onTap: () => _selectDate(context, isInicio: true),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _buildDateField(
            label: 'Fecha Fin *',
            value: _fechaFin,
            onTap: () => _selectDate(context, isInicio: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall + 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondaryLight),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  '${value.day}/${value.month}/${value.year}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoraFields() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildTimeField(
            label: 'Hora Inicio *',
            controller: _horaInicioController,
            enabled: _isCustomTime,
            focusNode: _horaInicioFocusNode,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _buildTimeField(
            label: 'Hora Fin *',
            controller: _horaFinController,
            enabled: _isCustomTime,
            focusNode: _horaFinFocusNode,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    FocusNode? focusNode,
  }) {
    // SIEMPRE habilitar edición de horas
    const bool isEditable = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: controller,
          enabled: isEditable,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'HH:mm',
            prefixIcon: const Icon(Icons.access_time, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            filled: false,
          ),
          onEditingComplete: () {
            // Auto-formatear cuando el usuario termina de editar (pierde foco o presiona Enter)
            final String formatted = _formatTimeInput(controller.text);
            if (formatted != controller.text) {
              controller.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }

            // Detectar si el turno cruza medianoche cuando se editan las horas manualmente
            if (_horaInicioController.text.isNotEmpty && _horaFinController.text.isNotEmpty) {
              if (_cruzaMedianoche(_horaInicioController.text, _horaFinController.text)) {
                setState(() {
                  _fechaFin = _fechaInicio.add(const Duration(days: 1));
                  debugPrint('🌙 Turno cruza medianoche: ${_horaInicioController.text}-${_horaFinController.text} | Ajustando fechaFin');
                });
              } else if (_fechaFin != _fechaInicio) {
                setState(() {
                  _fechaFin = _fechaInicio;
                  debugPrint('☀️ Turno mismo día: ${_horaInicioController.text}-${_horaFinController.text}');
                });
              }
            }
          },
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'La hora es requerida';
            }
            // Validar formato HH:mm
            final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
            if (!regex.hasMatch(value)) {
              return 'Formato inválido (HH:mm)';
            }

            // Validar que la hora sea válida (00-23)
            final List<String> parts = value.split(':');
            final int? hora = int.tryParse(parts[0]);
            final int? minuto = int.tryParse(parts[1]);

            if (hora == null || hora < 0 || hora > 23) {
              return 'Hora inválida (00-23)';
            }
            if (minuto == null || minuto < 0 || minuto > 59) {
              return 'Minutos inválidos (00-59)';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildObservacionesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Observaciones',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _observacionesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Notas adicionales sobre el turno...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildActivoSwitch() {
    return Row(
      children: <Widget>[
        Switch(
          value: _activo,
          onChanged: (bool value) {
            setState(() => _activo = value);
          },
          activeThumbColor: AppColors.success,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          'Turno activo',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isInicio}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
          // Si la fecha fin es anterior a la nueva fecha inicio, ajustarla
          if (_fechaFin.isBefore(_fechaInicio)) {
            _fechaFin = _fechaInicio;
          }
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mostrar loading overlay
    setState(() => _isSaving = true);
    final bool isEditing = widget.turno != null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: isEditing ? 'Actualizando turno...' : 'Creando turno...',
          color: isEditing ? AppColors.secondaryLight : AppColors.primary,
          icon: isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    // Verificar si cruza medianoche antes de guardar
    final String horaInicio = _horaInicioController.text.trim();
    final String horaFin = _horaFinController.text.trim();
    final bool cruzaMedianoche = _cruzaMedianoche(horaInicio, horaFin);

    // Calcular fechaInicio y fechaFin correctamente con las horas
    final List<String> partesHoraInicio = horaInicio.split(':');
    final int horaInicioInt = int.parse(partesHoraInicio[0]);
    final int minutoInicioInt = int.parse(partesHoraInicio[1]);

    // IMPORTANTE: Crear DateTime en hora LOCAL y convertir a UTC
    // Esto asegura que la fecha guardada en Supabase refleje la hora local española
    final DateTime fechaInicioLocal = DateTime(
      _fechaInicio.year,
      _fechaInicio.month,
      _fechaInicio.day,
      horaInicioInt,
      minutoInicioInt,
    );
    final DateTime fechaInicioFinal = fechaInicioLocal.toUtc();

    DateTime fechaFinFinal;
    if (cruzaMedianoche) {
      // Si cruza medianoche, fechaFin es el día siguiente con la hora de fin
      final List<String> partesHoraFin = horaFin.split(':');
      final int horaFinInt = int.parse(partesHoraFin[0]);
      final int minutoFinInt = int.parse(partesHoraFin[1]);

      final DateTime fechaFinLocal = DateTime(
        _fechaInicio.year,
        _fechaInicio.month,
        _fechaInicio.day + 1,
        horaFinInt,
        minutoFinInt,
      );
      fechaFinFinal = fechaFinLocal.toUtc();
      debugPrint('🌙 Turno cruza medianoche:');
      debugPrint('   Local: ${fechaInicioLocal.toIso8601String()} → ${fechaFinLocal.toIso8601String()}');
      debugPrint('   UTC:   ${fechaInicioFinal.toIso8601String()} → ${fechaFinFinal.toIso8601String()}');
    } else {
      // Si NO cruza medianoche, fechaFin es el mismo día con la hora de fin
      final List<String> partesHoraFin = horaFin.split(':');
      final int horaFinInt = int.parse(partesHoraFin[0]);
      final int minutoFinInt = int.parse(partesHoraFin[1]);

      final DateTime fechaFinLocal = DateTime(
        _fechaInicio.year,
        _fechaInicio.month,
        _fechaInicio.day,
        horaFinInt,
        minutoFinInt,
      );
      fechaFinFinal = fechaFinLocal.toUtc();
      debugPrint('☀️ Turno mismo día:');
      debugPrint('   Local: ${fechaInicioLocal.toIso8601String()} → ${fechaFinLocal.toIso8601String()}');
      debugPrint('   UTC:   ${fechaInicioFinal.toIso8601String()} → ${fechaFinFinal.toIso8601String()}');
    }

    final TurnoEntity turno = TurnoEntity(
      id: widget.turno?.id ?? const Uuid().v4(),
      idPersonal: _idPersonal,
      nombrePersonal: _nombrePersonalController.text.trim(),
      tipoTurno: _tipoTurno,
      fechaInicio: fechaInicioFinal,
      fechaFin: fechaFinFinal,
      horaInicio: horaInicio,
      horaFin: horaFin,
      idContrato: _idContrato,
      idBase: _idBase,
      categoriaPersonal: _categoriaPersonal,
      idVehiculo: _idVehiculo,
      idDotacion: _idDotacion,
      observaciones: _observacionesController.text.trim().isNotEmpty
          ? _observacionesController.text.trim()
          : null,
      activo: _activo,
    );

    debugPrint('💾 Guardando turno:');
    debugPrint('  - Tipo: ${turno.tipoTurno.nombre}');
    debugPrint('  - Horario: ${turno.horaInicio} - ${turno.horaFin}');
    debugPrint('  - Fecha Inicio: ${turno.fechaInicio}');
    debugPrint('  - Fecha Fin: ${turno.fechaFin}');
    debugPrint('  - Cruza medianoche: $cruzaMedianoche');

    // Disparar evento al BLoC
    if (widget.turno == null) {
      debugPrint('🚀 TurnoFormDialog: Creando turno...');
      context.read<TurnosBloc>().add(TurnoCreateRequested(turno));
    } else {
      debugPrint('🚀 TurnoFormDialog: Actualizando turno...');
      context.read<TurnosBloc>().add(TurnoUpdateRequested(turno));
    }

    // NO cerrar el diálogo - el BlocListener lo hará cuando reciba la respuesta
  }

  /// Formatea automáticamente la entrada de hora
  /// Ejemplos:
  /// - "8" -> "08:00"
  /// - "14" -> "14:00"
  /// - "830" -> "08:30"
  /// - "1430" -> "14:30"
  String _formatTimeInput(String input) {
    // Si ya tiene el formato HH:mm:ss (con segundos), remover los segundos
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(input)) {
      return input.substring(0, 5); // "08:00:00" -> "08:00"
    }

    // Si ya tiene el formato correcto HH:mm, devolver sin cambios
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(input)) {
      return input;
    }

    // Remover todo excepto números
    final String numeros = input.replaceAll(RegExp('[^0-9]'), '');

    // Si está vacío, devolver vacío
    if (numeros.isEmpty) {
      return '';
    }

    // Formatear según la cantidad de dígitos
    if (numeros.length == 1) {
      // "8" -> "08:00"
      return '0$numeros:00';
    } else if (numeros.length == 2) {
      // "14" -> "14:00"
      final int hora = int.tryParse(numeros) ?? 0;
      if (hora <= 23) {
        return '$numeros:00';
      }
      // Si es mayor a 23, tomar primer dígito como hora
      return '0${numeros[0]}:${numeros[1]}0';
    } else if (numeros.length == 3) {
      // "830" -> "08:30"
      return '0${numeros[0]}:${numeros.substring(1)}';
    } else if (numeros.length >= 4) {
      // "1430" -> "14:30"
      return '${numeros.substring(0, 2)}:${numeros.substring(2, 4)}';
    }

    return input;
  }

  /// Obtiene el color según el tipo de turno
  Color _getTipoColor(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return AppColors.success; // 🟢 Verde
      case TipoTurno.tarde:
        return AppColors.turnoNaranja; // 🟠 Naranja
      case TipoTurno.noche:
        return AppColors.turnoAzul; // 🔵 Azul
      case TipoTurno.personalizado:
        return AppColors.turnoGris; // ⚪ Gris
    }
  }

  /// Detecta si un turno cruza medianoche comparando las horas
  /// Retorna true si horaFin < horaInicio o si son iguales (turno 24h)
  bool _cruzaMedianoche(String horaInicio, String horaFin) {
    // Si alguna está vacía, asumir que no cruza
    if (horaInicio.isEmpty || horaFin.isEmpty) {
      return false;
    }

    // Parsear horas a minutos desde medianoche para comparación
    final List<String> partesInicio = horaInicio.split(':');
    final List<String> partesFin = horaFin.split(':');

    if (partesInicio.length != 2 || partesFin.length != 2) {
      return false;
    }

    final int minutosInicio = (int.tryParse(partesInicio[0]) ?? 0) * 60 + (int.tryParse(partesInicio[1]) ?? 0);
    final int minutosFin = (int.tryParse(partesFin[0]) ?? 0) * 60 + (int.tryParse(partesFin[1]) ?? 0);

    // Si fin <= inicio, cruza medianoche
    // Incluye el caso de turno 24h (inicio == fin)
    return minutosFin <= minutosInicio;
  }

  /// Carga los vehículos disponibles desde el repositorio
  Future<void> _loadVehiculos() async {
    setState(() {
      _isLoadingVehiculos = true;
    });

    try {
      final VehiculoRepository repository = getIt<VehiculoRepository>();
      final List<VehiculoEntity> vehiculos = await repository.getAll();

      // Filtrar solo vehículos activos y ordenar alfabéticamente por matrícula
      final List<VehiculoEntity> vehiculosOperativos = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList()
        ..sort((VehiculoEntity a, VehiculoEntity b) =>
            a.matricula.toLowerCase().compareTo(b.matricula.toLowerCase()));

      // Si estamos editando y el vehículo asignado no está en la lista, agregarlo
      if (_idVehiculo != null && _idVehiculo!.isNotEmpty) {
        final bool vehiculoEnLista = vehiculosOperativos.any((VehiculoEntity v) => v.id == _idVehiculo);
        if (!vehiculoEnLista) {
          try {
            final VehiculoEntity vehiculoAsignado = vehiculos.firstWhere(
              (VehiculoEntity v) => v.id == _idVehiculo,
            );
            vehiculosOperativos.insert(0, vehiculoAsignado);
            debugPrint('⚠️ Vehículo asignado no está activo, incluido en lista: ${vehiculoAsignado.matricula}');
          } catch (e) {
            debugPrint('⚠️ Vehículo asignado no encontrado en repositorio, limpiando: $_idVehiculo');
            if (mounted) {
              setState(() => _idVehiculo = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _vehiculosDisponibles = vehiculosOperativos;
          _isLoadingVehiculos = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar vehículos: $e');
      if (mounted) {
        setState(() {
          _isLoadingVehiculos = false;
        });
      }
    }
  }

  /// Carga los contratos disponibles desde el repositorio
  Future<void> _loadContratos() async {
    setState(() {
      _isLoadingContratos = true;
    });

    try {
      final ContratoRepository repository = getIt<ContratoRepository>();
      final List<ContratoEntity> contratos = await repository.getAll();

      // Filtrar solo contratos activos y vigentes y ordenar alfabéticamente
      final List<ContratoEntity> contratosVigentes = contratos.where((ContratoEntity c) =>
        c.activo && c.esVigente
      ).toList()
        ..sort((ContratoEntity a, ContratoEntity b) =>
            a.codigo.toLowerCase().compareTo(b.codigo.toLowerCase()));

      // Si estamos editando y el contrato asignado no está en la lista, agregarlo
      if (_idContrato != null && _idContrato!.isNotEmpty) {
        final bool contratoEnLista = contratosVigentes.any((ContratoEntity c) => c.id == _idContrato);
        if (!contratoEnLista) {
          try {
            final ContratoEntity contratoAsignado = contratos.firstWhere(
              (ContratoEntity c) => c.id == _idContrato,
            );
            contratosVigentes.insert(0, contratoAsignado);
            debugPrint('⚠️ Contrato asignado no está vigente, incluido en lista: ${contratoAsignado.codigo}');
          } catch (e) {
            debugPrint('⚠️ Contrato asignado no encontrado en repositorio, limpiando: $_idContrato');
            if (mounted) {
              setState(() => _idContrato = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _contratosDisponibles = contratosVigentes;
          _isLoadingContratos = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar contratos: $e');
      if (mounted) {
        setState(() {
          _isLoadingContratos = false;
        });
      }
    }
  }

  /// Carga las bases disponibles desde el repositorio
  Future<void> _loadBases() async {
    setState(() {
      _isLoadingBases = true;
    });

    try {
      final BasesRepository repository = getIt<BasesRepository>();
      final List<BaseCentroEntity> bases = await repository.getAll();

      // Filtrar solo bases activas y ordenar alfabéticamente
      final List<BaseCentroEntity> basesActivas = bases.where((BaseCentroEntity b) =>
        b.activo
      ).toList()
        ..sort((BaseCentroEntity a, BaseCentroEntity b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // Si estamos editando y la base asignada no está en la lista, agregarla
      if (_idBase != null && _idBase!.isNotEmpty) {
        final bool baseEnLista = basesActivas.any((BaseCentroEntity b) => b.id == _idBase);
        if (!baseEnLista) {
          try {
            final BaseCentroEntity baseAsignada = bases.firstWhere(
              (BaseCentroEntity b) => b.id == _idBase,
            );
            basesActivas.insert(0, baseAsignada);
            debugPrint('⚠️ Base asignada no está activa, incluida en lista: ${baseAsignada.nombre}');
          } catch (e) {
            debugPrint('⚠️ Base asignada no encontrada en repositorio, limpiando: $_idBase');
            if (mounted) {
              setState(() => _idBase = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _basesDisponibles = basesActivas;
          _isLoadingBases = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar bases: $e');
      if (mounted) {
        setState(() {
          _isLoadingBases = false;
        });
      }
    }
  }

  Future<void> _loadDotaciones() async {
    setState(() {
      _isLoadingDotaciones = true;
    });

    try {
      final DotacionesRepository repository = getIt<DotacionesRepository>();
      final List<DotacionEntity> dotaciones = await repository.getAll();

      // Filtrar solo dotaciones activas y vigentes en la fecha del turno, ordenar alfabéticamente
      final List<DotacionEntity> dotacionesVigentes = dotaciones.where((DotacionEntity d) =>
        d.activo && d.esVigenteEn(_fechaInicio)
      ).toList()
        ..sort((DotacionEntity a, DotacionEntity b) =>
            a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      // Si estamos editando y la dotación asignada no está en la lista, agregarla
      if (_idDotacion != null && _idDotacion!.isNotEmpty) {
        final bool dotacionEnLista = dotacionesVigentes.any((DotacionEntity d) => d.id == _idDotacion);
        if (!dotacionEnLista) {
          try {
            final DotacionEntity dotacionAsignada = dotaciones.firstWhere(
              (DotacionEntity d) => d.id == _idDotacion,
            );
            dotacionesVigentes.insert(0, dotacionAsignada);
            debugPrint('⚠️ Dotación asignada no está vigente, incluida en lista: ${dotacionAsignada.nombre}');
          } catch (e) {
            debugPrint('⚠️ Dotación asignada no encontrada en repositorio, limpiando: $_idDotacion');
            if (mounted) {
              setState(() => _idDotacion = null);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _dotacionesDisponibles = dotacionesVigentes;
          _isLoadingDotaciones = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar dotaciones: $e');
      if (mounted) {
        setState(() {
          _isLoadingDotaciones = false;
        });
      }
    }
  }

  /// Construye el selector de vehículo con búsqueda
  Widget _buildVehiculoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Vehículo (Opcional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (_isLoadingVehiculos)
          const Center(child: CircularProgressIndicator())
        else
          AppSearchableDropdown<String>(
            value: _idVehiculo,
            hint: 'Buscar vehículo...',
            searchHint: 'Buscar por matrícula, modelo...',
            prefixIcon: Icons.local_shipping,
            items: _vehiculosDisponibles.map((VehiculoEntity vehiculo) {
              return AppSearchableDropdownItem<String>(
                value: vehiculo.id,
                label: '${vehiculo.matricula} - ${vehiculo.modelo}',
                icon: Icons.local_shipping,
                iconColor: AppColors.primary,
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _idVehiculo = value;
              });
            },
          ),
      ],
    );
  }

  /// Construye el selector de contrato (requerido)
  Widget _buildContratoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Contrato *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (_isLoadingContratos)
          const Center(child: CircularProgressIndicator())
        else
          AppDropdown<String?>(
            value: _idContrato,
            hint: 'Selecciona un contrato',
            prefixIcon: Icons.description,
            items: <AppDropdownItem<String?>>[
              const AppDropdownItem<String?>(
                value: null,
                label: 'Sin contrato',
              ),
              ..._contratosDisponibles.map((ContratoEntity contrato) {
                return AppDropdownItem<String?>(
                  value: contrato.id,
                  label: '${contrato.codigo} - ${contrato.descripcion ?? contrato.tipoContrato ?? 'Sin descripción'}',
                  icon: Icons.assignment,
                  iconColor: AppColors.secondary,
                );
              }),
            ],
            onChanged: (String? value) {
              setState(() {
                _idContrato = value;
              });
            },
          ),
      ],
    );
  }

  /// Construye la fila con Contrato + Base
  Widget _buildContratoBaseRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Contrato selector (izquierda)
        Expanded(
          child: _buildContratoSelector(),
        ),
        const SizedBox(width: AppSizes.spacing),
        // Base selector (derecha)
        Expanded(
          child: _buildBaseSelector(),
        ),
      ],
    );
  }

  /// Construye la fila con Función + Vehículo
  Widget _buildCategoriaVehiculoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Categoría/Función selector (izquierda)
        Expanded(
          child: _buildCategoriaSelector(),
        ),
        const SizedBox(width: AppSizes.spacing),
        // Vehículo selector (derecha)
        Expanded(
          child: _buildVehiculoSelector(),
        ),
      ],
    );
  }

  /// Construye la fila con Tipo de Turno + Plantilla
  Widget _buildTipoTurnoPlantillaRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Tipo de Turno selector (izquierda)
        Expanded(
          child: _buildTipoTurnoSelector(),
        ),
        const SizedBox(width: AppSizes.spacing),
        // Plantilla selector (derecha)
        Expanded(
          child: _buildPlantillaSelector(),
        ),
      ],
    );
  }

  /// Construye el selector de base (opcional)
  Widget _buildBaseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Base (Opcional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (_isLoadingBases)
          const Center(child: CircularProgressIndicator())
        else
          AppDropdown<String?>(
            value: _idBase,
            hint: 'Selecciona una base',
            prefixIcon: Icons.home_work,
            items: <AppDropdownItem<String?>>[
              const AppDropdownItem<String?>(
                value: null,
                label: 'Sin base',
              ),
              ..._basesDisponibles.map((BaseCentroEntity base) {
                return AppDropdownItem<String?>(
                  value: base.id,
                  label: base.nombre,
                  icon: Icons.location_city,
                  iconColor: AppColors.info,
                );
              }),
            ],
            onChanged: (String? value) {
              setState(() {
                _idBase = value;
              });
            },
          ),
      ],
    );
  }

  /// Construye el selector de dotación (opcional)
  Widget _buildDotacionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Dotación (Opcional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (_isLoadingDotaciones)
          const Center(child: CircularProgressIndicator())
        else
          AppDropdown<String?>(
            value: _idDotacion,
            hint: 'Selecciona una dotación',
            prefixIcon: Icons.assignment,
            items: <AppDropdownItem<String?>>[
              const AppDropdownItem<String?>(
                value: null,
                label: 'Sin dotación',
              ),
              ..._dotacionesDisponibles.map((DotacionEntity dotacion) {
                return AppDropdownItem<String?>(
                  value: dotacion.id,
                  label: dotacion.nombre,
                  icon: Icons.local_shipping,
                  iconColor: AppColors.secondary,
                );
              }),
            ],
            onChanged: (String? value) {
              setState(() {
                _idDotacion = value;
              });
            },
          ),
      ],
    );
  }

  /// Construye el selector de categoría/función (requerido)
  Widget _buildCategoriaSelector() {
    // Opciones de categoría/función predefinidas
    const List<String> categorias = <String>[
      'TES',
      'Conductor',
      'Camillero',
      'Médico',
      'Enfermero',
      'Administrativo',
    ];

    // Validar que la categoría actual esté en la lista
    // Si no lo está, limpiarla (puede ser un valor legacy)
    if (_categoriaPersonal != null && !categorias.contains(_categoriaPersonal)) {
      debugPrint('⚠️ Categoría "$_categoriaPersonal" no es válida, limpiando...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _categoriaPersonal = null);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Función *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppDropdown<String?>(
          value: _categoriaPersonal,
          hint: 'Selecciona la función',
          prefixIcon: Icons.work,
          items: <AppDropdownItem<String?>>[
            const AppDropdownItem<String?>(
              value: null,
              label: 'Sin función',
            ),
            ...categorias.map((String categoria) {
              return AppDropdownItem<String?>(
                value: categoria,
                label: categoria,
                icon: Icons.badge,
                iconColor: AppColors.secondaryLight,
              );
            }),
          ],
          onChanged: (String? value) {
            setState(() {
              _categoriaPersonal = value;
            });
          },
        ),
      ],
    );
  }

}
