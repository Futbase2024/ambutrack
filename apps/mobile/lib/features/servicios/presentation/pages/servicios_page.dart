import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../../data/repositories/traslados_repository_impl.dart';
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_event.dart';
import '../bloc/traslados_state.dart';
import '../widgets/traslado_card.dart';

/// Página principal de servicios/traslados
class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

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
          // Iniciar Event Ledger: Realtime sin polling
          bloc.add(IniciarStreamEventos(idConductor));
        }

        return bloc;
      },
      child: const _ServiciosPageContent(),
    );
  }
}

class _ServiciosPageContent extends StatefulWidget {
  const _ServiciosPageContent();

  @override
  State<_ServiciosPageContent> createState() => _ServiciosPageContentState();
}

class _ServiciosPageContentState extends State<_ServiciosPageContent> {
  EstadoTraslado? _filtroEstado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Mis Servicios'),
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
            // Header con contador
            _buildHeader(context),

            // Filtros por estado
            _buildFiltrosEstado(),

            // Lista de traslados
            Expanded(
              child: BlocConsumer<TrasladosBloc, TrasladosState>(
                listener: (context, state) {
                  if (state is TrasladosError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } else if (state is EstadoCambiadoSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Estado cambiado a: ${state.traslado.estado.label}',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
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
                        context.read<TrasladosBloc>().add(const RefrescarTraslados());
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
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
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
                int activos = 0;

                if (state is TrasladosLoaded) {
                  total = state.traslados.length;
                  activos = state.traslados
                      .where((t) => t.estado.isActivo)
                      .length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Servicios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activos activos de $total totales',
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
    );
  }

  Widget _buildFiltrosEstado() {
    final estadosFiltro = [
      EstadoTraslado.recibido,
      EstadoTraslado.enOrigen,
      EstadoTraslado.saliendoOrigen,
      EstadoTraslado.enDestino,
    ];

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
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay traslados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filtroEstado == null
                ? 'Todos tus traslados aparecerán aquí'
                : 'No hay traslados con estado: ${_filtroEstado!.label}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<TrasladoEntity> _filtrarTraslados(List<TrasladoEntity> traslados) {
    if (_filtroEstado == null) {
      return traslados;
    }
    return traslados.where((t) => t.estado == _filtroEstado).toList();
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
