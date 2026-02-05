import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/registro_horario_repository.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_event.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/personal_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de gestión de horarios y registro horario del personal
class HorariosPage extends StatelessWidget {
  const HorariosPage({super.key});

  // Lista de personal de ejemplo (en producción vendría de un datasource)
  static final List<PersonalItem> _personalList = <PersonalItem>[
    const PersonalItem(
      id: 'PERS001',
      nombre: 'Juan Pérez',
      cargo: 'Médico - SVA',
    ),
    const PersonalItem(
      id: 'PERS002',
      nombre: 'María García',
      cargo: 'Enfermera - SVB',
    ),
    const PersonalItem(
      id: 'PERS003',
      nombre: 'Carlos López',
      cargo: 'Técnico - TES',
    ),
    const PersonalItem(
      id: 'PERS004',
      nombre: 'Ana Martínez',
      cargo: 'Médico - SVA',
    ),
    const PersonalItem(
      id: 'PERS005',
      nombre: 'Pedro Sánchez',
      cargo: 'Conductor',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<RegistroHorarioBloc>(
        create: (BuildContext context) => RegistroHorarioBloc(getIt<RegistroHorarioRepository>())
          ..add(const LoadRegistroHorarioData(personalId: 'PERS001')),
        child: _HorariosPageContent(personalList: _personalList),
      ),
    );
  }
}

/// Contenido principal de la página con BLoC
class _HorariosPageContent extends StatelessWidget {
  const _HorariosPageContent({required this.personalList});

  final List<PersonalItem> personalList;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistroHorarioBloc, RegistroHorarioState>(
      listener: (BuildContext context, RegistroHorarioState state) {
        // Mostrar SnackBar para estados de éxito y error
        if (state is RegistroHorarioSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is RegistroHorarioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (BuildContext context, RegistroHorarioState state) {
        // Determinar el estado de carga
        final bool isLoading = state is RegistroHorarioLoading ||
            state is RegistroHorarioProcessing ||
            state is RegistroHorarioInitial;

        // Obtener datos del estado Loaded
        String? personalId;
        String? nombrePersonal;
        List<RegistroHorarioEntity> registrosHoy = <RegistroHorarioEntity>[];
        RegistroHorarioEntity? fichajeActivo;

        if (state is RegistroHorarioLoaded) {
          personalId = state.personalId;
          nombrePersonal = state.nombrePersonal;
          registrosHoy = state.registrosHoy;
          fichajeActivo = state.fichajeActivo;
        } else if (state is RegistroHorarioSuccess) {
          personalId = state.previousState.personalId;
          nombrePersonal = state.previousState.nombrePersonal;
          registrosHoy = state.previousState.registrosHoy;
          fichajeActivo = state.previousState.fichajeActivo;
        } else if (state is RegistroHorarioError && state.previousState != null) {
          personalId = state.previousState!.personalId;
          nombrePersonal = state.previousState!.nombrePersonal;
          registrosHoy = state.previousState!.registrosHoy;
          fichajeActivo = state.previousState!.fichajeActivo;
        } else if (state is RegistroHorarioProcessing) {
          personalId = state.previousState.personalId;
          nombrePersonal = state.previousState.nombrePersonal;
          registrosHoy = state.previousState.registrosHoy;
          fichajeActivo = state.previousState.fichajeActivo;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _HorariosHeader(),
                const SizedBox(height: 24),

                // Selector de Personal
                PersonalSelector(
                  selectedPersonalId: personalId ?? 'PERS001',
                  personalList: personalList,
                  onPersonalSelected: (PersonalItem personal) {
                    context.read<RegistroHorarioBloc>().add(
                          ChangeSelectedPersonal(
                            personalId: personal.id,
                            nombrePersonal: personal.nombre,
                          ),
                        );
                  },
                ),

                const SizedBox(height: 24),

                // Botones de Fichaje
                _BotonesFichaje(
                  isLoading: isLoading,
                  fichajeActivo: fichajeActivo,
                  personalId: personalId ?? 'PERS001',
                  nombrePersonal: nombrePersonal ?? 'Personal',
                ),

                const SizedBox(height: 24),

                // Estado Actual
                if (fichajeActivo != null)
                  _FichajeActivo(fichajeActivo: fichajeActivo),

                const SizedBox(height: 24),

                // Registros de Hoy
                _RegistrosHoy(
                  isLoading: isLoading,
                  registrosHoy: registrosHoy,
                  personalId: personalId ?? 'PERS001',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Header de la página de horarios
class _HorariosHeader extends StatelessWidget {
  const _HorariosHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.success, Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Horarios y Turnos',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Control de registro horario del personal',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botones de registro de entrada y salida
class _BotonesFichaje extends StatelessWidget {
  const _BotonesFichaje({
    required this.isLoading,
    required this.fichajeActivo,
    required this.personalId,
    required this.nombrePersonal,
  });

  final bool isLoading;
  final RegistroHorarioEntity? fichajeActivo;
  final String personalId;
  final String nombrePersonal;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Registro Horario',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading || fichajeActivo != null
                        ? null
                        : () {
                            context.read<RegistroHorarioBloc>().add(
                                  RegisterEntrada(
                                    personalId: personalId,
                                    nombrePersonal: nombrePersonal,
                                    ubicacion: 'Base Central',
                                  ),
                                );
                          },
                    icon: const Icon(Icons.login, size: 24),
                    label: Text(
                      'Registrar Entrada',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading || fichajeActivo == null
                        ? null
                        : () {
                            context.read<RegistroHorarioBloc>().add(
                                  RegisterSalida(
                                    personalId: personalId,
                                    nombrePersonal: nombrePersonal,
                                    ubicacion: 'Base Central',
                                  ),
                                );
                          },
                    icon: const Icon(Icons.logout, size: 24),
                    label: Text(
                      'Registrar Salida',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar el fichaje activo
class _FichajeActivo extends StatelessWidget {
  const _FichajeActivo({required this.fichajeActivo});

  final RegistroHorarioEntity fichajeActivo;

  String _formatearDuracion(double horas) {
    final int horasEnteras = horas.floor();
    final int minutos = ((horas - horasEnteras) * 60).round();
    return '${horasEnteras}h ${minutos}m';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime ahora = DateTime.now();
    final Duration duracion = ahora.difference(fichajeActivo.fechaHora);
    final double horasTrabajadas = duracion.inMinutes / 60.0;

    return Card(
      elevation: 2,
      color: AppColors.primarySurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Fichaje Activo',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Entrada: ${fichajeActivo.fechaHora.hour.toString().padLeft(2, '0')}:${fichajeActivo.fechaHora.minute.toString().padLeft(2, '0')}",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _formatearDuracion(horasTrabajadas),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'trabajadas',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar los registros del día
class _RegistrosHoy extends StatelessWidget {
  const _RegistrosHoy({
    required this.isLoading,
    required this.registrosHoy,
    required this.personalId,
  });

  final bool isLoading;
  final List<RegistroHorarioEntity> registrosHoy;
  final String personalId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Registros de Hoy',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<RegistroHorarioBloc>().add(
                                RefreshRegistroHorarioData(personalId: personalId),
                              );
                        },
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (registrosHoy.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No hay registros para hoy',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: registrosHoy.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 24),
                itemBuilder: (BuildContext context, int index) {
                  final RegistroHorarioEntity registro = registrosHoy[index];
                  return _RegistroItem(registro: registro);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un item de registro
class _RegistroItem extends StatelessWidget {
  const _RegistroItem({required this.registro});

  final RegistroHorarioEntity registro;

  @override
  Widget build(BuildContext context) {
    final bool esEntrada = registro.tipo == 'entrada';
    final Color color = esEntrada ? AppColors.success : AppColors.error;
    final IconData icon = esEntrada ? Icons.login : Icons.logout;

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                esEntrada ? 'Entrada' : 'Salida',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${registro.fechaHora.hour.toString().padLeft(2, '0')}:${registro.fechaHora.minute.toString().padLeft(2, '0')}",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        if (registro.horasTrabajadas != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${registro.horasTrabajadas!.toStringAsFixed(2)}h',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
