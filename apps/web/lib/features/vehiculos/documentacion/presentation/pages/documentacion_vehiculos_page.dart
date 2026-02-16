import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_card.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_detail_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_filters.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/documentacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de Documentación de Vehículos
class DocumentacionVehiculosPage extends StatefulWidget {
  const DocumentacionVehiculosPage({super.key, this.vehiculoId});

  final String? vehiculoId;

  @override
  State<DocumentacionVehiculosPage> createState() =>
      _DocumentacionVehiculosPageState();
}

class _DocumentacionVehiculosPageState extends State<DocumentacionVehiculosPage> {
  DocumentacionFilters _filters = const DocumentacionFilters();

  Future<void> _showFormDialog(BuildContext context, {DocumentacionVehiculoEntity? documento}) async {
    final DocumentacionVehiculoEntity? result = await showDialog<DocumentacionVehiculoEntity>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => DocumentacionFormDialog(
        documento: documento,
        vehiculoId: widget.vehiculoId ?? '',
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (documento == null) {
      context.read<DocumentacionVehiculosBloc>().add(
        DocumentacionVehiculoCreateRequested(result),
      );
    } else {
      context.read<DocumentacionVehiculosBloc>().add(
        DocumentacionVehiculoUpdateRequested(result),
      );
    }
  }

  void _showDetailDialog(BuildContext context, DocumentacionVehiculoEntity documento) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => DocumentacionDetailDialog(
        documento: documento,
      ),
    );
  }

  void _handleEdit(BuildContext context, DocumentacionVehiculoEntity documento) {
    _showFormDialog(context, documento: documento);
  }

  void _handleRenovar(BuildContext context, DocumentacionVehiculoEntity documento) {
    context.read<DocumentacionVehiculosBloc>().add(
      DocumentacionVehiculoActualizarEstadoRequested(documento.id),
    );
  }

  Future<void> _handleDelete(BuildContext context, DocumentacionVehiculoEntity documento) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar Documento',
      message: '¿Estás seguro de que deseas eliminar este documento?\n\nNúmero: ${documento.numeroPoliza}\nCompañía: ${documento.compania}',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );

    if (confirmed == true && mounted) {
      context.read<DocumentacionVehiculosBloc>().add(
        DocumentacionVehiculoDeleteRequested(documento.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocProvider<DocumentacionVehiculosBloc>(
          create: (_) => getIt<DocumentacionVehiculosBloc>()
            ..add(const DocumentacionVehiculosLoadRequested()),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingLarge,
            ),
            child: _DocumentacionVehiculosView(
              filters: _filters,
              onFiltersChanged: (DocumentacionFilters newFilters) {
                setState(() {
                  _filters = newFilters;
                });
              },
              onShowForm: (DocumentacionVehiculoEntity? documento) {
                _showFormDialog(context, documento: documento);
              },
              onShowDetail: (DocumentacionVehiculoEntity documento) {
                _showDetailDialog(context, documento);
              },
              onEdit: (DocumentacionVehiculoEntity documento) {
                _handleEdit(context, documento);
              },
              onRenovar: (DocumentacionVehiculoEntity documento) {
                _handleRenovar(context, documento);
              },
              onDelete: (DocumentacionVehiculoEntity documento) {
                _handleDelete(context, documento);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentacionVehiculosView extends StatelessWidget {
  const _DocumentacionVehiculosView({
    required this.filters,
    required this.onFiltersChanged,
    required this.onShowForm,
    required this.onShowDetail,
    required this.onEdit,
    required this.onRenovar,
    required this.onDelete,
  });

  final DocumentacionFilters filters;
  final ValueChanged<DocumentacionFilters> onFiltersChanged;
  final void Function(DocumentacionVehiculoEntity?) onShowForm;
  final void Function(DocumentacionVehiculoEntity) onShowDetail;
  final void Function(DocumentacionVehiculoEntity) onEdit;
  final void Function(DocumentacionVehiculoEntity) onRenovar;
  final void Function(DocumentacionVehiculoEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentacionVehiculosBloc,
      DocumentacionVehiculosState>(
      builder: (BuildContext context, DocumentacionVehiculosState state) {
        if (state is DocumentacionVehiculosLoading ||
            state is DocumentacionVehiculosInitial) {
          return const _LoadingView();
        } else if (state is DocumentacionVehiculosLoaded) {
          return _buildLoadedContent(
            context: context,
            documentos: state.documentos,
            isRefreshing: state.isRefreshing,
          );
        } else if (state is DocumentacionVehiculosError) {
          return _ErrorView(
            message: state.message,
            onRetry: () {
              context.read<DocumentacionVehiculosBloc>().add(
                const DocumentacionVehiculosLoadRequested(),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadedContent({
    required BuildContext context,
    required List<DocumentacionVehiculoEntity> documentos,
    required bool isRefreshing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageHeader(
          config: PageHeaderConfig(
            icon: Icons.description_outlined,
            title: 'Documentación de Vehículos',
            subtitle: 'Gestión de documentos y vencimientos',
            stats: _buildHeaderStats(documentos),
            addButtonLabel: 'Nuevo Documento',
            onAdd: () => onShowForm(null),
          ),
        ),
        const SizedBox(height: AppSizes.spacingXl),
        DocumentacionFiltersWidget(
          filters: filters,
          onFiltersChanged: onFiltersChanged,
        ),
        const SizedBox(height: AppSizes.spacing),
        Expanded(
          child: documentos.isEmpty
              ? _EmptyView(onShowForm: onShowForm)
              : _LoadedView(
                  documentos: documentos,
                  isRefreshing: isRefreshing,
                  onShowDetail: onShowDetail,
                  onEdit: onEdit,
                  onRenovar: onRenovar,
                  onDelete: onDelete,
                ),
        ),
      ],
    );
  }

  List<HeaderStat> _buildHeaderStats(List<DocumentacionVehiculoEntity> documentos) {
    final int total = documentos.length;
    final int vigentes = documentos
        .where((DocumentacionVehiculoEntity d) => d.estado == 'vigente')
        .length;
    final int proximosVencer = documentos
        .where((DocumentacionVehiculoEntity d) => d.estado == 'proxima_vencer')
        .length;
    final int vencidos = documentos
        .where((DocumentacionVehiculoEntity d) => d.estado == 'vencida')
        .length;

    return <HeaderStat>[
      HeaderStat(
        value: '$total',
        icon: Icons.description,
        color: AppColors.primary,
      ),
      HeaderStat(
        value: '$vigentes',
        icon: Icons.check_circle,
        color: AppColors.primary,
      ),
      HeaderStat(
        value: '$proximosVencer',
        icon: Icons.warning,
        color: AppColors.primary,
      ),
      HeaderStat(
        value: '$vencidos',
        icon: Icons.error,
        color: AppColors.primary,
      ),
    ];
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onShowForm});

  final void Function(DocumentacionVehiculoEntity?) onShowForm;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'No hay documentos registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Haz clic en el botón Nuevo Documento para agregar uno',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar los documentos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.documentos,
    required this.isRefreshing,
    required this.onShowDetail,
    required this.onEdit,
    required this.onRenovar,
    required this.onDelete,
  });

  final List<DocumentacionVehiculoEntity> documentos;
  final bool isRefreshing;
  final void Function(DocumentacionVehiculoEntity) onShowDetail;
  final void Function(DocumentacionVehiculoEntity) onEdit;
  final void Function(DocumentacionVehiculoEntity) onRenovar;
  final void Function(DocumentacionVehiculoEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO(jps): Implementar refresh
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        itemCount: documentos.length,
        itemBuilder: (BuildContext context, int index) {
          final DocumentacionVehiculoEntity documento = documentos[index];
          return DocumentacionCard(
            documento: documento,
            onTap: () => onShowDetail(documento),
            onEdit: () => onEdit(documento),
            onRenovar: () => onRenovar(documento),
            onDelete: () => onDelete(documento),
          );
        },
      ),
    );
  }
}
