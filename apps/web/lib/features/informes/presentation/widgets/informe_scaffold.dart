import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_periodo_selector.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_sin_datos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Filtros extra de un informe (se construyen con los datos disponibles)
typedef InformeFiltrosBuilder<T> = List<Widget> Function(
  InformeFiltro filtro,
  T? data,
  ValueChanged<InformeFiltro> onChanged,
);

/// Pantalla estándar de informe: toolbar (Actualizar / Imprimir), barra de
/// filtros con periodo, contenido y barra de estado, dentro de `GestionFrame`.
///
/// El BLoC [B] debe estar disponible en el contexto.
class InformeScaffold<B extends Bloc<InformeEvent, InformeState<T>>, T> extends StatelessWidget {
  const InformeScaffold({
    required this.title,
    required this.icon,
    required this.contentBuilder,
    required this.statusBuilder,
    required this.impresion,
    this.filtrosBuilder,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget Function(T data) contentBuilder;
  final List<String> Function(T data) statusBuilder;

  /// Tabla principal a imprimir
  final InformeImpresion Function(T data) impresion;
  final InformeFiltrosBuilder<T>? filtrosBuilder;

  Future<void> _imprimir(BuildContext context, InformeState<T> state) async {
    final T? data = state.data;
    if (data == null) {
      return;
    }
    final InformeImpresion imp = impresion(data);
    try {
      await GestionPrint.listado(
        title: title,
        subtitle: 'Periodo: ${state.filtro.etiqueta}',
        headers: imp.headers,
        rows: imp.rows,
      );
    } catch (e) {
      debugPrint('❌ InformeScaffold: error al imprimir: $e');
      if (context.mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al imprimir',
          message: 'No se pudo generar el PDF del informe.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<B, InformeState<T>>(
          builder: (BuildContext context, InformeState<T> state) {
            final B bloc = context.read<B>();
            void cambiar(InformeFiltro f) => bloc.add(InformeFiltroChanged(f));
            final bool listo = state.status == InformeStatus.loaded && state.data != null;
            return GestionFrame(
              toolbar: GestionToolbar(
                title: title,
                icon: icon,
                groups: <List<GestionToolbarAction>>[
                  <GestionToolbarAction>[
                    GestionToolbarAction(
                      icon: Icons.refresh,
                      label: 'Actualizar',
                      onPressed: state.isLoading ? null : () => bloc.add(const InformeRefreshRequested()),
                    ),
                    GestionToolbarAction(
                      icon: Icons.print_outlined,
                      label: 'Imprimir',
                      tooltip: 'Imprimir / exportar a PDF la tabla de desglose',
                      onPressed: listo ? () => _imprimir(context, state) : null,
                    ),
                  ],
                ],
              ),
              filterBar: GestionFilterBar(
                children: <Widget>[
                  InformePeriodoSelector(filtro: state.filtro, onChanged: cambiar),
                  ...?filtrosBuilder?.call(state.filtro, state.data, cambiar),
                  if (state.filtro.extras.isNotEmpty)
                    GestionClearFiltersButton(
                      onPressed: () => cambiar(
                        InformeFiltro(
                          periodo: state.filtro.periodo,
                          desde: state.filtro.desde,
                          hasta: state.filtro.hasta,
                        ),
                      ),
                    ),
                ],
              ),
              statusBar: GestionStatusBar(
                items: <String>[
                  'Periodo: ${state.filtro.etiqueta}',
                  if (listo) ...statusBuilder(state.data as T),
                ],
              ),
              content: _InformeContent<T>(
                state: state,
                contentBuilder: contentBuilder,
                onRetry: () => bloc.add(const InformeRefreshRequested()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InformeContent<T> extends StatelessWidget {
  const _InformeContent({
    required this.state,
    required this.contentBuilder,
    required this.onRetry,
  });

  final InformeState<T> state;
  final Widget Function(T data) contentBuilder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == InformeStatus.error) {
      return InformeSinDatos(
        icon: Icons.error_outline,
        color: AppColors.error,
        title: 'No se pudo cargar el informe',
        message: state.message ?? 'Error desconocido',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }
    final T? data = state.data;
    if (state.isLoading || data == null) {
      return const Center(
        child: AppLoadingIndicator(message: 'Calculando informe...', icon: Icons.analytics_outlined),
      );
    }
    return contentBuilder(data);
  }
}
