import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/proveedor_form_body.dart';
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
      child: GestionFormDialog(
        title: _isEditing ? 'Editar proveedor' : 'Nuevo proveedor',
        subtitle: _isEditing ? widget.proveedor!.nombreComercial : null,
        icon: Icons.business_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (_isLoadingMasters)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppLoadingIndicator(message: 'Cargando datos...'),
            )
          else
            ProveedorFormBody(
              codigo: _codigoController,
              nombreComercial: _nombreComercialController,
              razonSocial: _razonSocialController,
              cifNif: _cifNifController,
              direccion: _direccionController,
              codigoPostal: _codigoPostalController,
              telefono: _telefonoController,
              email: _emailController,
              provincias: _provincias,
              localidades: _localidadesFiltradas,
              provinciaId: _provinciaId,
              localidadId: _localidadId,
              onProvincia: _onProvinciaChanged,
              onLocalidad: (String? value) => setState(() => _localidadId = value),
              activo: _activo,
              onActivo: (bool value) => setState(() => _activo = value),
            ),
        ],
      ),
    );
  }

  void _onProvinciaChanged(String? value) {
    setState(() {
      _provinciaId = value;
      if (value != null) {
        _filterLocalidadesByProvincia(value);
      } else {
        _localidadesFiltradas.clear();
        _localidadId = null;
      }
    });
  }

  void _onSave() {
    if (_isLoadingMasters || !_formKey.currentState!.validate()) {
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
