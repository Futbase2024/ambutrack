import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../../data/repositories/traslados_repository_impl.dart';
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_event.dart';
import '../bloc/traslados_state.dart';
import '../widgets/traslado_card.dart';

/// Página de histórico de servicios/traslados
class ServiciosHistoricoPage extends StatelessWidget {
  const ServiciosHistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = TrasladosRepositoryImpl();
        final bloc = TrasladosBloc(repository);

        // Obtener ID del conductor desde AuthBloc
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.personal != null) {
          final idConductor = authState.personal!.id;
          // Cargar traslados históricos (sin realtime)
          bloc.add(IniciarStreamEventos(idConductor));
        }

        return bloc;
      },
      child: const _ServiciosHistoricoPageContent(),
    );
  }
}

class _ServiciosHistoricoPageContent extends StatefulWidget {
  const _ServiciosHistoricoPageContent();

  @override
  State<_ServiciosHistoricoPageContent> createState() =>
      _ServiciosHistoricoPageContentState();
}

class _ServiciosHistoricoPageContentState
    extends State<_ServiciosHistoricoPageContent> {
  EstadoTraslado? _filtroEstado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    // Por defecto: últimos 30 días
    final ahora = DateTime.now();
    _fechaFin = DateTime(ahora.year, ahora.month, ahora.day);
    _fechaInicio = _fechaFin!.subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Histórico de Servicios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con contador y filtros de fecha
            _buildHeader(context),

            // Filtros por estado
            _buildFiltrosEstado(),

            // Lista de traslados
            Expanded(
              child: BlocBuilder<TrasladosBloc, TrasladosState>(
                builder: (context, state) {
                  if (state is TrasladosLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TrasladosLoaded) {
                    final traslados = _filtrarTraslados(state.traslados);

                    if (traslados.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<TrasladosBloc>()
                            .add(const RefrescarTraslados());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: traslados.length,
                        itemBuilder: (context, index) {
                          final traslado = traslados[index];
                          return TrasladoCard(
                            traslado: traslado,
                            onTap: () {
                              context.push('/servicios/${traslado.id}');
                            },
                          );
                        },
                      ),
                    );
                  }

                  // Estado inicial
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contador de resultados
          Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Título y contador
              Expanded(
                child: BlocBuilder<TrasladosBloc, TrasladosState>(
                  builder: (context, state) {
                    int total = 0;

                    if (state is TrasladosLoaded) {
                      total = _filtrarTraslados(state.traslados).length;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Histórico',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$total servicios encontrados',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Botón de actualizar
              IconButton(
                onPressed: () {
                  context.read<TrasladosBloc>().add(const RefrescarTraslados());
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Filtros de fecha
          Row(
            children: [
              // Fecha inicio
              Expanded(
                child: _buildFechaSelector(
                  context: context,
                  label: 'Desde',
                  fecha: _fechaInicio,
                  onChanged: (fecha) {
                    setState(() {
                      _fechaInicio = fecha;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Fecha fin
              Expanded(
                child: _buildFechaSelector(
                  context: context,
                  label: 'Hasta',
                  fecha: _fechaFin,
                  onChanged: (fecha) {
                    setState(() {
                      _fechaFin = fecha;
                    });
                  },
                ),
              ),
            ],
          ),

          // Accesos rápidos
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickFilterChip(
                label: 'Últimos 7 días',
                onTap: () {
                  final ahora = DateTime.now();
                  setState(() {
                    _fechaFin = DateTime(ahora.year, ahora.month, ahora.day);
                    _fechaInicio = _fechaFin!.subtract(const Duration(days: 7));
                  });
                },
              ),
              _buildQuickFilterChip(
                label: 'Últimos 30 días',
                onTap: () {
                  final ahora = DateTime.now();
                  setState(() {
                    _fechaFin = DateTime(ahora.year, ahora.month, ahora.day);
                    _fechaInicio = _fechaFin!.subtract(const Duration(days: 30));
                  });
                },
              ),
              _buildQuickFilterChip(
                label: 'Último mes',
                onTap: () {
                  final ahora = DateTime.now();
                  setState(() {
                    _fechaFin = DateTime(ahora.year, ahora.month, ahora.day);
                    _fechaInicio = DateTime(ahora.year, ahora.month - 1, ahora.day);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFechaSelector({
    required BuildContext context,
    required String label,
    required DateTime? fecha,
    required Function(DateTime) onChanged,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'ES'),
        );

        if (pickedDate != null) {
          onChanged(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fecha != null ? dateFormat.format(fecha) : '--/--/----',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltrosEstado() {
    final estadosFiltro = EstadoTraslado.values;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Filtro "Todos"
          _buildFiltroChip(
            label: 'TODOS',
            isSelected: _filtroEstado == null,
            onTap: () {
              setState(() {
                _filtroEstado = null;
              });
            },
          ),
          const SizedBox(width: 8),

          // Filtros por estado
          ...estadosFiltro.map((estado) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFiltroChip(
                label: estado.label,
                isSelected: _filtroEstado == estado,
                onTap: () {
                  setState(() {
                    _filtroEstado = estado;
                  });
                },
                color: _getColorFromHex(estado.colorHex),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFiltroChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : effectiveColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : effectiveColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay servicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _filtroEstado == null
                  ? 'No se encontraron servicios en el rango de fechas seleccionado'
                  : 'No hay servicios con estado: ${_filtroEstado!.label}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<TrasladoEntity> _filtrarTraslados(List<TrasladoEntity> traslados) {
    var trasladosFiltrados = traslados;

    // 1. Filtrar por rango de fechas
    if (_fechaInicio != null && _fechaFin != null) {
      trasladosFiltrados = trasladosFiltrados.where((t) {
        if (t.fecha == null) return false;
        final fechaTraslado = DateTime(
          t.fecha!.year,
          t.fecha!.month,
          t.fecha!.day,
        );
        final inicio = DateTime(
          _fechaInicio!.year,
          _fechaInicio!.month,
          _fechaInicio!.day,
        );
        final fin = DateTime(
          _fechaFin!.year,
          _fechaFin!.month,
          _fechaFin!.day,
        );

        return (fechaTraslado.isAtSameMomentAs(inicio) ||
                fechaTraslado.isAfter(inicio)) &&
            (fechaTraslado.isAtSameMomentAs(fin) ||
                fechaTraslado.isBefore(fin));
      }).toList();
    }

    // 2. Aplicar filtro por estado si está seleccionado
    if (_filtroEstado != null) {
      trasladosFiltrados = trasladosFiltrados
          .where((t) {
            final estadoActual = EstadoTraslado.fromValue(t.estado);
            return estadoActual == _filtroEstado;
          })
          .toList();
    }

    // 3. Ordenar por fecha + hora (descendente: más reciente primero)
    trasladosFiltrados.sort((a, b) {
      // Primero comparar por fecha
      if (a.fecha == null && b.fecha == null) return 0;
      if (a.fecha == null) return 1;
      if (b.fecha == null) return -1;
      final dateCompare = b.fecha!.compareTo(a.fecha!);
      if (dateCompare != 0) return dateCompare;

      // Si la fecha es igual, comparar por hora
      if (a.horaProgramada == null && b.horaProgramada == null) return 0;
      if (a.horaProgramada == null) return 1;
      if (b.horaProgramada == null) return -1;
      return b.horaProgramada!.compareTo(a.horaProgramada!);
    });

    return trasladosFiltrados;
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
