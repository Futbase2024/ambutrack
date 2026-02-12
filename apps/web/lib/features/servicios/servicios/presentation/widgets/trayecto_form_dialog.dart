import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Formulario de edición de trayecto
class TrayectoFormDialog extends StatefulWidget {
  const TrayectoFormDialog({
    required this.trayecto,
    required this.onSave,
    super.key,
  });

  final TrasladoEntity trayecto;
  final void Function(TrasladoEntity) onSave;

  @override
  State<TrayectoFormDialog> createState() => _TrayectoFormDialogState();
}

class _TrayectoFormDialogState extends State<TrayectoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TrasladoDataSource _trasladoDataSource = TrasladoDataSourceFactory.createSupabase();
  final CentroHospitalarioDataSource _centroHospitalarioDataSource = CentroHospitalarioDataSourceFactory.createSupabase();

  late TextEditingController _observacionesController;
  late DateTime _fecha;
  late TimeOfDay _horaProgramada;

  // Origen
  String? _tipoOrigen;
  String? _origenValue;
  TextEditingController? _origenDireccionController;
  CentroHospitalarioEntity? _centroOrigenSeleccionado;

  // Destino
  String? _tipoDestino;
  String? _destinoValue;
  TextEditingController? _destinoDireccionController;
  CentroHospitalarioEntity? _centroDestinoSeleccionado;

  // Listas
  List<CentroHospitalarioEntity> _centrosHospitalarios = <CentroHospitalarioEntity>[];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _observacionesController = TextEditingController(text: widget.trayecto.observaciones ?? '');
    _fecha = widget.trayecto.fecha ?? DateTime.now();
    // Parsear horaProgramada desde DateTime a TimeOfDay
    final DateTime? horaProgramadaDateTime = widget.trayecto.horaProgramada;
    _horaProgramada = horaProgramadaDateTime != null
        ? TimeOfDay(hour: horaProgramadaDateTime.hour, minute: horaProgramadaDateTime.minute)
        : TimeOfDay.now();

    // Inicializar origen - SIEMPRE con los valores del trayecto
    _tipoOrigen = widget.trayecto.tipoOrigen;
    _origenValue = widget.trayecto.origen;
    debugPrint('🔍 Inicializando origen: tipo=$_tipoOrigen, valor=$_origenValue');

    // Si es domicilio, crear controlador con el texto de la dirección
    if (_tipoOrigen == 'domicilio_paciente' || _tipoOrigen == 'otro_domicilio') {
      _origenDireccionController = TextEditingController(text: _origenValue ?? '');
      debugPrint('📝 Controlador origen creado con: ${_origenValue ?? "(vacío)"}');
    }

    // Inicializar destino - SIEMPRE con los valores del trayecto
    _tipoDestino = widget.trayecto.tipoDestino;
    _destinoValue = widget.trayecto.destino;
    debugPrint('🔍 Inicializando destino: tipo=$_tipoDestino, valor=$_destinoValue');

    // Si es domicilio, crear controlador con el texto de la dirección
    if (_tipoDestino == 'domicilio_paciente' || _tipoDestino == 'otro_domicilio') {
      _destinoDireccionController = TextEditingController(text: _destinoValue ?? '');
      debugPrint('📝 Controlador destino creado con: ${_destinoValue ?? "(vacío)"}');
    }

    _loadCentrosHospitalarios();
  }

  Future<void> _loadCentrosHospitalarios() async {
    try {
      debugPrint('🏥 Cargando centros hospitalarios...');
      debugPrint('📊 Estado inicial: tipoOrigen=$_tipoOrigen, origenValue=$_origenValue');
      debugPrint('📊 Estado inicial: tipoDestino=$_tipoDestino, destinoValue=$_destinoValue');

      final List<CentroHospitalarioEntity> centros = await _centroHospitalarioDataSource.getAll();
      debugPrint('🏥 ${centros.length} centros cargados desde Supabase');

      if (mounted) {
        // Primero establecer la lista de centros (incluyendo inactivos para búsqueda)
        _centrosHospitalarios = centros;
        debugPrint('🏥 ${_centrosHospitalarios.length} centros totales disponibles');

        // Si el origen es un centro hospitalario, buscar el seleccionado
        if (_tipoOrigen == 'centro_hospitalario' && _origenValue != null) {
          debugPrint('🔍 Buscando centro origen: $_origenValue');
          debugPrint('🔍 IDs disponibles: ${_centrosHospitalarios.map((CentroHospitalarioEntity c) => c.id).join(", ")}');

          // Primero intentar buscar por ID (UUID)
          try {
            _centroOrigenSeleccionado = _centrosHospitalarios.firstWhere(
              (CentroHospitalarioEntity c) => c.id == _origenValue,
            );
            debugPrint('✅ Centro origen encontrado por ID: ${_centroOrigenSeleccionado!.nombre} (ID: ${_centroOrigenSeleccionado!.id}, activo: ${_centroOrigenSeleccionado!.activo})');
          } catch (e) {
            // Si no se encuentra por ID, intentar buscar por nombre (legacy data)
            debugPrint('⚠️ Centro origen NO encontrado por ID: $_origenValue');
            debugPrint('🔍 Intentando buscar por nombre...');
            try {
              _centroOrigenSeleccionado = _centrosHospitalarios.firstWhere(
                (CentroHospitalarioEntity c) => c.nombre == _origenValue,
              );
              debugPrint('✅ Centro origen encontrado por NOMBRE: ${_centroOrigenSeleccionado!.nombre} (ID: ${_centroOrigenSeleccionado!.id}, activo: ${_centroOrigenSeleccionado!.activo})');
              // Actualizar _origenValue con el ID correcto para futuras actualizaciones
              _origenValue = _centroOrigenSeleccionado!.id;
              debugPrint('🔄 Valor actualizado a ID: $_origenValue');
            } catch (e2) {
              debugPrint('❌ Centro origen NO encontrado ni por ID ni por nombre: $_origenValue');
            }
          }
        } else {
          debugPrint('ℹ️ Origen NO es centro hospitalario: tipoOrigen=$_tipoOrigen, origenValue=$_origenValue');
        }

        // Si el destino es un centro hospitalario, buscar el seleccionado
        if (_tipoDestino == 'centro_hospitalario' && _destinoValue != null) {
          debugPrint('🔍 Buscando centro destino: $_destinoValue');
          debugPrint('🔍 IDs disponibles: ${_centrosHospitalarios.map((CentroHospitalarioEntity c) => c.id).join(", ")}');

          // Primero intentar buscar por ID (UUID)
          try {
            _centroDestinoSeleccionado = _centrosHospitalarios.firstWhere(
              (CentroHospitalarioEntity c) => c.id == _destinoValue,
            );
            debugPrint('✅ Centro destino encontrado por ID: ${_centroDestinoSeleccionado!.nombre} (ID: ${_centroDestinoSeleccionado!.id}, activo: ${_centroDestinoSeleccionado!.activo})');
          } catch (e) {
            // Si no se encuentra por ID, intentar buscar por nombre (legacy data)
            debugPrint('⚠️ Centro destino NO encontrado por ID: $_destinoValue');
            debugPrint('🔍 Intentando buscar por nombre...');
            try {
              _centroDestinoSeleccionado = _centrosHospitalarios.firstWhere(
                (CentroHospitalarioEntity c) => c.nombre == _destinoValue,
              );
              debugPrint('✅ Centro destino encontrado por NOMBRE: ${_centroDestinoSeleccionado!.nombre} (ID: ${_centroDestinoSeleccionado!.id}, activo: ${_centroDestinoSeleccionado!.activo})');
              // Actualizar _destinoValue con el ID correcto para futuras actualizaciones
              _destinoValue = _centroDestinoSeleccionado!.id;
              debugPrint('🔄 Valor actualizado a ID: $_destinoValue');
            } catch (e2) {
              debugPrint('❌ Centro destino NO encontrado ni por ID ni por nombre: $_destinoValue');
            }
          }
        } else {
          debugPrint('ℹ️ Destino NO es centro hospitalario: tipoDestino=$_tipoDestino, destinoValue=$_destinoValue');
        }

        debugPrint('🎯 Finalizando carga. Centros seleccionados:');
        debugPrint('   - Origen: ${_centroOrigenSeleccionado?.nombre ?? "NINGUNO"}');
        debugPrint('   - Destino: ${_centroDestinoSeleccionado?.nombre ?? "NINGUNO"}');

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando centros hospitalarios: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _origenDireccionController?.dispose();
    _destinoDireccionController?.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fecha) {
      setState(() {
        _fecha = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaProgramada,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _horaProgramada) {
      setState(() {
        _horaProgramada = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Crear hora programada como String "HH:mm:ss"
      final String nuevaHoraProgramada =
          '${_horaProgramada.hour.toString().padLeft(2, '0')}:${_horaProgramada.minute.toString().padLeft(2, '0')}:00';

      // Crear trayecto actualizado
      final TrasladoEntity trayectoActualizado = widget.trayecto.copyWith(
        fecha: _fecha,
        horaProgramada: DateTime.parse('${_fecha.toIso8601String().split('T')[0]}T$nuevaHoraProgramada'),
        tipoOrigen: _tipoOrigen,
        origen: _origenValue,
        tipoDestino: _tipoDestino,
        destino: _destinoValue,
        observaciones: _observacionesController.text.trim().isNotEmpty
            ? _observacionesController.text.trim()
            : null,
        updatedAt: DateTime.now(),
      );

      // Guardar en Supabase usando update con Map
      await _trasladoDataSource.update(
        id: widget.trayecto.id,
        updates: <String, dynamic>{
          'fecha': _fecha.toIso8601String(),
          'hora_programada': DateTime.parse('${_fecha.toIso8601String().split('T')[0]}T$nuevaHoraProgramada').toIso8601String(),
          'tipo_origen': _tipoOrigen,
          'origen': _origenValue,
          'tipo_destino': _tipoDestino,
          'destino': _destinoValue,
          'observaciones': _observacionesController.text.trim().isNotEmpty
              ? _observacionesController.text.trim()
              : null,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        // Llamar callback onSave
        widget.onSave(trayectoActualizado);

        // Cerrar diálogo
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error al guardar trayecto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppDialog(
        title: 'Editar Trayecto',
        type: AppDialogType.edit,
        icon: Icons.edit_road,
        content: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingMassive),
            child: CircularProgressIndicator(),
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
        ],
      );
    }

    return AppDialog(
      title: 'Editar Trayecto',
      type: AppDialogType.edit,
      icon: Icons.edit_road,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Tipo de Traslado (Solo lectura)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray300),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.trayecto.tipoTraslado == 'ida'
                          ? Icons.arrow_forward
                          : Icons.arrow_back,
                      color: AppColors.textSecondaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Tipo de Traslado',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.trayecto.tipoTraslado == 'ida' ? 'Ida' : 'Vuelta',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'No editable',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacing),

              // Fecha y Hora
              const _SectionHeader(
                icon: Icons.calendar_today_outlined,
                title: 'Fecha y Hora',
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Row(
                children: <Widget>[
                  // Fecha
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today, size: 20),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_fecha),
                          style: const TextStyle(
                            fontSize: AppSizes.fontMedium,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  // Hora
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.paddingSmall,
                          ),
                          suffixIcon: const Icon(Icons.access_time, size: 20),
                        ),
                        child: Text(
                          _horaProgramada.format(context),
                          style: const TextStyle(
                            fontSize: AppSizes.fontMedium,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),

              // ORIGEN
              const _SectionHeader(
                icon: Icons.place_outlined,
                title: 'Origen',
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              _buildLocationInput(
                tipo: _tipoOrigen,
                locationValue: _origenValue,
                direccionController: _origenDireccionController,
                centroSeleccionado: _centroOrigenSeleccionado,
                labelPrefix: 'Origen',
                onTipoChanged: (String? value) {
                  setState(() {
                    _tipoOrigen = value;
                    _origenValue = null;
                    _centroOrigenSeleccionado = null;
                    _origenDireccionController?.dispose();
                    _origenDireccionController = null;
                    if (value == 'domicilio_paciente' || value == 'otro_domicilio') {
                      _origenDireccionController = TextEditingController();
                    }
                  });
                },
                onDireccionChanged: (String? value) {
                  _origenValue = value;
                },
                onCentroChanged: (CentroHospitalarioEntity? centro) {
                  setState(() {
                    _centroOrigenSeleccionado = centro;
                    _origenValue = centro?.id;
                  });
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // DESTINO
              const _SectionHeader(
                icon: Icons.flag_outlined,
                title: 'Destino',
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              _buildLocationInput(
                tipo: _tipoDestino,
                locationValue: _destinoValue,
                direccionController: _destinoDireccionController,
                centroSeleccionado: _centroDestinoSeleccionado,
                labelPrefix: 'Destino',
                onTipoChanged: (String? value) {
                  setState(() {
                    _tipoDestino = value;
                    _destinoValue = null;
                    _centroDestinoSeleccionado = null;
                    _destinoDireccionController?.dispose();
                    _destinoDireccionController = null;
                    if (value == 'domicilio_paciente' || value == 'otro_domicilio') {
                      _destinoDireccionController = TextEditingController();
                    }
                  });
                },
                onDireccionChanged: (String? value) {
                  _destinoValue = value;
                },
                onCentroChanged: (CentroHospitalarioEntity? centro) {
                  setState(() {
                    _centroDestinoSeleccionado = centro;
                    _destinoValue = centro?.id;
                  });
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // Observaciones
              const _SectionHeader(
                icon: Icons.notes_outlined,
                title: 'Observaciones',
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              TextFormField(
                controller: _observacionesController,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Notas adicionales sobre el trayecto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _isSaving ? null : _onSave,
          label: _isSaving ? 'Guardando...' : 'Guardar',
          icon: Icons.save,
        ),
      ],
    );
  }

  /// Construye el input de ubicación según el tipo seleccionado
  Widget _buildLocationInput({
    required String? tipo,
    required String? locationValue,
    required TextEditingController? direccionController,
    required CentroHospitalarioEntity? centroSeleccionado,
    required String labelPrefix,
    required void Function(String?) onTipoChanged,
    required void Function(String?) onDireccionChanged,
    required void Function(CentroHospitalarioEntity?) onCentroChanged,
  }) {
    debugPrint('🔨 _buildLocationInput para $labelPrefix:');
    debugPrint('   tipo: $tipo');
    debugPrint('   locationValue: $locationValue');
    debugPrint('   direccionController.text: ${direccionController?.text ?? "null"}');
    debugPrint('   centroSeleccionado: ${centroSeleccionado?.nombre ?? "null"}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Selector de tipo
        AppDropdown<String>(
          value: tipo,
          label: 'Tipo $labelPrefix *',
          hint: 'Seleccione tipo',
          prefixIcon: Icons.category,
          items: const <AppDropdownItem<String>>[
            AppDropdownItem<String>(
              value: 'domicilio_paciente',
              label: 'Domicilio Paciente',
              icon: Icons.home,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<String>(
              value: 'otro_domicilio',
              label: 'Otro Domicilio',
              icon: Icons.location_city,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<String>(
              value: 'centro_hospitalario',
              label: 'Centro Hospitalario',
              icon: Icons.local_hospital,
              iconColor: AppColors.error,
            ),
          ],
          onChanged: onTipoChanged,
        ),
        const SizedBox(height: AppSizes.spacing),

        // Input condicional según tipo
        if (tipo == 'domicilio_paciente') ...<Widget>[
          TextFormField(
            key: ValueKey<String>('domicilio_paciente_$labelPrefix'),
            controller: direccionController,
            decoration: InputDecoration(
              labelText: 'Dirección Domicilio Paciente *',
              hintText: 'Ingrese dirección del domicilio',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              prefixIcon: const Icon(Icons.home, size: 20),
            ),
            maxLines: 2,
            onChanged: onDireccionChanged,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingrese la dirección';
              }
              return null;
            },
          ),
        ] else if (tipo == 'otro_domicilio') ...<Widget>[
          TextFormField(
            key: ValueKey<String>('otro_domicilio_$labelPrefix'),
            controller: direccionController,
            decoration: InputDecoration(
              labelText: 'Otra Dirección *',
              hintText: 'Ingrese dirección',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              prefixIcon: const Icon(Icons.location_city, size: 20),
            ),
            maxLines: 2,
            onChanged: onDireccionChanged,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingrese la dirección';
              }
              return null;
            },
          ),
        ] else if (tipo == 'centro_hospitalario') ...<Widget>[
          AppSearchableDropdown<CentroHospitalarioEntity>(
            key: ValueKey<String>('centro_hospitalario_${labelPrefix}_${centroSeleccionado?.id ?? "null"}'),
            value: centroSeleccionado,
            label: 'Centro Hospitalario *',
            hint: 'Buscar centro por nombre',
            prefixIcon: Icons.local_hospital,
            searchHint: 'Escribe para buscar...',
            items: _centrosHospitalarios
                .map(
                  (CentroHospitalarioEntity centro) => AppSearchableDropdownItem<CentroHospitalarioEntity>(
                    value: centro,
                    label: centro.nombre,
                    icon: Icons.local_hospital,
                    iconColor: AppColors.error,
                  ),
                )
                .toList(),
            onChanged: onCentroChanged,
            displayStringForOption: (CentroHospitalarioEntity centro) => centro.nombre,
          ),
        ] else ...<Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.info_outline, color: AppColors.textSecondaryLight, size: 20),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    'Seleccione un tipo de ubicación',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Header de sección del formulario
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
