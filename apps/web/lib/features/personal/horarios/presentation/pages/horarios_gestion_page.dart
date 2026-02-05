import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de gestión de horarios con vista de cuadrícula
class HorariosGestionPage extends StatefulWidget {
  const HorariosGestionPage({super.key});

  @override
  State<HorariosGestionPage> createState() => _HorariosGestionPageState();
}

class _HorariosGestionPageState extends State<HorariosGestionPage> {
  // Datos de ejemplo del personal
  final List<PersonalHorario> _personalHorarios = <PersonalHorario>[
    const PersonalHorario(
      id: 'PERS001',
      nombre: 'Juan Pérez',
      cargo: 'Médico - SVA',
      turno: 'Mañana',
      horaEntrada: TimeOfDay(hour: 8, minute: 0),
      horaSalida: TimeOfDay(hour: 16, minute: 0),
      horaInicioDescanso: TimeOfDay(hour: 12, minute: 0),
      horaFinDescanso: TimeOfDay(hour: 13, minute: 0),
      activo: true,
    ),
    const PersonalHorario(
      id: 'PERS002',
      nombre: 'María García',
      cargo: 'Enfermera - SVB',
      turno: 'Tarde',
      horaEntrada: TimeOfDay(hour: 14, minute: 0),
      horaSalida: TimeOfDay(hour: 22, minute: 0),
      horaInicioDescanso: TimeOfDay(hour: 18, minute: 0),
      horaFinDescanso: TimeOfDay(hour: 19, minute: 0),
      activo: true,
    ),
    const PersonalHorario(
      id: 'PERS003',
      nombre: 'Carlos López',
      cargo: 'Técnico - TES',
      turno: 'Noche',
      horaEntrada: TimeOfDay(hour: 22, minute: 0),
      horaSalida: TimeOfDay(hour: 6, minute: 0),
      horaInicioDescanso: TimeOfDay(hour: 2, minute: 0),
      horaFinDescanso: TimeOfDay(hour: 3, minute: 0),
      activo: true,
    ),
    const PersonalHorario(
      id: 'PERS004',
      nombre: 'Ana Martínez',
      cargo: 'Médico - SVA',
      turno: 'Mañana',
      horaEntrada: TimeOfDay(hour: 8, minute: 0),
      horaSalida: TimeOfDay(hour: 16, minute: 0),
      horaInicioDescanso: TimeOfDay(hour: 12, minute: 0),
      horaFinDescanso: TimeOfDay(hour: 13, minute: 0),
      activo: true,
    ),
    const PersonalHorario(
      id: 'PERS005',
      nombre: 'Pedro Sánchez',
      cargo: 'Conductor',
      turno: 'Rotativo',
      horaEntrada: TimeOfDay(hour: 7, minute: 0),
      horaSalida: TimeOfDay(hour: 15, minute: 0),
      horaInicioDescanso: TimeOfDay(hour: 11, minute: 0),
      horaFinDescanso: TimeOfDay(hour: 12, minute: 0),
      activo: true,
    ),
  ];

  String _filtroTurno = 'Todos';
  String _busqueda = '';

  List<PersonalHorario> get _personalFiltrado {
    return _personalHorarios.where((PersonalHorario p) {
      final bool cumpleTurno = _filtroTurno == 'Todos' || p.turno == _filtroTurno;
      final bool cumpleBusqueda =
          _busqueda.isEmpty || p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      return cumpleTurno && cumpleBusqueda;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _HeaderGestion(),
              const SizedBox(height: 24),
              _EstadisticasResumen(personalHorarios: _personalHorarios),
              const SizedBox(height: 24),
              _FiltrosYBusqueda(
                filtroTurno: _filtroTurno,
                busqueda: _busqueda,
                onFiltroChanged: (String? value) {
                  setState(() {
                    _filtroTurno = value ?? 'Todos';
                  });
                },
                onBusquedaChanged: (String value) {
                  setState(() {
                    _busqueda = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              _TablaHorarios(
                personalHorarios: _personalFiltrado,
                onEdit: _editarHorario,
                onToggleActivo: _toggleActivo,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _agregarNuevoPersonal,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Agregar Personal',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _editarHorario(PersonalHorario personal, String campo, Object valor) {
    setState(() {
      final int index = _personalHorarios.indexWhere((PersonalHorario p) => p.id == personal.id);
      if (index != -1) {
        final PersonalHorario nuevoHorario = personal.copyWith(
          turno: campo == 'turno' ? valor as String : null,
          horaEntrada: campo == 'horaEntrada' ? valor as TimeOfDay : null,
          horaSalida: campo == 'horaSalida' ? valor as TimeOfDay : null,
          horaInicioDescanso: campo == 'horaInicioDescanso' ? valor as TimeOfDay : null,
          horaFinDescanso: campo == 'horaFinDescanso' ? valor as TimeOfDay : null,
        );

        // Validación básica
        if (_validarHorario(nuevoHorario)) {
          _personalHorarios[index] = nuevoHorario;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Horario de ${personal.nombre} actualizado'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Verifica que las horas sean coherentes'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  bool _validarHorario(PersonalHorario horario) {
    // Validar que las horas sean coherentes
    if (horario.horaEntrada != null && horario.horaSalida != null) {
      final int minutosEntrada = horario.horaEntrada!.hour * 60 + horario.horaEntrada!.minute;
      final int minutosSalida = horario.horaSalida!.hour * 60 + horario.horaSalida!.minute;

      // Permitir turnos nocturnos (salida al día siguiente)
      if (horario.turno != 'Noche' && minutosSalida <= minutosEntrada) {
        return false;
      }
    }

    // Validar descansos
    if (horario.horaInicioDescanso != null && horario.horaFinDescanso != null) {
      final int minutosInicioDescanso = horario.horaInicioDescanso!.hour * 60 +
                                         horario.horaInicioDescanso!.minute;
      final int minutosFinDescanso = horario.horaFinDescanso!.hour * 60 +
                                      horario.horaFinDescanso!.minute;

      if (minutosFinDescanso <= minutosInicioDescanso) {
        return false;
      }
    }

    return true;
  }

  void _toggleActivo(PersonalHorario personal) {
    setState(() {
      final int index = _personalHorarios.indexWhere((PersonalHorario p) => p.id == personal.id);
      if (index != -1) {
        _personalHorarios[index] = personal.copyWith(activo: !personal.activo);
      }
    });
  }

  void _agregarNuevoPersonal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de agregar personal en desarrollo'),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Estadísticas resumen
class _EstadisticasResumen extends StatelessWidget {
  const _EstadisticasResumen({required this.personalHorarios});

  final List<PersonalHorario> personalHorarios;

  @override
  Widget build(BuildContext context) {
    final int totalActivos = personalHorarios.where((PersonalHorario p) => p.activo).length;
    final int totalInactivos = personalHorarios.length - totalActivos;
    final Map<String, int> porTurno = _contarPorTurno();

    return Row(
      children: <Widget>[
        Expanded(
          child: _TarjetaEstadistica(
            titulo: 'Total Personal',
            valor: '${personalHorarios.length}',
            icono: Icons.people,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaEstadistica(
            titulo: 'Activos',
            valor: '$totalActivos',
            icono: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaEstadistica(
            titulo: 'Inactivos',
            valor: '$totalInactivos',
            icono: Icons.cancel,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaEstadistica(
            titulo: 'Turno Mañana',
            valor: '${porTurno['Mañana'] ?? 0}',
            icono: Icons.wb_sunny,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TarjetaEstadistica(
            titulo: 'Turno Noche',
            valor: '${porTurno['Noche'] ?? 0}',
            icono: Icons.nightlight_round,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Map<String, int> _contarPorTurno() {
    final Map<String, int> conteo = <String, int>{};
    for (final PersonalHorario personal in personalHorarios) {
      if (personal.activo) {
        conteo[personal.turno] = (conteo[personal.turno] ?? 0) + 1;
      }
    }
    return conteo;
  }
}

/// Tarjeta de estadística individual
class _TarjetaEstadistica extends StatelessWidget {
  const _TarjetaEstadistica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: color, size: 24),
                ),
                Text(
                  valor,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header de la página
class _HeaderGestion extends StatelessWidget {
  const _HeaderGestion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
            child: const Icon(Icons.schedule, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Gestión de Horarios',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configuración de turnos y horarios del personal',
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

/// Filtros y búsqueda
class _FiltrosYBusqueda extends StatelessWidget {
  const _FiltrosYBusqueda({
    required this.filtroTurno,
    required this.busqueda,
    required this.onFiltroChanged,
    required this.onBusquedaChanged,
  });

  final String filtroTurno;
  final String busqueda;
  final ValueChanged<String?> onFiltroChanged;
  final ValueChanged<String> onBusquedaChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar Personal',
                  hintText: 'Escribe el nombre del personal...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: onBusquedaChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: filtroTurno,
                decoration: InputDecoration(
                  labelText: 'Filtrar por Turno',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'Todos', child: Text('Todos')),
                  DropdownMenuItem<String>(value: 'Mañana', child: Text('Mañana')),
                  DropdownMenuItem<String>(value: 'Tarde', child: Text('Tarde')),
                  DropdownMenuItem<String>(value: 'Noche', child: Text('Noche')),
                  DropdownMenuItem<String>(value: 'Rotativo', child: Text('Rotativo')),
                ],
                onChanged: onFiltroChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabla de horarios editable
class _TablaHorarios extends StatelessWidget {
  const _TablaHorarios({
    required this.personalHorarios,
    required this.onEdit,
    required this.onToggleActivo,
  });

  final List<PersonalHorario> personalHorarios;
  final void Function(PersonalHorario, String, Object) onEdit;
  final void Function(PersonalHorario) onToggleActivo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.primarySurface,
            ),
            columns: <DataColumn>[
              DataColumn(
                label: Text(
                  'Personal',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Cargo',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Turno',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hora Entrada',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hora Salida',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Inicio Descanso',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fin Descanso',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Horas Totales',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Estado',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: personalHorarios
                .map(
                  (PersonalHorario personal) => DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          personal.nombre,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(personal.cargo)),
                      DataCell(
                        _CeldaTurnoEditable(
                          personal: personal,
                          onEdit: onEdit,
                        ),
                      ),
                      DataCell(
                        _CeldaHoraEditable(
                          personal: personal,
                          campo: 'horaEntrada',
                          hora: personal.horaEntrada,
                          onEdit: onEdit,
                        ),
                      ),
                      DataCell(
                        _CeldaHoraEditable(
                          personal: personal,
                          campo: 'horaSalida',
                          hora: personal.horaSalida,
                          onEdit: onEdit,
                        ),
                      ),
                      DataCell(
                        _CeldaHoraEditable(
                          personal: personal,
                          campo: 'horaInicioDescanso',
                          hora: personal.horaInicioDescanso,
                          onEdit: onEdit,
                        ),
                      ),
                      DataCell(
                        _CeldaHoraEditable(
                          personal: personal,
                          campo: 'horaFinDescanso',
                          hora: personal.horaFinDescanso,
                          onEdit: onEdit,
                        ),
                      ),
                      DataCell(
                        _CeldaHorasTotales(personal: personal),
                      ),
                      DataCell(
                        Switch(
                          value: personal.activo,
                          onChanged: (bool value) => onToggleActivo(personal),
                          activeTrackColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

/// Celda editable para turno
class _CeldaTurnoEditable extends StatelessWidget {
  const _CeldaTurnoEditable({
    required this.personal,
    required this.onEdit,
  });

  final PersonalHorario personal;
  final void Function(PersonalHorario, String, Object) onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final String? nuevoTurno = await showDialog<String>(
          context: context,
          builder: (BuildContext context) => _DialogSeleccionTurno(
            turnoActual: personal.turno,
          ),
        );
        if (nuevoTurno != null && nuevoTurno != personal.turno) {
          onEdit(personal, 'turno', nuevoTurno);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getColorTurno(personal.turno),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              personal.turno,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Color _getColorTurno(String turno) {
    switch (turno) {
      case 'Mañana':
        return AppColors.success;
      case 'Tarde':
        return AppColors.warning;
      case 'Noche':
        return AppColors.primary;
      case 'Rotativo':
        return AppColors.secondary;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}

/// Celda que muestra las horas totales trabajadas
class _CeldaHorasTotales extends StatelessWidget {
  const _CeldaHorasTotales({required this.personal});

  final PersonalHorario personal;

  @override
  Widget build(BuildContext context) {
    final String horasTotales = _calcularHorasTotales();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.timer, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            horasTotales,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _calcularHorasTotales() {
    if (personal.horaEntrada == null || personal.horaSalida == null) {
      return '--:--';
    }

    final int minutosEntrada = personal.horaEntrada!.hour * 60 + personal.horaEntrada!.minute;
    int minutosSalida = personal.horaSalida!.hour * 60 + personal.horaSalida!.minute;

    // Si es turno nocturno, agregar 24 horas a la salida
    if (personal.turno == 'Noche' && minutosSalida < minutosEntrada) {
      minutosSalida += 24 * 60;
    }

    int minutosTotales = minutosSalida - minutosEntrada;

    // Restar tiempo de descanso si existe
    if (personal.horaInicioDescanso != null && personal.horaFinDescanso != null) {
      final int minutosInicioDescanso = personal.horaInicioDescanso!.hour * 60 +
                                         personal.horaInicioDescanso!.minute;
      final int minutosFinDescanso = personal.horaFinDescanso!.hour * 60 +
                                      personal.horaFinDescanso!.minute;
      final int minutosDescanso = minutosFinDescanso - minutosInicioDescanso;

      if (minutosDescanso > 0) {
        minutosTotales -= minutosDescanso;
      }
    }

    if (minutosTotales < 0) {
      return '--:--';
    }

    final int horas = minutosTotales ~/ 60;
    final int minutos = minutosTotales % 60;

    return '${horas}h ${minutos}m';
  }
}

/// Celda editable para hora
class _CeldaHoraEditable extends StatelessWidget {
  const _CeldaHoraEditable({
    required this.personal,
    required this.campo,
    required this.hora,
    required this.onEdit,
  });

  final PersonalHorario personal;
  final String campo;
  final TimeOfDay? hora;
  final void Function(PersonalHorario, String, Object) onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? nuevaHora = await showTimePicker(
          context: context,
          initialTime: hora ?? const TimeOfDay(hour: 8, minute: 0),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (nuevaHora != null && nuevaHora != hora) {
          onEdit(personal, campo, nuevaHora);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.access_time, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              hora != null ? _formatearHora(hora!) : '--:--',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}

/// Diálogo para seleccionar turno
class _DialogSeleccionTurno extends StatelessWidget {
  const _DialogSeleccionTurno({required this.turnoActual});

  final String turnoActual;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Seleccionar Turno',
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _OpcionTurno(
            turno: 'Mañana',
            seleccionado: turnoActual == 'Mañana',
            onTap: () => Navigator.pop(context, 'Mañana'),
          ),
          _OpcionTurno(
            turno: 'Tarde',
            seleccionado: turnoActual == 'Tarde',
            onTap: () => Navigator.pop(context, 'Tarde'),
          ),
          _OpcionTurno(
            turno: 'Noche',
            seleccionado: turnoActual == 'Noche',
            onTap: () => Navigator.pop(context, 'Noche'),
          ),
          _OpcionTurno(
            turno: 'Rotativo',
            seleccionado: turnoActual == 'Rotativo',
            onTap: () => Navigator.pop(context, 'Rotativo'),
          ),
        ],
      ),
    );
  }
}

/// Opción de turno en el diálogo
class _OpcionTurno extends StatelessWidget {
  const _OpcionTurno({
    required this.turno,
    required this.seleccionado,
    required this.onTap,
  });

  final String turno;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.textSecondaryLight,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              seleccionado ? Icons.check_circle : Icons.circle_outlined,
              color: seleccionado ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Text(
              turno,
              style: GoogleFonts.inter(
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                color: seleccionado ? AppColors.primary : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo de datos para horario de personal
class PersonalHorario {
  const PersonalHorario({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.turno,
    required this.horaEntrada,
    required this.horaSalida,
    this.horaInicioDescanso,
    this.horaFinDescanso,
    required this.activo,
  });

  final String id;
  final String nombre;
  final String cargo;
  final String turno;
  final TimeOfDay? horaEntrada;
  final TimeOfDay? horaSalida;
  final TimeOfDay? horaInicioDescanso;
  final TimeOfDay? horaFinDescanso;
  final bool activo;

  PersonalHorario copyWith({
    String? id,
    String? nombre,
    String? cargo,
    String? turno,
    TimeOfDay? horaEntrada,
    TimeOfDay? horaSalida,
    TimeOfDay? horaInicioDescanso,
    TimeOfDay? horaFinDescanso,
    bool? activo,
  }) {
    return PersonalHorario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      turno: turno ?? this.turno,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSalida: horaSalida ?? this.horaSalida,
      horaInicioDescanso: horaInicioDescanso ?? this.horaInicioDescanso,
      horaFinDescanso: horaFinDescanso ?? this.horaFinDescanso,
      activo: activo ?? this.activo,
    );
  }
}
