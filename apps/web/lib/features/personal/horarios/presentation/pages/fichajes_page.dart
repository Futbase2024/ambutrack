import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_event.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/fichajes_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pagina de visualizacion de fichajes con mapas GPS
class FichajesPage extends StatelessWidget {
  const FichajesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<RegistroHorarioBloc>.value(
        value: getIt<RegistroHorarioBloc>(),
        child: const _FichajesView(),
      ),
    );
  }
}

class _FichajesView extends StatefulWidget {
  const _FichajesView();

  @override
  State<_FichajesView> createState() => _FichajesViewState();
}

class _FichajesViewState extends State<_FichajesView> {
  @override
  void initState() {
    super.initState();

    // Cargar fichajes de los últimos 30 días por defecto
    final DateTime hoy = DateTime.now();
    final DateTime hace30Dias = hoy.subtract(const Duration(days: 30));
    final DateTime finHoy = hoy.add(const Duration(days: 1));

    context.read<RegistroHorarioBloc>().add(LoadAllRegistros(
          fechaInicio: hace30Dias,
          fechaFin: finHoy,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          children: <Widget>[
            // Header con estadisticas
            BlocBuilder<RegistroHorarioBloc, RegistroHorarioState>(
              builder: (BuildContext context, RegistroHorarioState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.location_on,
                    title: 'Fichajes del Personal',
                    subtitle: 'Visualiza los registros de entrada/salida con ubicacion GPS',
                    stats: _buildHeaderStats(state),
                    onAdd: () {
                      // Vista de solo lectura - sin accion de agregar
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla con filtros
            const Expanded(
              child: FichajesTable(),
            ),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(RegistroHorarioState state) {
    String totalFichajes = '-';
    String fichajesHoy = '-';
    String entradas = '-';
    String salidas = '-';

    if (state is RegistroHorarioFichajesLoaded) {
      totalFichajes = state.registros.length.toString();

      final DateTime hoy = DateTime.now();
      final List<RegistroHorarioEntity> fichajesDeHoy = state.registros.where((RegistroHorarioEntity r) {
        final DateTime fecha = r.fechaHora;
        return fecha.year == hoy.year &&
            fecha.month == hoy.month &&
            fecha.day == hoy.day;
      }).toList();

      fichajesHoy = fichajesDeHoy.length.toString();
      entradas = state.registros
          .where((RegistroHorarioEntity r) => r.tipo.toLowerCase() == 'entrada')
          .length
          .toString();
      salidas = state.registros
          .where((RegistroHorarioEntity r) => r.tipo.toLowerCase() == 'salida')
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: totalFichajes, icon: Icons.list),
      HeaderStat(value: fichajesHoy, icon: Icons.today),
      HeaderStat(
          value: entradas, icon: Icons.login, color: AppColors.success),
      HeaderStat(value: salidas, icon: Icons.logout, color: AppColors.error),
    ];
  }
}
