import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:flutter/material.dart';

/// Valor "sin filtro" de los desplegables
const String _todos = '';

/// Barra de filtros de la auditoría.
///
/// La búsqueda es en cliente; tabla, acción, usuario y fechas se aplican en servidor.
class AuditoriaFilters extends StatelessWidget {
  const AuditoriaFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.filtros,
    required this.usuarios,
    required this.registros,
    required this.onFiltrosChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final AuditoriaFiltros filtros;
  final List<UserEntity> usuarios;
  final List<AuditLogEntity> registros;
  final ValueChanged<AuditoriaFiltros> onFiltrosChanged;
  final VoidCallback? onClear;

  AuditoriaFiltros _con({
    String? tabla,
    String? accion,
    String? usuarioId,
    DateTimeRange? rango,
    bool cambiaRango = false,
  }) {
    final DateTimeRange? r = cambiaRango ? rango : _rangoActual;
    return AuditoriaFiltros(
      tabla: _nulo(tabla ?? filtros.tabla),
      accion: _nulo(accion ?? filtros.accion),
      usuarioId: _nulo(usuarioId ?? filtros.usuarioId),
      desde: r?.start,
      hasta: r?.end,
    );
  }

  static String? _nulo(String? v) => v == null || v.isEmpty ? null : v;

  DateTimeRange? get _rangoActual {
    final DateTime? d = filtros.desde;
    final DateTime? h = filtros.hasta;
    if (d == null && h == null) {
      return null;
    }
    return DateTimeRange(start: d ?? DateTime(2000), end: h ?? DateTime.now());
  }

  /// Usuarios de la empresa + emails presentes en los registros cargados
  Map<String, String> _opcionesUsuario() {
    final Map<String, String> porId = <String, String>{
      for (final AuditLogEntity e in registros)
        if (e.usuarioId != null) e.usuarioId!: auditoriaUsuarioLabel(e),
      for (final UserEntity u in usuarios)
        if (u.email.isNotEmpty) u.id: u.email,
    };
    final String? actual = filtros.usuarioId;
    if (actual != null && !porId.containsKey(actual)) {
      porId[actual] = 'Usuario seleccionado';
    }
    final List<MapEntry<String, String>> ordenadas = porId.entries.toList()
      ..sort((MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return <String, String>{_todos: 'Todos', for (final MapEntry<String, String> e in ordenadas) e.key: e.value};
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> controles = <Widget>[
      GestionSearchField(
        controller: searchController,
        onChanged: onSearchChanged,
        hint: 'Buscar registro, email, campo...',
        width: 240,
      ),
      GestionFilterDropdown<String>(
        label: 'Tabla',
        value: filtros.tabla ?? _todos,
        options: const <String, String>{_todos: 'Todas', ...auditoriaTablas},
        onChanged: (String v) => onFiltrosChanged(_con(tabla: v)),
      ),
      GestionFilterDropdown<String>(
        label: 'Acción',
        value: filtros.accion ?? _todos,
        options: const <String, String>{_todos: 'Todas', ...auditoriaAcciones},
        onChanged: (String v) => onFiltrosChanged(_con(accion: v)),
      ),
      GestionFilterDropdown<String>(
        label: 'Usuario',
        value: filtros.usuarioId ?? _todos,
        options: _opcionesUsuario(),
        onChanged: (String v) => onFiltrosChanged(_con(usuarioId: v)),
      ),
      TallerDateRangeFilter(
        rango: _rangoActual,
        onChanged: (DateTimeRange? r) => onFiltrosChanged(_con(rango: r, cambiaRango: true)),
      ),
      GestionClearFiltersButton(onPressed: onClear),
    ];
    return GestionFilterBar(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < controles.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 12),
                  controles[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
