import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_cubit.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitud_entregar_dialog.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitud_vestuario_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones de la pantalla de solicitudes: aprobar, rechazar, entregar y ver foto
mixin SolicitudesVestuarioAcciones<T extends StatefulWidget> on State<T> {
  SolicitudesVestuarioCubit get _cubit => context.read<SolicitudesVestuarioCubit>();

  String _descripcion(SolicitudVestuarioEntity s) =>
      '${s.cantidad} × ${s.prenda} (talla ${GestionFormatters.texto(s.talla)}) '
      'de ${GestionFormatters.texto(s.personalNombre)}';

  /// Confirma y aprueba una solicitud pendiente
  Future<void> aprobarSolicitud(SolicitudVestuarioEntity s) async {
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Aprobar solicitud',
      message: '¿Aprobar la solicitud de ${_descripcion(s)}?',
      confirmText: 'Aprobar',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.info,
      confirmButtonColor: AppColors.info,
    );
    if (ok == true && mounted) {
      await _cubit.aprobar(s);
    }
  }

  /// Pide motivo, confirma y rechaza una solicitud abierta
  Future<void> rechazarSolicitud(SolicitudVestuarioEntity s) async {
    final String? motivo =
        await pedirMotivoRechazoSolicitud(context, trabajador: GestionFormatters.texto(s.personalNombre));
    if (motivo == null || !mounted) {
      return;
    }
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Rechazar solicitud',
      message: '¿Rechazar la solicitud de ${_descripcion(s)}?\n\nMotivo: $motivo',
      confirmText: 'Rechazar',
      icon: Icons.cancel_outlined,
    );
    if (ok == true && mounted) {
      await _cubit.rechazar(s, motivo: motivo);
    }
  }

  /// Elige stock y destino de la prenda antigua, confirma y entrega
  Future<void> entregarSolicitud(SolicitudVestuarioEntity s) async {
    final EntregaSolicitudVestuario? datos =
        await pedirDatosEntrega(context, solicitud: s, stock: _cubit.state.stock);
    if (datos == null || !mounted) {
      return;
    }
    final StockVestuarioEntity? st = datos.stock;
    final String origen = st == null ? '' : '\n\nSe entrega desde el almacén: talla ${st.talla}.';
    final String antigua = datos.devolverAStock == null
        ? ''
        : '\nLa prenda antigua ${datos.devolverAStock! ? 'vuelve al almacén' : 'se da de baja'}.';
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: s.tipo.entregaPrenda ? 'Entregar prenda' : 'Registrar devolución',
      message: '¿Confirmar la ${s.tipo.entregaPrenda ? 'entrega' : 'devolución'} de ${_descripcion(s)}?$origen$antigua',
      confirmText: s.tipo.entregaPrenda ? 'Entregar' : 'Registrar',
      icon: Icons.local_shipping_outlined,
      iconColor: AppColors.success,
      confirmButtonColor: AppColors.success,
    );
    if (ok == true && mounted) {
      await _cubit.entregar(s, stockId: st?.id, devolverAStock: datos.devolverAStock);
    }
  }

  /// Muestra la foto adjunta en un diálogo
  Future<void> verFotoSolicitud(SolicitudVestuarioEntity s) {
    final String? ruta = s.fotoUrl;
    if (ruta == null || ruta.isEmpty) {
      return Future<void>.value();
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => SolicitudFotoDialog(
        url: _cubit.urlFoto(ruta),
        titulo: '${s.prenda} · ${GestionFormatters.texto(s.personalNombre)}',
      ),
    );
  }

  /// Muestra el resultado de la última acción de gestión
  void mostrarResultadoSolicitud(SolicitudVestuarioResultado r) {
    final bool devolucion = r.tipo == TipoSolicitudVestuario.devolucion;
    final (String titulo, String mensaje, String fallo) = switch (r.accion) {
      AccionSolicitudVestuario.aprobar => (
          'Solicitud aprobada',
          'La solicitud se ha aprobado. El trabajador recibirá una notificación.',
          'No se pudo aprobar la solicitud.',
        ),
      AccionSolicitudVestuario.rechazar => (
          'Solicitud rechazada',
          'La solicitud se ha rechazado. El trabajador recibirá una notificación con el motivo.',
          'No se pudo rechazar la solicitud.',
        ),
      AccionSolicitudVestuario.entregar => (
          devolucion ? 'Devolución registrada' : 'Prenda entregada',
          devolucion
              ? 'Se ha registrado la devolución y actualizado el stock.'
              : 'Se ha entregado la prenda, actualizado el stock y el vestuario del trabajador.',
          devolucion ? 'No se pudo registrar la devolución.' : 'No se pudo entregar la prenda.',
        ),
    };
    showResultDialog(
      context: context,
      title: r.ok ? titulo : 'Error en la solicitud',
      message: r.ok ? mensaje : fallo,
      details: r.error,
      type: r.ok ? ResultType.success : ResultType.error,
    );
  }
}
