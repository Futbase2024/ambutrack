import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/app_skeleton.dart';
import '../../../servicios/presentation/bloc/traslados_bloc.dart';
import '../../../servicios/presentation/bloc/traslados_event.dart';
import '../../../servicios/presentation/bloc/traslados_state.dart';
import '../../../servicios/presentation/widgets/estado_traslado_badge.dart';

/// Tarjeta con el próximo servicio asignado al técnico
class HomeProximoServicio extends StatelessWidget {
  const HomeProximoServicio({super.key, required this.idConductor});

  final String idConductor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrasladosBloc>(
      create: (_) => getIt<TrasladosBloc>()..add(CargarTrasladosActivos(idConductor)),
      child: BlocBuilder<TrasladosBloc, TrasladosState>(
        builder: (context, state) {
          if (state is TrasladosLoaded) {
            final List<TrasladoEntity> pendientes = _ordenar(state.traslados);
            if (pendientes.isEmpty) {
              return const _SinServicios();
            }
            return _ServicioCard(traslado: pendientes.first, restantes: pendientes.length - 1);
          }
          if (state is TrasladosError) {
            return const _SinServicios(mensaje: 'No se pudieron cargar los servicios');
          }
          return const _ServicioSkeleton();
        },
      ),
    );
  }

  /// Estados en los que la ambulancia ya está realizando el servicio
  static const Set<String> _enMarcha = <String>{'en_origen', 'saliendo_origen', 'en_transito', 'en_destino'};

  /// Primero el servicio en marcha; después por hora programada
  static List<TrasladoEntity> _ordenar(List<TrasladoEntity> traslados) {
    final List<TrasladoEntity> lista = traslados.where((t) => t.estaEnCurso).toList();
    lista.sort((a, b) {
      final bool aMarcha = _enMarcha.contains(a.estado);
      final bool bMarcha = _enMarcha.contains(b.estado);
      if (aMarcha != bMarcha) {
        return aMarcha ? -1 : 1;
      }
      final DateTime fa = a.horaProgramada ?? a.fecha ?? DateTime(2100);
      final DateTime fb = b.horaProgramada ?? b.fecha ?? DateTime(2100);
      return fa.compareTo(fb);
    });
    return lista;
  }
}

/// Contenedor común de la tarjeta
class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Próximo servicio con hora, estado y trayecto
class _ServicioCard extends StatelessWidget {
  const _ServicioCard({required this.traslado, required this.restantes});

  final TrasladoEntity traslado;
  final int restantes;

  @override
  Widget build(BuildContext context) {
    final DateTime? hora = traslado.horaProgramada;
    final EstadoTraslado? estado = EstadoTraslado.fromValue(traslado.estado);

    return _Tarjeta(
      onTap: () => context.push('/servicios/${traslado.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                hora != null ? DateFormat('HH:mm').format(hora.toLocal()) : '--:--',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  traslado.pacienteNombre ?? traslado.codigo ?? 'Servicio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
              ),
              if (estado != null) EstadoTrasladoBadge(estado: estado),
            ],
          ),
          const SizedBox(height: 14),
          _Parada(icon: Icons.trip_origin_rounded, color: AppColors.secondary, texto: traslado.origenCompleto),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(height: 12, child: VerticalDivider(width: 1, color: AppColors.gray300)),
          ),
          _Parada(icon: Icons.location_on_rounded, color: AppColors.error, texto: traslado.destinoCompleto),
          const SizedBox(height: 12),
          _Pie(restantes: restantes),
        ],
      ),
    );
  }
}

/// Origen o destino del trayecto
class _Parada extends StatelessWidget {
  const _Parada({required this.icon, required this.color, required this.texto});

  final IconData icon;
  final Color color;
  final String? texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            (texto != null && texto!.isNotEmpty) ? texto! : 'Sin especificar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.gray700),
          ),
        ),
      ],
    );
  }
}

/// Pie con servicios restantes y acceso al listado
class _Pie extends StatelessWidget {
  const _Pie({required this.restantes});

  final int restantes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            restantes > 0 ? '+$restantes servicio${restantes == 1 ? '' : 's'} más' : 'Último servicio asignado',
            style: const TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ),
        const Text(
          'Ver detalle',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.primary),
      ],
    );
  }
}

/// Estado sin servicios pendientes
class _SinServicios extends StatelessWidget {
  const _SinServicios({this.mensaje = 'No tienes servicios pendientes'});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return _Tarjeta(
      onTap: () => context.push('/servicios'),
      child: Row(
        children: <Widget>[
          const Icon(Icons.event_available_outlined, size: 24, color: AppColors.gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensaje, style: const TextStyle(fontSize: 14, color: AppColors.gray600)),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
        ],
      ),
    );
  }
}

/// Esqueleto mientras se cargan los servicios
class _ServicioSkeleton extends StatelessWidget {
  const _ServicioSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSkeleton(width: 140, height: 22),
          SizedBox(height: 16),
          AppSkeleton(height: 14),
          SizedBox(height: 10),
          AppSkeleton(width: 220, height: 14),
        ],
      ),
    );
  }
}
