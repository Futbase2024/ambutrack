import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_dia_cell.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_persona_cell.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_resumen_semana_cell.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_header.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/tabla/cuadrante_tabla_utils.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vista de tabla semanal del cuadrante.
///
/// Filas de altura fija: persona · 7 días · resumen semanal. Las dotaciones
/// se cargan aquí (como en la barra de filtros) para calcular la cobertura.
class CuadranteTablaView extends StatefulWidget {
  const CuadranteTablaView({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  State<CuadranteTablaView> createState() => _CuadranteTablaViewState();
}

class _CuadranteTablaViewState extends State<CuadranteTablaView> {
  List<DotacionEntity>? _dotaciones;

  @override
  void initState() {
    super.initState();
    _cargarDotaciones();
  }

  Future<void> _cargarDotaciones() async {
    try {
      final List<DotacionEntity> todas = await getIt<DotacionesRepository>().getAll();
      if (mounted) {
        setState(() => _dotaciones = todas.where((DotacionEntity d) => d.activo).toList());
      }
    } catch (e) {
      debugPrint('❌ CuadranteTabla: error al cargar dotaciones para la cobertura: $e');
      if (mounted) {
        setState(() => _dotaciones = const <DotacionEntity>[]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurnosBloc, TurnosState>(
      listener: (BuildContext context, TurnosState turnosState) {
        if (turnosState is TurnosOperationSuccess) {
          debugPrint('✅ Operación de turno exitosa, refrescando cuadrante...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
            }
          });
        }
      },
      child: widget.state.personalConTurnos.isEmpty
          ? const _TablaVacia()
          : _Tabla(state: widget.state, dotaciones: _dotaciones),
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({required this.state, required this.dotaciones});

  final CuadranteLoaded state;
  final List<DotacionEntity>? dotaciones;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> nombresDotacion = <String, String>{
      for (final DotacionEntity d in dotaciones ?? const <DotacionEntity>[]) d.id: d.nombre,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingSmall),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.gray200),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CuadranteTablaHeader(state: state, dotaciones: dotaciones),
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: state.personalConTurnos.length,
                itemExtent: CuadranteTablaMedidas.altoFila,
                itemBuilder: (BuildContext context, int i) => _FilaPersona(
                  persona: state.personalConTurnos[i],
                  state: state,
                  nombresDotacion: nombresDotacion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaPersona extends StatelessWidget {
  const _FilaPersona({required this.persona, required this.state, required this.nombresDotacion});

  final PersonalConTurnosEntity persona;
  final CuadranteLoaded state;
  final Map<String, String> nombresDotacion;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray200))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: CuadranteTablaMedidas.anchoPersonal,
            child: CuadrantePersonaCell(persona: persona, nombresDotacion: nombresDotacion),
          ),
          for (final DateTime dia in diasDeSemana(state.primerDiaSemana))
            Expanded(child: CuadranteDiaCell(persona: persona, dia: dia, state: state)),
          SizedBox(
            width: CuadranteTablaMedidas.anchoSemana,
            child: CuadranteResumenSemanaCell(persona: persona, lunes: state.primerDiaSemana),
          ),
        ],
      ),
    );
  }
}

class _TablaVacia extends StatelessWidget {
  const _TablaVacia();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondaryLight),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'No hay personal disponible',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Ajusta los filtros o agrega personal al sistema',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}
