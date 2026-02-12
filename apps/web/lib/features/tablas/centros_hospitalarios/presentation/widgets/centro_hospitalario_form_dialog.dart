import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar centros hospitalarios
class CentroHospitalarioFormDialog extends StatefulWidget {
  const CentroHospitalarioFormDialog({super.key, this.centro});

  final CentroHospitalarioEntity? centro;

  @override
  State<CentroHospitalarioFormDialog> createState() => _CentroHospitalarioFormDialogState();
}

class _CentroHospitalarioFormDialogState extends State<CentroHospitalarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<LocalidadEntity> _todasLasLocalidades = <LocalidadEntity>[];
  List<LocalidadEntity> _localidadesFiltradas = <LocalidadEntity>[];

  String? _provinciaId;
  String? _localidadId;
  String? _tipoCentro;
  bool _activo = true;
  bool _isLoadingData = false;
  bool get _isEditing => widget.centro != null;

  // Tipos de centro disponibles
  final List<AppDropdownItem<String>> _tiposCentro = <AppDropdownItem<String>>[
    const AppDropdownItem<String>(value: 'HOSPITAL', label: 'HOSPITAL'),
    const AppDropdownItem<String>(value: 'CENTRO SALUD', label: 'CENTRO SALUD'),
    const AppDropdownItem<String>(value: 'CLÍNICA', label: 'CLÍNICA'),
  ];

  @override
  void initState() {
    super.initState();
    final CentroHospitalarioEntity? c = widget.centro;

    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _direccionController = TextEditingController(text: c?.direccion ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');

    _localidadId = c?.localidadId;

    // Validar que el tipo de centro existe en la lista de opciones
    if (c?.tipoCentro != null) {
      final bool existeEnLista = _tiposCentro.any(
        (AppDropdownItem<String> item) => item.value == c!.tipoCentro,
      );
      _tipoCentro = existeEnLista ? c!.tipoCentro : null;

      if (!existeEnLista && c!.tipoCentro != null) {
        debugPrint('⚠️ Tipo de centro "${c.tipoCentro}" no está en la lista de opciones predefinidas');
      }
    }

    _activo = c?.activo ?? true;

    _loadData();
  }

  /// Carga provincias y localidades
  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final ProvinciaDataSource provinciaDataSource = getIt<ProvinciaDataSource>();
      final LocalidadRepository localidadRepository = getIt<LocalidadRepository>();

      final List<ProvinciaEntity> provincias = await provinciaDataSource.getAll();
      final List<LocalidadEntity> localidades = await localidadRepository.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias..sort((ProvinciaEntity a, ProvinciaEntity b) => a.nombre.compareTo(b.nombre));
          _todasLasLocalidades = localidades..sort((LocalidadEntity a, LocalidadEntity b) => a.nombre.compareTo(b.nombre));

          // Si estamos editando, buscar la provincia de la localidad seleccionada
          if (_isEditing && _localidadId != null) {
            try {
              final LocalidadEntity localidadActual = _todasLasLocalidades.firstWhere(
                (LocalidadEntity l) => l.id == _localidadId,
              );
              _provinciaId = localidadActual.provinciaId;
              _filtrarLocalidadesPorProvincia(_provinciaId);
            } catch (e) {
              debugPrint('⚠️ No se encontró la localidad con id: $_localidadId');
            }
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  /// Filtra localidades por provincia seleccionada
  void _filtrarLocalidadesPorProvincia(String? provinciaId) {
    if (provinciaId == null) {
      setState(() {
        _localidadesFiltradas = <LocalidadEntity>[];
        _localidadId = null;
      });
      return;
    }

    setState(() {
      _localidadesFiltradas = _todasLasLocalidades
          .where((LocalidadEntity l) => l.provinciaId == provinciaId)
          .toList();

      // Si la localidad actual no pertenece a la provincia seleccionada, resetearla
      if (_localidadId != null &&
          !_localidadesFiltradas.any((LocalidadEntity l) => l.id == _localidadId)) {
        _localidadId = null;
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final CentroHospitalarioEntity centro = CentroHospitalarioEntity(
      id: widget.centro?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty
          ? null
          : _direccionController.text.trim(),
      localidadId: _localidadId,
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      tipoCentro: _tipoCentro,
      activo: _activo,
      createdAt: widget.centro?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando centro hospitalario: ${centro.nombre}');
      context.read<CentroHospitalarioBloc>().add(
            CentroHospitalarioUpdateRequested(centro),
          );
    } else {
      debugPrint('➕ Creando nuevo centro hospitalario: ${centro.nombre}');
      context.read<CentroHospitalarioBloc>().add(
            CentroHospitalarioCreateRequested(centro),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CentroHospitalarioBloc, CentroHospitalarioState>(
      listener: (BuildContext context, CentroHospitalarioState state) {
        if (state is CentroHospitalarioLoaded) {
          debugPrint('✅ CentroHospitalarioFormDialog: Centro guardado exitosamente, cerrando diálogo');

          Navigator.of(context).pop(); // Cierra el formulario

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? '✅ Centro hospitalario actualizado exitosamente' : '✅ Centro hospitalario creado exitosamente'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is CentroHospitalarioError) {
          debugPrint('❌ CentroHospitalarioFormDialog: Error al guardar centro - ${state.message}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${state.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      builder: (BuildContext context, CentroHospitalarioState state) {
        final bool isSaving = state is CentroHospitalarioLoading && !_isLoadingData;

        return AppDialog(
          title: _isEditing ? 'Editar Centro Hospitalario' : 'Nuevo Centro Hospitalario',
          icon: _isEditing ? Icons.edit : Icons.add,
          type: _isEditing ? AppDialogType.edit : AppDialogType.create,
          content: _isLoadingData
              ? const Center(
                  child: AppLoadingIndicator(
                    message: 'Cargando datos...',
                    size: 100,
                  ),
                )
              : isSaving
                  ? const Center(
                      child: AppLoadingIndicator(
                        message: 'Guardando...',
                        size: 100,
                      ),
                    )
                  : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Nombre
                          TextFormField(
                            controller: _nombreController,
                            textInputAction: TextInputAction.next,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              hintText: 'Ingrese el nombre del centro',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              prefixIcon: const Icon(Icons.local_hospital),
                            ),
                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Tipo de Centro
                          AppDropdown<String>(
                            value: _tipoCentro,
                            label: 'Tipo de Centro',
                            hint: 'Seleccione el tipo',
                            prefixIcon: Icons.category,
                            items: _tiposCentro,
                            onChanged: (String? value) {
                              setState(() => _tipoCentro = value);
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Dirección
                          TextFormField(
                            controller: _direccionController,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: 'Dirección',
                              hintText: 'Ingrese la dirección completa',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Provincia
                          AppDropdown<String>(
                            value: _provinciaId,
                            label: 'Provincia',
                            hint: 'Seleccione la provincia',
                            prefixIcon: Icons.map,
                            items: _provincias
                                .map(
                                  (ProvinciaEntity p) => AppDropdownItem<String>(
                                    value: p.id,
                                    label: p.nombre,
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _provinciaId = value;
                                _filtrarLocalidadesPorProvincia(value);
                              });
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Localidad (filtrada por provincia)
                          AppDropdown<String>(
                            value: _localidadId,
                            label: 'Localidad / Población',
                            hint: _provinciaId == null
                                ? 'Primero seleccione una provincia'
                                : 'Seleccione la localidad',
                            prefixIcon: Icons.location_city,
                            enabled: _provinciaId != null,
                            items: _localidadesFiltradas
                                .map(
                                  (LocalidadEntity l) => AppDropdownItem<String>(
                                    value: l.id,
                                    label: l.nombre,
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              setState(() => _localidadId = value);
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Teléfono
                          TextFormField(
                            controller: _telefonoController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Teléfono',
                              hintText: 'Ingrese el teléfono',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Ingrese el email',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              prefixIcon: const Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (String? value) {
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  !value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.spacing),

                          // Estado (Activo/Inactivo)
                          Row(
                            children: <Widget>[
                              Text(
                                'Estado:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacing),
                              Switch(
                                value: _activo,
                                onChanged: (bool value) {
                                  setState(() => _activo = value);
                                },
                                activeTrackColor: AppColors.success,
                              ),
                              const SizedBox(width: AppSizes.spacingSmall),
                              Text(
                                _activo ? 'Activo' : 'Inactivo',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: _activo ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          actions: <Widget>[
            AppButton(
              onPressed: (isSaving || _isLoadingData) ? null : () => Navigator.of(context).pop(),
              label: 'Cancelar',
              variant: AppButtonVariant.text,
            ),
            AppButton(
              onPressed: (_isLoadingData || isSaving) ? null : _onSave,
              label: _isEditing ? 'Actualizar' : 'Crear',
              icon: _isEditing ? Icons.check : Icons.save,
            ),
          ],
        );
      },
    );
  }
}

/// Formatter que convierte el texto a mayúsculas automáticamente
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
