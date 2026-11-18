import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicio_fechas_excepcion_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Acciones de la barra de herramientas de servicios (diálogos + eventos del BLoC)
abstract final class ServicioAcciones {
  /// Datos del servicio que se muestran en los diálogos de confirmación
  static Map<String, String> _detalles(ServicioEntity s, {bool conEstado = false}) {
    return <String, String>{
      if (s.codigo != null) 'Código': s.codigo!,
      if (s.tipoRecurrencia != null) 'Tipo': s.tipoRecurrencia!,
      if (s.fechaServicioInicio != null)
        'Fecha Inicio': DateFormat('dd/MM/yyyy').format(s.fechaServicioInicio!),
      if (conEstado) 'Estado': s.estado.toUpperCase(),
    };
  }

  /// Abre el wizard de alta/edición y recarga la lista al cerrarlo
  static Future<void> abrirFormulario(BuildContext context, [ServicioEntity? servicio]) async {
    debugPrint(servicio == null
        ? '=== Botón Nuevo Servicio presionado ==='
        : '🖊️ Editar servicio: ${servicio.codigo} (${servicio.id})');
    final ServiciosBloc bloc = context.read<ServiciosBloc>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<ServiciosBloc>.value(
        value: bloc,
        child: ServicioFormWizardDialog(servicio: servicio),
      ),
    );
    bloc.add(const ServiciosEvent.loadRequested());
  }

  static Future<void> eliminar(BuildContext context, ServicioEntity servicio) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar este servicio? Esta acción eliminará todos los trayectos asociados.',
      itemDetails: _detalles(servicio, conEstado: true),
      warningMessage: '⚠️ Esta acción no se puede deshacer',
    );
    if (ok == true && context.mounted) {
      context.read<ServiciosBloc>().add(ServiciosEvent.deleteRequested(id: servicio.id!));
    }
  }

  static Future<void> finalizar(BuildContext context, ServicioEntity servicio) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Finalización',
      message:
          '¿Deseas finalizar este servicio? El servicio se marcará como FINALIZADO y no se generarán más trayectos.',
      itemDetails: _detalles(servicio),
      confirmText: 'Finalizar',
      confirmButtonColor: AppColors.info,
      icon: Icons.done_all,
      iconColor: AppColors.info,
    );
    if (ok == true && context.mounted) {
      context
          .read<ServiciosBloc>()
          .add(ServiciosEvent.updateEstadoRequested(id: servicio.id!, estado: 'FINALIZADO'));
    }
  }

  static Future<void> suspender(BuildContext context, ServicioEntity servicio) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Suspensión',
      message:
          '¿Deseas suspender este servicio? Los trayectos ya generados no se cancelarán, pero no se crearán nuevos trayectos.',
      itemDetails: _detalles(servicio),
      confirmText: 'Suspender',
      confirmButtonColor: AppColors.warning,
      iconColor: AppColors.warning,
    );
    if (ok == true && context.mounted) {
      context
          .read<ServiciosBloc>()
          .add(ServiciosEvent.updateEstadoRequested(id: servicio.id!, estado: 'SUSPENDIDO'));
    }
  }

  static Future<void> reanudar(BuildContext context, ServicioEntity servicio) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Reanudación',
      message: '¿Deseas reanudar este servicio? Se regenerarán los trayectos desde hoy en adelante.',
      itemDetails: _detalles(servicio),
      confirmText: 'Reanudar',
      confirmButtonColor: AppColors.success,
      iconColor: AppColors.success,
    );
    if (ok == true && context.mounted) {
      context.read<ServiciosBloc>().add(ServiciosEvent.reanudarRequested(id: servicio.id!));
    }
  }

  /// Fechas excluidas/incluidas; al cerrar se recargan los detalles (trayectos)
  static Future<void> excluir(BuildContext context, ServicioEntity servicio) async {
    final String? id = servicio.id;
    if (id == null) {
      return;
    }
    debugPrint('🚫 Excepciones de fechas: ${servicio.codigo}');
    final ServiciosBloc bloc = context.read<ServiciosBloc>();
    await showServicioFechasExcepcionDialog(context: context, servicioId: id, codigo: servicio.codigo);
    bloc.add(ServiciosEvent.loadServicioDetailsRequested(id: id));
  }
}
