import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/vestuario_form_dialog.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Tabla de registros de vestuario
class VestuarioTable extends StatefulWidget {
  const VestuarioTable({super.key});

  @override
  State<VestuarioTable> createState() => _VestuarioTableState();
}

class _VestuarioTableState extends State<VestuarioTable> {
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool _isDeleting = false;
  BuildContext? _loadingDialogContext;
  DateTime? _deleteStartTime;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  bool _deleteHandled = false; // Bandera para procesar eliminación solo una vez

  @override
  Widget build(BuildContext context) {
    return BlocListener<VestuarioBloc, VestuarioState>(
      listener: (BuildContext context, VestuarioState state) {
        // Solo procesar si está eliminando y NO ha sido manejado
        if (!_isDeleting || _loadingDialogContext == null || _deleteHandled) {
          return;
        }

        // Marcar como manejado PRIMERO para prevenir re-entrada
        _deleteHandled = true;

        // Solo procesar una vez por eliminación
        if (state is VestuarioLoaded) {
          final Duration elapsed = DateTime.now().difference(_deleteStartTime!);
          final BuildContext savedContext = context; // Capturar contexto

          // Programar el cierre del dialog para el siguiente frame
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Cerrar loading dialog usando el contexto guardado
            if (_loadingDialogContext != null && _loadingDialogContext!.mounted) {
              Navigator.of(_loadingDialogContext!).pop();
            }

            // Resetear estado
            if (mounted) {
              setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteHandled = false;
              });
            }

            // Esperar un frame antes de mostrar el resultado
            await Future<void>.delayed(const Duration(milliseconds: 100));

            // Mostrar resultado
            if (mounted && savedContext.mounted) {
              await showResultDialog(
                context: savedContext,
                title: 'Vestuario Eliminado',
                message: 'El registro de Vestuario ha sido eliminado exitosamente.',
                type: ResultType.success,
                durationMs: elapsed.inMilliseconds,
              );
            }
          });
        } else if (state is VestuarioError) {
          final BuildContext savedContext = context; // Capturar contexto
          final String errorMessage = state.message;

          // Programar el cierre del dialog para el siguiente frame
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Cerrar loading dialog usando el contexto guardado
            if (_loadingDialogContext != null && _loadingDialogContext!.mounted) {
              Navigator.of(_loadingDialogContext!).pop();
            }

            // Resetear estado
            if (mounted) {
              setState(() {
                _isDeleting = false;
                _loadingDialogContext = null;
                _deleteHandled = false;
              });
            }

            // Esperar un frame antes de mostrar el resultado
            await Future<void>.delayed(const Duration(milliseconds: 100));

            // Mostrar resultado
            if (mounted && savedContext.mounted) {
              await showResultDialog(
                context: savedContext,
                title: 'Error al Eliminar',
                message: 'No se pudo eliminar el registro de Vestuario.',
                type: ResultType.error,
                details: errorMessage,
              );
            }
          });
        }
      },
      child: BlocBuilder<VestuarioBloc, VestuarioState>(
        builder: (BuildContext context, VestuarioState state) {
          if (state is VestuarioLoading) {
            return const _LoadingView();
          }

          if (state is VestuarioError) {
            return _ErrorView(message: state.message);
          }

          if (state is VestuarioLoaded) {
            List<VestuarioEntity> filtrados = _filterItems(state.items);
            filtrados = _sortItems(filtrados);

            // Cálculo de paginación
            final int totalItems = filtrados.length;
            final int totalPages = (totalItems / _itemsPerPage).ceil();
            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
            final List<VestuarioEntity> itemsPaginados =
                filtrados.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header con búsqueda
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Listado de Vestuario',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: _SearchField(
                        searchQuery: _searchQuery,
                        onSearchChanged: (String query) {
                          setState(() {
                            _searchQuery = query;
                            _currentPage = 0; // Reset a primera página al buscar
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing),

                // Info filtrado
                if (state.items.length != filtrados.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacing),
                    child: Text(
                      'Mostrando ${filtrados.length} de ${state.items.length} registros',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                // Tabla con AppDataGridV5
                Expanded(
                  child: BlocBuilder<PersonalBloc, PersonalState>(
                    builder: (BuildContext context, PersonalState personalState) {
                      final List<PersonalEntity> personalList =
                          personalState is PersonalLoaded ? personalState.personal : <PersonalEntity>[];

                      return AppDataGridV5<VestuarioEntity>(
                        columns: const <DataGridColumn>[
                          DataGridColumn(label: 'TRABAJADOR', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'PRENDA', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'TALLA', flexWidth: 1, sortable: true),
                          DataGridColumn(label: 'CANTIDAD', flexWidth: 1, sortable: true),
                          DataGridColumn(label: 'FECHA ENTREGA', flexWidth: 2, sortable: true),
                          DataGridColumn(label: 'ESTADO', flexWidth: 1, sortable: true),
                        ],
                        rows: itemsPaginados,
                        buildCells: (VestuarioEntity item) => <DataGridCell>[
                          DataGridCell(child: _buildTrabajadorCell(item, personalList)),
                          DataGridCell(child: _buildPrendaCell(item)),
                          DataGridCell(child: _buildTallaCell(item)),
                          DataGridCell(child: _buildCantidadCell(item)),
                          DataGridCell(child: _buildFechaEntregaCell(item)),
                          DataGridCell(child: _buildEstadoCell(item)),
                        ],
                        onView: (VestuarioEntity item) => _showDetailDialog(context, item, personalList),
                        onEdit: (VestuarioEntity item) => _showFormDialog(context, item: item),
                        onDelete: (VestuarioEntity item) => _confirmDelete(context, item),
                        emptyMessage: _searchQuery.isNotEmpty
                            ? 'No se encontraron registros con los filtros aplicados'
                            : 'No hay registros de vestuario',
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onSort: (int columnIndex, {required bool ascending}) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortAscending = ascending;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Paginación
                const SizedBox(height: AppSizes.spacing),
                _buildPaginationControls(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  totalItems: totalItems,
                  onPageChanged: (int page) => setState(() => _currentPage = page),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Construye controles de paginación profesional
  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required void Function(int) onPageChanged,
  }) {
    final int startItem = totalItems == 0 ? 0 : currentPage * _itemsPerPage + 1;
    final int endItem = totalItems == 0
        ? 0
        : ((currentPage + 1) * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Info de elementos mostrados
          Text(
            'Mostrando $startItem-$endItem de $totalItems items',
            style: AppTextStyles.bodySmallSecondary,
          ),

          // Controles de navegación
          Row(
            children: <Widget>[
              // Primera página
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: Icons.first_page,
                tooltip: 'Primera página',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Página anterior
              _PaginationButton(
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                icon: Icons.chevron_left,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: AppSizes.spacing),

              // Indicador de página actual (badge azul)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  'Página ${currentPage + 1} de ${totalPages > 0 ? totalPages : 1}',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing),

              // Página siguiente
              _PaginationButton(
                onPressed:
                    currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                icon: Icons.chevron_right,
                tooltip: 'Página siguiente',
              ),
              const SizedBox(width: AppSizes.spacingSmall),

              // Última página
              _PaginationButton(
                onPressed:
                    currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                icon: Icons.last_page,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<VestuarioEntity> _filterItems(List<VestuarioEntity> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }

    final String query = _searchQuery.toLowerCase();

    return items.where((VestuarioEntity item) {
      return item.prenda.toLowerCase().contains(query) ||
          item.talla.toLowerCase().contains(query) ||
          (item.marca?.toLowerCase().contains(query) ?? false) ||
          (item.color?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<VestuarioEntity> _sortItems(List<VestuarioEntity> items) {
    final List<VestuarioEntity> sorted = List<VestuarioEntity>.from(items)
      ..sort((VestuarioEntity a, VestuarioEntity b) {
      int compare = 0;

      switch (_sortColumnIndex) {
        case 0: // TRABAJADOR - ordena por personalId
          compare = a.personalId.compareTo(b.personalId);
        case 1: // PRENDA
          compare = a.prenda.compareTo(b.prenda);
        case 2: // TALLA
          compare = a.talla.compareTo(b.talla);
        case 3: // CANTIDAD
          compare = (a.cantidad ?? 0).compareTo(b.cantidad ?? 0);
        case 4: // FECHA ENTREGA
          compare = a.fechaEntrega.compareTo(b.fechaEntrega);
        case 5: // ESTADO
          compare = (a.estado ?? '').compareTo(b.estado ?? '');
      }

      return _sortAscending ? compare : -compare;
    });
    return sorted;
  }

  /// Obtiene el nombre del trabajador por ID
  String _getTrabajadorNombre(String personalId, List<PersonalEntity> personalList) {
    try {
      final PersonalEntity personal = personalList.firstWhere(
        (PersonalEntity p) => p.id == personalId,
      );
      return personal.nombreCompleto;
    } catch (e) {
      return 'Desconocido';
    }
  }

  Widget _buildTrabajadorCell(VestuarioEntity item, List<PersonalEntity> personalList) {
    final String nombreTrabajador = _getTrabajadorNombre(item.personalId, personalList);
    return Text(
      nombreTrabajador,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildPrendaCell(VestuarioEntity item) {
    return Text(
      item.prenda,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildTallaCell(VestuarioEntity item) {
    return Text(
      item.talla,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryLight),
    );
  }

  Widget _buildCantidadCell(VestuarioEntity item) {
    return Text(
      '${item.cantidad ?? 1}',
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryLight),
    );
  }

  Widget _buildFechaEntregaCell(VestuarioEntity item) {
    final String fecha = DateFormat('dd/MM/yyyy').format(item.fechaEntrega);
    return Text(
      fecha,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryLight),
    );
  }

  Widget _buildEstadoCell(VestuarioEntity item) {
    final bool asignado = item.estaAsignado;
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: asignado
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.gray300.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            asignado ? 'Asignado' : 'Devuelto',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: asignado ? AppColors.success : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra diálogo de detalles del vestuario
  Future<void> _showDetailDialog(
    BuildContext context,
    VestuarioEntity item,
    List<PersonalEntity> personalList,
  ) async {
    final String nombreTrabajador = _getTrabajadorNombre(item.personalId, personalList);

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checkroom, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detalles del Vestuario',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildDetailRow('Trabajador', nombreTrabajador),
                _buildDetailRow('Prenda', item.prenda),
                _buildDetailRow('Talla', item.talla),
                _buildDetailRow('Cantidad', '${item.cantidad ?? 1}'),
                if (item.marca != null && item.marca!.isNotEmpty)
                  _buildDetailRow('Marca', item.marca!),
                if (item.color != null && item.color!.isNotEmpty)
                  _buildDetailRow('Color', item.color!),
                _buildDetailRow(
                  'Fecha de Entrega',
                  DateFormat('dd/MM/yyyy').format(item.fechaEntrega),
                ),
                if (item.fechaDevolucion != null)
                  _buildDetailRow(
                    'Fecha de Devolución',
                    DateFormat('dd/MM/yyyy').format(item.fechaDevolucion!),
                  ),
                _buildDetailRow(
                  'Estado',
                  item.estaAsignado ? 'Asignado' : 'Devuelto',
                  valueColor: item.estaAsignado ? AppColors.success : AppColors.gray600,
                ),
                if (item.observaciones != null && item.observaciones!.isNotEmpty)
                  _buildDetailRow('Observaciones', item.observaciones!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  /// Widget para mostrar una fila de detalle
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFormDialog(BuildContext context, {VestuarioEntity? item}) async {
    // Capturar los BLoCs del contexto actual ANTES de showDialog
    final VestuarioBloc vestuarioBloc = context.read<VestuarioBloc>();
    final PersonalBloc personalBloc = context.read<PersonalBloc>();
    final StockVestuarioBloc stockVestuarioBloc = context.read<StockVestuarioBloc>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<VestuarioBloc>.value(value: vestuarioBloc),
            BlocProvider<PersonalBloc>.value(value: personalBloc),
            BlocProvider<StockVestuarioBloc>.value(value: stockVestuarioBloc),
          ],
          child: VestuarioFormDialog(item: item),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, VestuarioEntity item) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar este registro de vestuario? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Prenda': item.prenda,
        'Talla': item.talla,
        if (item.marca != null && item.marca!.isNotEmpty) 'Marca': item.marca!,
        if (item.color != null && item.color!.isNotEmpty) 'Color': item.color!,
        'Cantidad': '${item.cantidad ?? 1}',
        'Fecha Entrega': DateFormat('dd/MM/yyyy').format(item.fechaEntrega),
        'Estado': item.estaAsignado ? 'Asignado' : 'Devuelto',
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando vestuario: ${item.prenda} (${item.id})');

      BuildContext? loadingContext;

      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            loadingContext = dialogContext;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && loadingContext != null) {
                setState(() {
                  _isDeleting = true;
                  _loadingDialogContext = loadingContext;
                  _deleteStartTime = DateTime.now();
                  _deleteHandled = false; // Resetear al iniciar nueva eliminación
                });
              }
            });

            return const AppLoadingOverlay(
              message: 'Eliminando vestuario...',
              color: AppColors.emergency,
              icon: Icons.delete_forever,
            );
          },
        ),
      );

      if (context.mounted) {
        // Solo devolver al stock si el vestuario está asignado
        if (item.estaAsignado) {
          // Buscar el stock correspondiente para devolverlo
          final StockVestuarioState stockState = context.read<StockVestuarioBloc>().state;

          if (stockState is StockVestuarioLoaded) {
            // Buscar el stock que coincida con prenda, talla, marca y color
            StockVestuarioEntity? stock;
            try {
              stock = stockState.items.firstWhere(
                (StockVestuarioEntity s) =>
                    s.prenda == item.prenda &&
                    s.talla == item.talla &&
                    s.marca == item.marca &&
                    s.color == item.color,
              );
            } catch (e) {
              stock = null;
            }

            if (stock != null) {
              // Devolver stock (decrementar cantidad asignada, incrementar disponible)
              debugPrint('📦 Devolviendo al stock: ${item.prenda} (${item.talla}) - Cantidad: ${item.cantidad ?? 1}');
              debugPrint('   Stock ID: ${stock.id}');
              debugPrint('   Antes - Asignada: ${stock.cantidadAsignada}, Disponible: ${stock.cantidadDisponible}');

              context.read<StockVestuarioBloc>().add(
                    StockVestuarioDecrementarAsignadaRequested(
                      stock.id, // ID del stock
                      item.cantidad ?? 1,
                    ),
                  );
            } else {
              debugPrint('⚠️ No se encontró stock para devolver: ${item.prenda} ${item.talla}');
              debugPrint('   Marca buscada: ${item.marca}');
              debugPrint('   Color buscado: ${item.color}');
              debugPrint('   Stocks disponibles:');
              for (final StockVestuarioEntity s in stockState.items) {
                debugPrint('   - ${s.prenda} ${s.talla} ${s.marca} ${s.color}');
              }
            }
          } else {
            debugPrint('⚠️ Stock no está cargado (estado: $stockState)');
          }
        } else {
          debugPrint('ℹ️ Vestuario ya estaba devuelto, no se incrementa stock');
        }

        // Eliminar el registro de vestuario
        context.read<VestuarioBloc>().add(VestuarioDeleteRequested(item.id));
      }
    }
  }
}

/// Botón de paginación reutilizable
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: onPressed != null
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray300,
            ),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSmall,
            color: onPressed != null ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}

/// Campo de búsqueda
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final String searchQuery;
  final void Function(String) onSearchChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar vestuario...',
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondaryLight),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondaryLight),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        isDense: true,
      ),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando vestuario...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar vestuario',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
