import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc_exports.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/form/dotacion_form_body.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/form/dotacion_form_data.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo de formulario para crear/editar una Dotación
class DotacionFormDialog extends StatefulWidget {
  const DotacionFormDialog({super.key, this.dotacion});

  final DotacionEntity? dotacion;

  @override
  State<DotacionFormDialog> createState() => _DotacionFormDialogState();
}

class _DotacionFormDialogState extends State<DotacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final DotacionFormData _data = DotacionFormData(original: widget.dotacion);

  bool _isSaving = false;
  bool _isLoading = true;
  DotacionFormCatalogos _catalogos = const DotacionFormCatalogos();

  bool get _isEditing => widget.dotacion != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  /// Carga datos asíncronos necesarios para los selectores
  Future<void> _loadData() async {
    try {
      final List<BaseCentroEntity> bases = await getIt<BasesRepository>().getActivas();
      final List<ContratoEntity> contratos = await getIt<ContratoRepository>().getActivos();
      final List<CentroHospitalarioEntity> hospitales = await getIt<CentroHospitalarioRepository>().getAll();
      final List<TipoVehiculoEntity> tiposVehiculo = await getIt<TipoVehiculoRepository>().getAll();

      // Crear map de hospitales para lookup rápido
      final Map<String, String> hospitalesMap = <String, String>{
        for (final CentroHospitalarioEntity h in hospitales) h.id: h.nombre,
      };

      if (mounted) {
        setState(() {
          _catalogos = DotacionFormCatalogos(
            bases: bases,
            contratos: contratos,
            tiposVehiculo: tiposVehiculo,
            hospitalesMap: hospitalesMap,
          );
          _isLoading = false;
        });
        debugPrint(
          '✅ Datos cargados: ${bases.length} bases, ${contratos.length} contratos, '
          '${hospitalesMap.length} hospitales, ${tiposVehiculo.length} tipos de vehículo',
        );
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        await showResultDialog(
          context: context,
          title: 'Error al cargar datos',
          message: 'No se pudieron cargar bases, contratos o tipos de vehículo.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  void _onBlocState(BuildContext context, DotacionesState state) {
    void reset() {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (state is DotacionesLoaded && _isSaving) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Dotación',
        onComplete: reset,
      );
    }
    if (state is DotacionesError && _isSaving) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        errorMessage: state.message,
        onComplete: reset,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DotacionesBloc, DotacionesState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar dotación' : 'Nueva dotación',
        subtitle: _isEditing ? (widget.dotacion!.codigo ?? widget.dotacion!.nombre) : null,
        icon: Icons.groups_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        saveLabel: _isEditing ? 'Actualizar' : 'Crear',
        onSave: _onSave,
        children: <Widget>[
          DotacionFormBody(
            data: _data,
            catalogos: _catalogos,
            isLoading: _isLoading,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    // Base, tipo de vehículo y días se validan en el propio campo
    if (_isLoading ||
        !_formKey.currentState!.validate() ||
        _data.baseId == null ||
        _data.tipoVehiculoId == null ||
        !_data.tieneDias) {
      return;
    }

    final List<bool> d = _data.dias;
    final DotacionEntity dotacion = DotacionEntity(
      id: widget.dotacion?.id ?? '',
      codigo: widget.dotacion?.codigo,
      nombre: _data.nombre.text.trim(),
      descripcion: _data.descripcion.text.trim().isNotEmpty ? _data.descripcion.text.trim() : null,
      baseId: _data.baseId,
      contratoId: _data.contratoId,
      tipoVehiculoId: _data.tipoVehiculoId!,
      cantidadUnidades: int.parse(_data.cantidadUnidades.text),
      prioridad: int.parse(_data.prioridad.text),
      fechaInicio: _data.fechaInicio,
      fechaFin: _data.fechaFin,
      aplicaLunes: d[0],
      aplicaMartes: d[1],
      aplicaMiercoles: d[2],
      aplicaJueves: d[3],
      aplicaViernes: d[4],
      aplicaSabado: d[5],
      aplicaDomingo: d[6],
      activo: _data.activo,
      createdAt: widget.dotacion?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('💾 Guardando dotación: ${dotacion.nombre}');

    // Mostrar loading overlay
    setState(() => _isSaving = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando Dotación...' : 'Creando Dotación...',
          color: AppColors.primary,
          icon: Icons.save,
        ),
      ),
    );

    // Disparar evento de guardado
    context.read<DotacionesBloc>().add(
          _isEditing ? DotacionUpdateRequested(dotacion) : DotacionCreateRequested(dotacion),
        );
  }
}
