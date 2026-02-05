import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar proveedores con provincia y localidad combinadas
class ProveedorFormDialog extends StatefulWidget {
  const ProveedorFormDialog({super.key, this.proveedor});

  final ProveedorEntity? proveedor;

  @override
  State<ProveedorFormDialog> createState() => _ProveedorFormDialogState();
}

class _ProveedorFormDialogState extends State<ProveedorFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _codigoController;
  late TextEditingController _nombreComercialController;
  late TextEditingController _razonSocialController;
  late TextEditingController _cifNifController;
  late TextEditingController _direccionController;
  late TextEditingController _codigoPostalController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  // Listas de maestros
  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  List<LocalidadEntity> _todasLocalidades = <LocalidadEntity>[];
  List<LocalidadEntity> _localidadesFiltradas = <LocalidadEntity>[];

  // IDs seleccionados
  String? _provinciaId;
  String? _localidadId;

  bool _activo = true;
  bool _isSaving = false;
  bool _isLoadingMasters = true;
  bool get _isEditing => widget.proveedor != null;

  @override
  void initState() {
    super.initState();
    final ProveedorEntity? p = widget.proveedor;

    _codigoController = TextEditingController(text: p?.codigo ?? '');
    _nombreComercialController = TextEditingController(text: p?.nombreComercial ?? '');
    _razonSocialController = TextEditingController(text: p?.razonSocial ?? '');
    _cifNifController = TextEditingController(text: p?.cifNif ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _codigoPostalController = TextEditingController(text: p?.codigoPostal ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _activo = p?.activo ?? true;

    // Cargar provincias y localidades
    _loadMasterData();
  }

  /// Carga provincias y localidades desde los datasources
  Future<void> _loadMasterData() async {
    setState(() {
      _isLoadingMasters = true;
    });

    try {
      // Cargar provincias
      final ProvinciaDataSource provinciaDS = getIt<ProvinciaDataSource>();
      final List<ProvinciaEntity> provincias = await provinciaDS.getAll();

      // Cargar localidades
      final LocalidadDataSource localidadDS = getIt<LocalidadDataSource>();
      final List<LocalidadEntity> localidades = await localidadDS.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias;
          _todasLocalidades = localidades;
          _isLoadingMasters = false;

          // Si estamos editando, intentar recuperar provincia y localidad desde el proveedor
          if (widget.proveedor != null) {
            // Buscar provincia por nombre
            if (widget.proveedor!.provincia != null && widget.proveedor!.provincia!.isNotEmpty) {
              final ProvinciaEntity? provinciaMatch = _provincias.cast<ProvinciaEntity?>().firstWhere(
                (ProvinciaEntity? p) => p?.nombre == widget.proveedor!.provincia,
                orElse: () => null,
              );

              if (provinciaMatch != null) {
                _provinciaId = provinciaMatch.id;
                _filterLocalidadesByProvincia(_provinciaId!);

                // Buscar localidad por nombre
                if (widget.proveedor!.ciudad != null && widget.proveedor!.ciudad!.isNotEmpty) {
                  final LocalidadEntity? localidadMatch = _localidadesFiltradas.cast<LocalidadEntity?>().firstWhere(
                    (LocalidadEntity? l) => l?.nombre == widget.proveedor!.ciudad,
                    orElse: () => null,
                  );
                  if (localidadMatch != null) {
                    _localidadId = localidadMatch.id;
                  }
                }
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar provincias/localidades: $e');
      if (mounted) {
        setState(() {
          _isLoadingMasters = false;
        });
      }
    }
  }

  /// Filtra localidades según la provincia seleccionada
  void _filterLocalidadesByProvincia(String provinciaId) {
    setState(() {
      _localidadesFiltradas = _todasLocalidades.where((LocalidadEntity l) => l.provinciaId == provinciaId).toList();

      // Si la localidad seleccionada no está en la nueva lista filtrada, resetearla
      if (_localidadId != null && !_localidadesFiltradas.any((LocalidadEntity l) => l.id == _localidadId)) {
        _localidadId = null;
      }
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreComercialController.dispose();
    _razonSocialController.dispose();
    _cifNifController.dispose();
    _direccionController.dispose();
    _codigoPostalController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProveedoresBloc, ProveedoresState>(
      listener: (BuildContext context, ProveedoresState state) {
        if (state is ProveedoresLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Proveedor',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is ProveedoresError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Proveedor',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
        icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        maxWidth: 800,
        content: _isLoadingMasters
            ? const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando datos...',
                  size: 100,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Código y Nombre Comercial (obligatorios)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _codigoController,
                              decoration: const InputDecoration(
                                labelText: 'Código *',
                                hintText: 'PROV001',
                                prefixIcon: Icon(Icons.tag),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El código es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nombreComercialController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre Comercial *',
                                hintText: 'Ej: Suministros Médicos SA',
                                prefixIcon: Icon(Icons.business),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre comercial es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Razón Social y CIF/NIF
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _razonSocialController,
                              decoration: const InputDecoration(
                                labelText: 'Razón Social',
                                prefixIcon: Icon(Icons.business_center),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            child: TextFormField(
                              controller: _cifNifController,
                              decoration: const InputDecoration(
                                labelText: 'CIF/NIF',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Dirección
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Código Postal, Provincia y Localidad (COMBOS COMBINADOS)
                      Row(
                        children: <Widget>[
                          // Código Postal
                          Expanded(
                            child: TextFormField(
                              controller: _codigoPostalController,
                              decoration: const InputDecoration(
                                labelText: 'C.P.',
                                prefixIcon: Icon(Icons.markunread_mailbox),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),

                          // Provincia (Dropdown)
                          Expanded(
                            flex: 2,
                            child: AppDropdown<String>(
                              value: _provinciaId,
                              label: 'Provincia',
                              hint: 'Selecciona provincia',
                              prefixIcon: Icons.map,
                              items: _provincias
                                  .map(
                                    (ProvinciaEntity p) => AppDropdownItem<String>(
                                      value: p.id,
                                      label: p.nombre,
                                      icon: Icons.location_city,
                                      iconColor: AppColors.primary,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _provinciaId = value;
                                  if (value != null) {
                                    _filterLocalidadesByProvincia(value);
                                  } else {
                                    _localidadesFiltradas.clear();
                                    _localidadId = null;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),

                          // Localidad (Dropdown filtrado por provincia)
                          Expanded(
                            flex: 2,
                            child: AppDropdown<String>(
                              value: _localidadId,
                              label: 'Localidad',
                              hint: _provinciaId == null ? 'Selecciona provincia primero' : 'Selecciona localidad',
                              prefixIcon: Icons.location_city,
                              enabled: _provinciaId != null && _localidadesFiltradas.isNotEmpty,
                              items: _localidadesFiltradas
                                  .map(
                                    (LocalidadEntity l) => AppDropdownItem<String>(
                                      value: l.id,
                                      label: l.nombre,
                                      icon: Icons.place,
                                      iconColor: AppColors.secondary,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _localidadId = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Teléfono y Email
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              textInputAction: TextInputAction.done,
                              validator: (String? value) {
                                if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
                                  return 'Email no válido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Estado (Activo/Inactivo)
                      SwitchListTile(
                        value: _activo,
                        onChanged: (bool value) {
                          setState(() {
                            _activo = value;
                          });
                        },
                        title: Text(_activo ? 'Activo' : 'Inactivo'),
                        secondary: Icon(
                          _activo ? Icons.check_circle : Icons.cancel,
                          color: _activo ? AppColors.success : AppColors.error,
                        ),
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
            onPressed: _isSaving || _isLoadingMasters ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando proveedor...' : 'Creando proveedor...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    // Obtener nombres de provincia y localidad desde los IDs
    String? provinciaNombre;
    String? localidadNombre;

    if (_provinciaId != null) {
      final ProvinciaEntity? provincia = _provincias.cast<ProvinciaEntity?>().firstWhere(
        (ProvinciaEntity? p) => p?.id == _provinciaId,
        orElse: () => null,
      );
      provinciaNombre = provincia?.nombre;
    }

    if (_localidadId != null) {
      final LocalidadEntity? localidad = _localidadesFiltradas.cast<LocalidadEntity?>().firstWhere(
        (LocalidadEntity? l) => l?.id == _localidadId,
        orElse: () => null,
      );
      localidadNombre = localidad?.nombre;
    }

    // Crear entidad
    final ProveedorEntity proveedor = ProveedorEntity(
      id: widget.proveedor?.id ?? const Uuid().v4(),
      codigo: _codigoController.text.trim(),
      nombreComercial: _nombreComercialController.text.trim(),
      razonSocial: _razonSocialController.text.trim().isNotEmpty ? _razonSocialController.text.trim() : null,
      cifNif: _cifNifController.text.trim().isNotEmpty ? _cifNifController.text.trim() : null,
      direccion: _direccionController.text.trim().isNotEmpty ? _direccionController.text.trim() : null,
      codigoPostal: _codigoPostalController.text.trim().isNotEmpty ? _codigoPostalController.text.trim() : null,
      ciudad: localidadNombre, // Guardamos el nombre de la localidad
      provincia: provinciaNombre, // Guardamos el nombre de la provincia
      telefono: _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      activo: _activo,
      createdAt: widget.proveedor?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Disparar evento
    if (_isEditing) {
      context.read<ProveedoresBloc>().add(ProveedorUpdateRequested(proveedor));
    } else {
      context.read<ProveedoresBloc>().add(ProveedorCreateRequested(proveedor));
    }
  }
}
