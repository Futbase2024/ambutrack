import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Página de gestión de formación del personal
class FormacionPage extends StatefulWidget {
  const FormacionPage({super.key});

  @override
  State<FormacionPage> createState() => _FormacionPageState();
}

class _FormacionPageState extends State<FormacionPage> {
  String _filtroEstado = 'todos';
  String _busqueda = '';

  // Datos de ejemplo
  final List<Map<String, dynamic>> _personal = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': '1',
      'nombre': 'Dr. García López',
      'cargo': 'Médico - Soporte Vital Avanzado',
      'certificaciones': <String>['SVA', 'ACLS', 'PHTLS'],
      'ultimaFormacion': DateTime(2024, 8, 15),
      'proximaFormacion': DateTime(2025, 2, 15),
      'horasAcumuladas': 120.0,
      'estado': 'Al día',
      'observaciones': 'Certificaciones vigentes',
    },
    <String, dynamic>{
      'id': '2',
      'nombre': 'Enf. Martínez Ruiz',
      'cargo': 'Enfermero/a - TES',
      'certificaciones': <String>['TES', 'SVB', 'DEA'],
      'ultimaFormacion': DateTime(2024, 6, 20),
      'proximaFormacion': DateTime(2024, 12, 20),
      'horasAcumuladas': 85.0,
      'estado': 'Próxima',
      'observaciones': 'Renovación de TES pendiente',
    },
    <String, dynamic>{
      'id': '3',
      'nombre': 'Técn. Rodríguez Sánchez',
      'cargo': 'Técnico de Emergencias Sanitarias',
      'certificaciones': <String>['TES', 'SVB'],
      'ultimaFormacion': DateTime(2024, 3, 10),
      'proximaFormacion': DateTime(2024, 9, 10),
      'horasAcumuladas': 60.0,
      'estado': 'Vencida',
      'observaciones': 'Requiere actualización urgente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> personalFiltrado = _filtrarYOrdenarPersonal();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: <Widget>[
            _buildHeader(),
            _buildSearchAndFilters(),
            _buildStats(),
            Expanded(
              child: personalFiltrado.isEmpty
                  ? _buildEmptyState()
                  : _buildPersonalGrid(personalFiltrado),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.secondary,
            AppColors.formacion,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
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
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Formación y Certificaciones',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Control de capacitaciones y certificaciones del personal',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO(team): Implementar programar formación
            },
            icon: const Icon(Icons.add),
            label: const Text('Programar Formación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (String value) {
                setState(() {
                  _busqueda = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cargo...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _filtroEstado,
              decoration: InputDecoration(
                labelText: 'Estado',
                prefixIcon: const Icon(Icons.filter_list, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
                DropdownMenuItem<String>(value: 'Al día', child: Text('Al día')),
                DropdownMenuItem<String>(value: 'Próxima', child: Text('Próxima')),
                DropdownMenuItem<String>(value: 'Vencida', child: Text('Vencida')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _filtroEstado = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final int total = _personal.length;
    final int alDia = _personal.where((Map<String, dynamic> p) => p['estado'] == 'Al día').length;
    final int proximas = _personal.where((Map<String, dynamic> p) => p['estado'] == 'Próxima').length;
    final int vencidas = _personal.where((Map<String, dynamic> p) => p['estado'] == 'Vencida').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          _buildStatCard('Total', total.toString(), Icons.people, AppColors.primary),
          const SizedBox(width: 16),
          _buildStatCard('Al Día', alDia.toString(), Icons.check_circle, AppColors.success),
          const SizedBox(width: 16),
          _buildStatCard('Próximas', proximas.toString(), Icons.warning, AppColors.warning),
          const SizedBox(width: 16),
          _buildStatCard('Vencidas', vencidas.toString(), Icons.error, AppColors.emergency),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gray900.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
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

  Widget _buildPersonalGrid(List<Map<String, dynamic>> personal) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gray900.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildGridHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: personal.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildGridRow(personal[index], index % 2 == 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: <Widget>[
          _buildHeaderCell('Nombre', flex: 3),
          _buildHeaderCell('Cargo', flex: 3),
          _buildHeaderCell('Certificaciones', flex: 3),
          _buildHeaderCell('Última Formación', flex: 2),
          _buildHeaderCell('Próxima Formación', flex: 2),
          _buildHeaderCell('Horas'),
          _buildHeaderCell('Estado', flex: 2),
          _buildHeaderCell('Acciones'),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGridRow(Map<String, dynamic> persona, bool isEven) {
    final Color estadoColor = _getEstadoColor(persona['estado'] as String);
    final List<String> certificaciones = (persona['certificaciones'] as List<dynamic>).cast<String>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.backgroundLight.withValues(alpha: 0.3),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              persona['nombre'] as String,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              persona['cargo'] as String,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: certificaciones.map((String cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cert,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy').format(persona['ultimaFormacion'] as DateTime),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy').format(persona['proximaFormacion'] as DateTime),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${persona['horasAcumuladas']}h',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: estadoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: estadoColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      persona['estado'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: estadoColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'ver',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.visibility, size: 18, color: AppColors.info),
                      SizedBox(width: 12),
                      Text('Ver Detalles'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'programar',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('Programar Formación'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.school_outlined,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontró personal',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta los filtros para ver más resultados',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtrarYOrdenarPersonal() {
    final List<Map<String, dynamic>> resultado = _personal.where((Map<String, dynamic> persona) {
      final bool coincideBusqueda = _busqueda.isEmpty ||
          (persona['nombre'] as String).toLowerCase().contains(_busqueda.toLowerCase()) ||
          (persona['cargo'] as String).toLowerCase().contains(_busqueda.toLowerCase());

      final bool coincideEstado = _filtroEstado == 'todos' || persona['estado'] == _filtroEstado;

      return coincideBusqueda && coincideEstado;
    }).toList();

    return resultado;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Al día':
        return AppColors.success;
      case 'Próxima':
        return AppColors.warning;
      case 'Vencida':
        return AppColors.emergency;
      default:
        return AppColors.gray600;
    }
  }
}
