part of '../turno_form_dialog.dart';

/// Cuerpo del formulario de turnos: secciones con etiquetas a la izquierda.
///
/// Lee y modifica el estado del diálogo ([s]); se reconstruye en cada setState.
class _TurnoFormBody extends StatelessWidget {
  const _TurnoFormBody({required this.s});

  final _TurnoFormDialogState s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Asignación', first: true),
        _AsignacionSection(s: s),
        const GestionFormSection(title: 'Horario'),
        _HorarioSection(s: s),
        const GestionFormSection(title: 'Otros datos'),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(
            controller: s._observacionesController,
            hint: 'Notas adicionales sobre el turno...',
            maxLines: 3,
          ),
        ),
        GestionFormRow(
          label: 'Estado',
          child: GestionSwitchField(
            value: s._activo,
            text: 'Turno activo',
            onChanged: s._setActivo,
          ),
        ),
      ],
    );
  }
}

/// Personal, contrato, base, dotación, función y vehículo
class _AsignacionSection extends StatelessWidget {
  const _AsignacionSection({required this.s});

  final _TurnoFormDialogState s;

  @override
  Widget build(BuildContext context) {
    final String nombre = s._nombrePersonalController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormRow(
          label: 'Personal',
          child: GestionFormReadOnly(value: nombre.isEmpty ? 'No asignado' : nombre),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Contrato',
              required: true,
              child: s._isLoadingContratos
                  ? const TurnoFormLoadingField()
                  : GestionDropdownField<String?>(
                      value: s._idContrato,
                      hint: 'Selecciona un contrato',
                      options: <GestionOption<String?>>[
                        const GestionOption<String?>(null, 'Sin contrato'),
                        ...s._contratosDisponibles.map(
                          (ContratoEntity c) => GestionOption<String?>(
                            c.id,
                            '${c.codigo} - ${c.descripcion ?? c.tipoContrato ?? 'Sin descripción'}',
                          ),
                        ),
                      ],
                      onChanged: (String? v) => s._setCatalogo(() => s._idContrato = v),
                    ),
            ),
            GestionFormRow(
              label: 'Base',
              child: s._isLoadingBases
                  ? const TurnoFormLoadingField()
                  : GestionDropdownField<String?>(
                      value: s._idBase,
                      hint: 'Selecciona una base',
                      options: <GestionOption<String?>>[
                        const GestionOption<String?>(null, 'Sin base'),
                        ...s._basesDisponibles.map(
                          (BaseCentroEntity b) => GestionOption<String?>(b.id, b.nombre),
                        ),
                      ],
                      onChanged: (String? v) => s._setCatalogo(() => s._idBase = v),
                    ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Dotación',
          child: s._isLoadingDotaciones
              ? const TurnoFormLoadingField()
              : GestionDropdownField<String?>(
                  value: s._idDotacion,
                  hint: 'Selecciona una dotación',
                  options: <GestionOption<String?>>[
                    const GestionOption<String?>(null, 'Sin dotación'),
                    ...s._dotacionesDisponibles.map(
                      (DotacionEntity d) => GestionOption<String?>(d.id, d.nombre),
                    ),
                  ],
                  onChanged: (String? v) => s._setCatalogo(() => s._idDotacion = v),
                ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Función',
              required: true,
              child: s._isLoadingCategorias
                  ? const TurnoFormLoadingField()
                  : GestionDropdownField<String?>(
                      value: s._categoriaPersonal,
                      hint: 'Selecciona la función',
                      options: <GestionOption<String?>>[
                        const GestionOption<String?>(null, 'Sin función'),
                        ...s._categoriasDisponibles.map(
                          (CategoriaPersonalEntity c) => GestionOption<String?>(c.categoria, c.categoria),
                        ),
                      ],
                      onChanged: (String? v) => s._setCatalogo(() => s._categoriaPersonal = v),
                    ),
            ),
            GestionFormRow(
              label: 'Vehículo',
              child: GestionSearchField<String>(
                value: s._idVehiculo,
                loading: s._isLoadingVehiculos,
                hint: 'Buscar por matrícula, modelo...',
                options: s._vehiculosDisponibles
                    .map((VehiculoEntity v) => GestionOption<String>(v.id, '${v.matricula} - ${v.modelo}'))
                    .toList(),
                onChanged: (String? v) => s._setCatalogo(() => s._idVehiculo = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tipo de turno, plantilla, fechas y horas
class _HorarioSection extends StatelessWidget {
  const _HorarioSection({required this.s});

  final _TurnoFormDialogState s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo de turno',
              required: true,
              child: TurnoTipoSelector(
                value: s._tipoTurno,
                enabled: s._idPlantillaSeleccionada == null,
                onSelected: s._onTipoTurnoSelected,
              ),
            ),
            GestionFormRow(
              label: 'Plantilla',
              child: s._isLoadingPlantillas
                  ? const TurnoFormLoadingField()
                  : GestionDropdownField<String?>(
                      value: s._idPlantillaSeleccionada,
                      hint: 'Selecciona una plantilla (opcional)',
                      options: <GestionOption<String?>>[
                        const GestionOption<String?>(null, 'Sin plantilla'),
                        ...s._plantillasDisponibles.map(
                          (PlantillaTurnoEntity p) => GestionOption<String?>(
                            p.id,
                            p.nombre,
                            color: TurnoFormUtils.parseHexColor(p.color),
                          ),
                        ),
                      ],
                      onChanged: s._onPlantillaChanged,
                    ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha inicio',
              required: true,
              child: TurnoFormDateField(
                value: s._fechaInicio,
                onTap: () => s._selectDate(context, isInicio: true),
              ),
            ),
            GestionFormRow(
              label: 'Fecha fin',
              required: true,
              child: TurnoFormDateField(
                value: s._fechaFin,
                onTap: () => s._selectDate(context, isInicio: false),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Hora inicio',
              required: true,
              child: TurnoHoraField(
                controller: s._horaInicioController,
                focusNode: s._horaInicioFocusNode,
                onEditingComplete: () => s._onHoraEditingComplete(s._horaInicioController),
              ),
            ),
            GestionFormRow(
              label: 'Hora fin',
              required: true,
              child: TurnoHoraField(
                controller: s._horaFinController,
                focusNode: s._horaFinFocusNode,
                onEditingComplete: () => s._onHoraEditingComplete(s._horaFinController),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
