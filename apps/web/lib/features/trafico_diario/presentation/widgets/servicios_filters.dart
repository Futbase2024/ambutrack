import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/resizable_data_table.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/filtro_dropdown_widget.dart';
import 'package:flutter/material.dart';

/// Fila de filtros tipo Excel para la tabla de servicios
///
/// Incluye:
/// - Checkbox para seleccionar/deseleccionar todos
/// - Filtros dropdown por columna
/// - TextField de búsqueda en línea
class ServiciosFilters {
  const ServiciosFilters({
    required this.traslados,
    required this.trasladosFiltrados,
    required this.trasladosSeleccionados,
    required this.filtrosActivos,
    required this.filtroTextControllers,
    required this.serviciosPorTraslado,
    required this.localidadesPorId,
    required this.personalPorId,
    required this.localidadesPorNombreHospital,
    required this.onFilterChanged,
    required this.onSelectionChanged,
  });

  final List<TrasladoEntity> traslados;
  final List<TrasladoEntity> trasladosFiltrados;
  final Set<String> trasladosSeleccionados;
  final Map<String, Set<String>> filtrosActivos;
  final Map<String, TextEditingController> filtroTextControllers;
  final Map<String, ServicioEntity> serviciosPorTraslado;
  final Map<String, String> localidadesPorId;
  final Map<String, String> personalPorId;
  final Map<String, String> localidadesPorNombreHospital;
  final ValueChanged<Map<String, Set<String>>> onFilterChanged;
  final ValueChanged<Set<String>> onSelectionChanged;

  DataTableRow build() {
    return DataTableRow(
      cells: <DataTableCell>[
        // Checkbox para seleccionar/deseleccionar todos
        DataTableCell(
          child: Checkbox(
            value: trasladosSeleccionados.length == trasladosFiltrados.length && trasladosFiltrados.isNotEmpty,
            onChanged: (bool? value) {
              if (value == true) {
                onSelectionChanged(trasladosFiltrados.map((TrasladoEntity t) => t.id).toSet());
              } else {
                onSelectionChanged(<String>{});
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          alignment: Alignment.center,
        ),
        // I/V
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'tipoTraslado',
            valores: _obtenerValoresUnicos('tipoTraslado'),
            seleccionados: filtrosActivos['tipoTraslado'] ?? <String>{},
            controller: _getController('tipoTraslado'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('tipoTraslado', nuevosSeleccionados);
            },
          ),
          alignment: Alignment.center,
        ),
        // H. Prog. - sin filtro
        const DataTableCell(child: SizedBox.shrink()),
        // Paciente
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'paciente',
            valores: _obtenerValoresUnicos('paciente'),
            seleccionados: filtrosActivos['paciente'] ?? <String>{},
            controller: _getController('paciente'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('paciente', nuevosSeleccionados);
            },
          ),
        ),
        // Dom. Origen - sin filtro
        const DataTableCell(child: SizedBox.shrink()),
        // Loc. Origen
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'localidadOrigen',
            valores: _obtenerValoresUnicos('localidadOrigen'),
            seleccionados: filtrosActivos['localidadOrigen'] ?? <String>{},
            controller: _getController('localidadOrigen'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('localidadOrigen', nuevosSeleccionados);
            },
          ),
        ),
        // Origen
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'origen',
            valores: _obtenerValoresUnicos('origen'),
            seleccionados: filtrosActivos['origen'] ?? <String>{},
            controller: _getController('origen'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('origen', nuevosSeleccionados);
            },
          ),
        ),
        // Dom. Destino - sin filtro
        const DataTableCell(child: SizedBox.shrink()),
        // Loc. Dest
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'localidadDestino',
            valores: _obtenerValoresUnicos('localidadDestino'),
            seleccionados: filtrosActivos['localidadDestino'] ?? <String>{},
            controller: _getController('localidadDestino'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('localidadDestino', nuevosSeleccionados);
            },
          ),
        ),
        // Destino
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'destino',
            valores: _obtenerValoresUnicos('destino'),
            seleccionados: filtrosActivos['destino'] ?? <String>{},
            controller: _getController('destino'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('destino', nuevosSeleccionados);
            },
          ),
        ),
        // Terapia
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'terapia',
            valores: _obtenerValoresUnicos('terapia'),
            seleccionados: filtrosActivos['terapia'] ?? <String>{},
            controller: _getController('terapia'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('terapia', nuevosSeleccionados);
            },
          ),
        ),
        // Estado
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'estatus',
            valores: _obtenerValoresUnicos('estatus'),
            seleccionados: filtrosActivos['estatus'] ?? <String>{},
            controller: _getController('estatus'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('estatus', nuevosSeleccionados);
            },
          ),
          alignment: Alignment.center,
        ),
        // Conductor
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'conductor',
            valores: _obtenerValoresUnicos('conductor'),
            seleccionados: filtrosActivos['conductor'] ?? <String>{},
            controller: _getController('conductor'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('conductor', nuevosSeleccionados);
            },
          ),
        ),
        // Requisitos - sin filtro (4 columnas: SIC, CA, Ayu, Ac)
        ...List<DataTableCell>.generate(4, (_) => const DataTableCell(child: SizedBox.shrink(), alignment: Alignment.center)),
        // Matrícula
        DataTableCell(
          child: FiltroDropdownWidget(
            columna: 'matricula',
            valores: _obtenerValoresUnicos('matricula'),
            seleccionados: filtrosActivos['matricula'] ?? <String>{},
            controller: _getController('matricula'),
            onChanged: (Set<String> nuevosSeleccionados) {
              _actualizarFiltro('matricula', nuevosSeleccionados);
            },
          ),
        ),
        // Horas cronológicas - sin filtro (6 columnas: H. Env, H. Rec, H. Org, H. Sal, H. Dst, H. Fin)
        ...List<DataTableCell>.generate(6, (_) => const DataTableCell(child: SizedBox.shrink(), alignment: Alignment.center)),
      ],
    );
  }

  TextEditingController _getController(String columna) {
    return filtroTextControllers.putIfAbsent(
      columna,
      TextEditingController.new,
    );
  }

  void _actualizarFiltro(String columna, Set<String> nuevosSeleccionados) {
    final Map<String, Set<String>> nuevosFiltros = Map<String, Set<String>>.from(filtrosActivos);

    if (nuevosSeleccionados.isEmpty) {
      nuevosFiltros.remove(columna);
      _getController(columna).clear();
    } else {
      nuevosFiltros[columna] = nuevosSeleccionados;
    }

    onFilterChanged(nuevosFiltros);
  }

  Set<String> _obtenerValoresUnicos(String columna) {
    final Set<String> valores = <String>{};

    for (final TrasladoEntity traslado in traslados) {
      final ServicioEntity? servicio = serviciosPorTraslado[traslado.id];
      String valor = '';

      switch (columna) {
        case 'tipoTraslado':
          valor = traslado.tipoTraslado.toUpperCase();
          break;
        case 'paciente':
          if (servicio?.paciente != null) {
            valor = '${servicio!.paciente!.nombre} ${servicio.paciente!.primerApellido}';
          }
          break;
        case 'localidadOrigen':
          if (traslado.tipoOrigen == 'domicilio_paciente') {
            valor = servicio?.paciente?.localidadId != null
                ? (localidadesPorId[servicio!.paciente!.localidadId!] ?? '')
                : '';
          } else if (traslado.origen != null && traslado.origen!.isNotEmpty) {
            valor = localidadesPorNombreHospital[traslado.origen!] ?? '';
          }
          break;
        case 'origen':
          valor = traslado.tipoOrigen == 'centro_hospitalario' &&
                  traslado.origen != null &&
                  traslado.origen!.isNotEmpty
              ? traslado.origen!
              : 'DOMICILIO';
          break;
        case 'localidadDestino':
          if (traslado.tipoDestino == 'domicilio_paciente') {
            valor = servicio?.paciente?.localidadId != null
                ? (localidadesPorId[servicio!.paciente!.localidadId!] ?? '')
                : '';
          } else if (traslado.destino != null && traslado.destino!.isNotEmpty) {
            valor = localidadesPorNombreHospital[traslado.destino!] ?? '';
          }
          break;
        case 'destino':
          valor = traslado.tipoDestino == 'centro_hospitalario' &&
                  traslado.destino != null &&
                  traslado.destino!.isNotEmpty
              ? traslado.destino!
              : 'DOMICILIO';
          break;
        case 'terapia':
          valor = servicio?.motivoTraslado?.nombre ?? '';
          break;
        case 'estatus':
          valor = traslado.estado.name;
          break;
        case 'conductor':
          valor = traslado.idConductor != null
              ? (personalPorId[traslado.idConductor!] ?? '')
              : '';
          break;
        case 'matricula':
          valor = traslado.matriculaVehiculo ?? '';
          break;
      }

      if (valor.isNotEmpty) {
        valores.add(valor);
      }
    }

    return valores;
  }
}
