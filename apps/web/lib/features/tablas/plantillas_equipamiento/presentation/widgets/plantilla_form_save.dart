import 'dart:async';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Guardado común de los formularios de plantillas: overlay + evento + resultado
mixin PlantillaFormSave<T extends StatefulWidget> on State<T> {
  bool isSaving = false;

  /// Nombre de la entidad para los diálogos de resultado
  String get entityName;

  /// true = edición, false = alta
  bool get isEditing;

  /// Solo reaccionar a escrituras terminadas
  bool listenWhen(PlantillasEquipamientoState a, PlantillasEquipamientoState b) => a.operacion != b.operacion;

  void onBlocState(BuildContext context, PlantillasEquipamientoState state) {
    if (!isSaving) {
      return;
    }
    if (state.resultado == PlantillasResultado.exito) {
      unawaited(CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: isSaving,
        isEditing: isEditing,
        entityName: entityName,
        onClose: _reset,
      ));
    } else if (state.resultado == PlantillasResultado.error) {
      unawaited(CrudOperationHandler.handleError(
        context: context,
        isSaving: isSaving,
        isEditing: isEditing,
        entityName: entityName,
        errorMessage: state.error ?? 'Error desconocido',
        onClose: _reset,
      ));
    }
  }

  /// Muestra el overlay de carga y lanza el evento de guardado
  void guardar(PlantillasEquipamientoEvent event) {
    setState(() => isSaving = true);
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => AppLoadingOverlay(
        message: isEditing ? 'Actualizando ${entityName.toLowerCase()}...' : 'Creando ${entityName.toLowerCase()}...',
        color: isEditing ? AppColors.secondary : AppColors.primary,
        icon: isEditing ? Icons.edit : Icons.add_circle_outline,
      ),
    ));
    context.read<PlantillasEquipamientoBloc>().add(event);
  }

  void _reset() {
    if (mounted) {
      setState(() => isSaving = false);
    }
  }
}
