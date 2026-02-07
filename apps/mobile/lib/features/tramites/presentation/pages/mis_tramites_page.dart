import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_state.dart';
import '../widgets/tramite_card.dart';

/// Pantalla que muestra todos los trámites del usuario.
/// Combina vacaciones y ausencias en una lista única ordenada por fecha.
class MisTramitesPage extends StatefulWidget {
  const MisTramitesPage({super.key});

  @override
  State<MisTramitesPage> createState() => _MisTramitesPageState();
}

class _MisTramitesPageState extends State<MisTramitesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Mis Trámites'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            tabs: const [
              Tab(
                icon: Icon(Icons.beach_access_rounded),
                text: 'Vacaciones',
              ),
              Tab(
                icon: Icon(Icons.event_busy_rounded),
                text: 'Ausencias',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _VacacionesListView(),
            _AusenciasListView(),
          ],
        ),
      ),
    );
  }
}

/// Vista de lista de vacaciones.
class _VacacionesListView extends StatelessWidget {
  const _VacacionesListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacacionesBloc, VacacionesState>(
      builder: (context, state) {
        if (state is VacacionesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is VacacionesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: AppSizes.iconXLarge,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.spacingMedium),
                  Text(
                    'Error al cargar vacaciones',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is VacacionesLoaded) {
          final vacaciones = state.vacaciones;

          if (vacaciones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.beach_access_outlined,
                      size: AppSizes.iconXLarge * 1.5,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
                    Text(
                      'No hay vacaciones registradas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Solicita tus primeras vacaciones desde la pantalla principal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Agrupar por estado
          final pendientes = state.pendientes;
          final aprobadas = state.aprobadas;
          final rechazadas = state.rechazadas;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
            children: [
              if (pendientes.isNotEmpty) ...[
                _buildSeccionHeader('Pendientes (${pendientes.length})'),
                ...pendientes.map(
                  (v) => TramiteCard(
                    titulo: 'Vacaciones',
                    fechaInicio: v.fechaInicio,
                    fechaFin: v.fechaFin,
                    dias: v.diasSolicitados,
                    estado: v.estado,
                    icono: Icons.beach_access_rounded,
                    colorIcono: AppColors.success,
                    observaciones: v.observaciones,
                    fechaSolicitud: v.fechaSolicitud,
                    solicitadoPor: v.idPersonal,
                    onTap: () {
                      context.push(
                        '/tramites/vacacion/${v.id}',
                        extra: v,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
              ],
              if (aprobadas.isNotEmpty) ...[
                _buildSeccionHeader('Aprobadas (${aprobadas.length})'),
                ...aprobadas.map(
                  (v) => TramiteCard(
                    titulo: 'Vacaciones',
                    fechaInicio: v.fechaInicio,
                    fechaFin: v.fechaFin,
                    dias: v.diasSolicitados,
                    estado: v.estado,
                    icono: Icons.beach_access_rounded,
                    colorIcono: AppColors.success,
                    observaciones: v.observaciones,
                    fechaSolicitud: v.fechaSolicitud,
                    solicitadoPor: v.idPersonal,
                    aprobadoPor: v.aprobadoPor,
                    fechaAprobacion: v.fechaAprobacion,
                    onTap: () {
                      context.push(
                        '/tramites/vacacion/${v.id}',
                        extra: v,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),
              ],
              if (rechazadas.isNotEmpty) ...[
                _buildSeccionHeader('Rechazadas (${rechazadas.length})'),
                ...rechazadas.map(
                  (v) => TramiteCard(
                    titulo: 'Vacaciones',
                    fechaInicio: v.fechaInicio,
                    fechaFin: v.fechaFin,
                    dias: v.diasSolicitados,
                    estado: v.estado,
                    icono: Icons.beach_access_rounded,
                    colorIcono: AppColors.success,
                    observaciones: v.observaciones,
                    fechaSolicitud: v.fechaSolicitud,
                    solicitadoPor: v.idPersonal,
                    aprobadoPor: v.aprobadoPor,
                    fechaAprobacion: v.fechaAprobacion,
                    onTap: () {
                      context.push(
                        '/tramites/vacacion/${v.id}',
                        extra: v,
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSeccionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        bottom: AppSizes.paddingSmall,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.gray700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Vista de lista de ausencias.
class _AusenciasListView extends StatelessWidget {
  const _AusenciasListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AusenciasBloc, AusenciasState>(
      builder: (context, state) {
        if (state is AusenciasLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AusenciasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: AppSizes.iconXLarge,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.spacingMedium),
                  Text(
                    'Error al cargar ausencias',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AusenciasLoaded) {
          final ausencias = state.ausencias;
          final tipos = state.tiposAusencia;

          if (ausencias.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: AppSizes.iconXLarge * 1.5,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(height: AppSizes.spacingMedium),
                    Text(
                      'No hay ausencias registradas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      'Solicita ausencias desde la pantalla principal',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Agrupar por estado
          final pendientes = state.pendientes;
          final aprobadas = state.aprobadas;
          final rechazadas = state.rechazadas;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
            children: [
              if (pendientes.isNotEmpty) ...[
                _buildSeccionHeader('Pendientes (${pendientes.length})'),
                ...pendientes.map((a) {
                  final tipo = tipos.firstWhere(
                    (t) => t.id == a.idTipoAusencia,
                    orElse: () => TipoAusenciaEntity(
                      id: '',
                      nombre: 'Ausencia',
                      requiereAprobacion: true,
                      requiereDocumento: false,
                      color: '#6B7280',
                      activo: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  return TramiteCard(
                    titulo: tipo.nombre,
                    fechaInicio: a.fechaInicio,
                    fechaFin: a.fechaFin,
                    dias: a.diasAusencia,
                    estado: _getEstadoString(a.estado),
                    icono: _getIconoTipo(tipo.nombre),
                    colorIcono: _getColorFromHex(tipo.color),
                    subtitulo: a.motivo,
                    observaciones: a.observaciones,
                    fechaSolicitud: a.createdAt,
                    solicitadoPor: a.idPersonal,
                    isAusencia: true,
                    onTap: () {
                      context.push(
                        '/tramites/ausencia/${a.id}',
                        extra: {
                          'ausencia': a,
                          'tipo': tipo,
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: AppSizes.spacingMedium),
              ],
              if (aprobadas.isNotEmpty) ...[
                _buildSeccionHeader('Aprobadas (${aprobadas.length})'),
                ...aprobadas.map((a) {
                  final tipo = tipos.firstWhere(
                    (t) => t.id == a.idTipoAusencia,
                    orElse: () => TipoAusenciaEntity(
                      id: '',
                      nombre: 'Ausencia',
                      requiereAprobacion: true,
                      requiereDocumento: false,
                      color: '#6B7280',
                      activo: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  return TramiteCard(
                    titulo: tipo.nombre,
                    fechaInicio: a.fechaInicio,
                    fechaFin: a.fechaFin,
                    dias: a.diasAusencia,
                    estado: _getEstadoString(a.estado),
                    icono: _getIconoTipo(tipo.nombre),
                    colorIcono: _getColorFromHex(tipo.color),
                    subtitulo: a.motivo,
                    observaciones: a.observaciones,
                    fechaSolicitud: a.createdAt,
                    solicitadoPor: a.idPersonal,
                    aprobadoPor: a.aprobadoPor,
                    fechaAprobacion: a.fechaAprobacion,
                    isAusencia: true,
                    onTap: () {
                      context.push(
                        '/tramites/ausencia/${a.id}',
                        extra: {
                          'ausencia': a,
                          'tipo': tipo,
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: AppSizes.spacingMedium),
              ],
              if (rechazadas.isNotEmpty) ...[
                _buildSeccionHeader('Rechazadas (${rechazadas.length})'),
                ...rechazadas.map((a) {
                  final tipo = tipos.firstWhere(
                    (t) => t.id == a.idTipoAusencia,
                    orElse: () => TipoAusenciaEntity(
                      id: '',
                      nombre: 'Ausencia',
                      requiereAprobacion: true,
                      requiereDocumento: false,
                      color: '#6B7280',
                      activo: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  return TramiteCard(
                    titulo: tipo.nombre,
                    fechaInicio: a.fechaInicio,
                    fechaFin: a.fechaFin,
                    dias: a.diasAusencia,
                    estado: _getEstadoString(a.estado),
                    icono: _getIconoTipo(tipo.nombre),
                    colorIcono: _getColorFromHex(tipo.color),
                    subtitulo: a.motivo,
                    observaciones: a.observaciones,
                    fechaSolicitud: a.createdAt,
                    solicitadoPor: a.idPersonal,
                    aprobadoPor: a.aprobadoPor,
                    fechaAprobacion: a.fechaAprobacion,
                    isAusencia: true,
                    onTap: () {
                      context.push(
                        '/tramites/ausencia/${a.id}',
                        extra: {
                          'ausencia': a,
                          'tipo': tipo,
                        },
                      );
                    },
                  );
                }),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSeccionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        bottom: AppSizes.paddingSmall,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.gray700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getEstadoString(EstadoAusencia estado) {
    return estado.name;
  }

  IconData _getIconoTipo(String nombre) {
    final nombreLower = nombre.toLowerCase();
    if (nombreLower.contains('médica') || nombreLower.contains('medica')) {
      return Icons.medical_services_rounded;
    } else if (nombreLower.contains('personal')) {
      return Icons.person_outline_rounded;
    } else if (nombreLower.contains('formación') ||
        nombreLower.contains('formacion')) {
      return Icons.school_rounded;
    } else if (nombreLower.contains('compensatorio')) {
      return Icons.event_available_rounded;
    }
    return Icons.event_busy_rounded;
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(
        int.parse(hexColor.replaceFirst('#', '0xFF')),
      );
    } catch (e) {
      return AppColors.gray500;
    }
  }
}
