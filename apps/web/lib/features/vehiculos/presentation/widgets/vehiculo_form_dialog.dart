import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart'
    as auth;
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/form/vehiculo_form_body.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/form/vehiculo_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear/editar vehículos
class VehiculoFormDialog extends StatefulWidget {
  const VehiculoFormDialog({super.key, this.vehiculo});

  final VehiculoEntity? vehiculo;

  @override
  State<VehiculoFormDialog> createState() => _VehiculoFormDialogState();
}

class _VehiculoFormDialogState extends State<VehiculoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final VehiculoFormData _data = VehiculoFormData(original: widget.vehiculo);
  bool _isSaving = false;

  bool get _isEditing => widget.vehiculo != null;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, VehiculosState state) {
    if (state is VehiculosLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Vehículo',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is VehiculosError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Vehículo',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar vehículo' : 'Nuevo vehículo',
        subtitle: _isEditing ? widget.vehiculo!.matricula : null,
        icon: _isEditing ? Icons.edit_outlined : Icons.directions_car_outlined,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          VehiculoFormBody(data: _data, onChanged: () => setState(() {})),
        ],
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      debugPrint('🚗 VehiculoFormDialog: Validación exitosa, creando entidad...');

      // Capacidades
      final int? camillas = _data.camillasValue;
      final int? pasajeros = _data.sentadosValue;

      // Valores por defecto para campos obligatorios
      final String matricula = _data.matricula.text.trim();
      final String tipoVehiculo = _data.tipo.text.trim();
      final String marca = _data.marca.text.trim();
      final String modelo = _data.modelo.text.trim();
      final int anioFabricacion = int.parse(_data.anio.text.trim());

      // Generar número de bastidor temporal si no se proporciona (solo para crear)
      final String numeroBastidor = _data.numeroSerie.text.isNotEmpty
          ? _data.numeroSerie.text.trim()
          : (_isEditing ? widget.vehiculo!.numeroBastidor : 'BASTIDOR-${DateTime.now().millisecondsSinceEpoch}');

      // Obtener usuario autenticado y su empresa_id
      final User? currentUser = Supabase.instance.client.auth.currentUser;
      final String? userId = currentUser?.id;

      // DEBUG: Ver metadata del usuario
      debugPrint('🔐 Usuario actual: ${currentUser?.email}');
      debugPrint('🔐 app_metadata: ${currentUser?.appMetadata}');
      debugPrint('🔐 user_metadata: ${currentUser?.userMetadata}');

      // Obtener empresa_id del usuario autenticado
      String empresaId;
      if (_isEditing) {
        empresaId = widget.vehiculo!.empresaId;
      } else if (currentUser != null) {
        final auth.UserEntity userEntity =
            UserMapper.fromSupabaseUser(currentUser);
        debugPrint('🔐 empresa_id extraído: ${userEntity.empresaId}');
        // Usar empresa_id del usuario o fallback a valor por defecto
        empresaId = userEntity.empresaId ?? '00000000-0000-0000-0000-000000000001';
      } else {
        empresaId = '00000000-0000-0000-0000-000000000001';
      }
      debugPrint('🔐 empresa_id final: $empresaId');

      final VehiculoEntity vehiculo = VehiculoEntity(
        // ID: vacío para crear, existente para editar
        id: widget.vehiculo?.id ?? '',

        // CAMPOS OBLIGATORIOS
        matricula: matricula,
        tipoVehiculo: tipoVehiculo,
        categoria: _isEditing ? widget.vehiculo!.categoria : 'Ambulancia',
        marca: marca,
        modelo: modelo,
        anioFabricacion: anioFabricacion,
        numeroBastidor: numeroBastidor,
        estado: _data.estado,
        empresaId: empresaId,
        proximaItv: _data.fechaProximaItv ?? (_isEditing ? widget.vehiculo!.proximaItv : DateTime.now().add(const Duration(days: 365))),
        fechaVencimientoSeguro: _isEditing ? widget.vehiculo!.fechaVencimientoSeguro : DateTime.now().add(const Duration(days: 365)),
        homologacionSanitaria: _isEditing ? widget.vehiculo!.homologacionSanitaria : 'PENDIENTE',
        fechaVencimientoHomologacion: _isEditing ? widget.vehiculo!.fechaVencimientoHomologacion : DateTime.now().add(const Duration(days: 365)),
        createdAt: widget.vehiculo?.createdAt ?? DateTime.now(),

        // CAMPOS OPCIONALES
        capacidadPasajeros: pasajeros,
        capacidadCamilla: camillas,
        kmActual: _data.kmActualValue,
        fechaAdquisicion: _data.fechaAdquisicion,
        ubicacionActual: _data.ubicacionValue,
        observaciones: _data.observacionesValue,

        // Mantenimiento
        ultimoMantenimiento: _data.fechaUltimoMantenimiento,
        proximoMantenimiento: _data.proximoMantenimiento,
        kmProximoMantenimiento: _data.kmProxMantenimientoValue,

        updatedAt: DateTime.now(),

        // Auditoría
        createdBy: _isEditing ? widget.vehiculo!.createdBy : userId,
        updatedBy: _isEditing ? userId : null,
      );

      debugPrint('🚗 VehiculoFormDialog: ${_isEditing ? "Actualizando" : "Creando"} vehículo - Matrícula: ${vehiculo.matricula}');
      debugPrint('🚗 VehiculoFormDialog: Estado: ${vehiculo.estado}, Marca: ${vehiculo.marca} ${vehiculo.modelo}');
      debugPrint('🚗 VehiculoFormDialog: Número Bastidor: ${vehiculo.numeroBastidor}');
      debugPrint('🚗 VehiculoFormDialog: Created By: ${vehiculo.createdBy}, Updated By: ${vehiculo.updatedBy}');

      // Marcar como guardando
      setState(() {
        _isSaving = true;
      });

      // Mostrar loading overlay
      unawaited(showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando vehículo...' : 'Creando vehículo...',
            color: _isEditing ? AppColors.secondary : AppColors.primary,
            icon: _isEditing ? Icons.edit : Icons.directions_car,
          );
        },
      ));

      // Enviar el evento correcto según el modo
      if (_isEditing) {
        debugPrint('🚗 VehiculoFormDialog: Enviando evento VehiculoUpdateRequested al BLoC...');
        context.read<VehiculosBloc>().add(VehiculoUpdateRequested(vehiculo: vehiculo));
      } else {
        debugPrint('🚗 VehiculoFormDialog: Enviando evento VehiculoCreateRequested al BLoC...');
        context.read<VehiculosBloc>().add(VehiculoCreateRequested(vehiculo: vehiculo));
      }
    } else {
      debugPrint('❌ VehiculoFormDialog: Validación fallida');
    }
  }
}
