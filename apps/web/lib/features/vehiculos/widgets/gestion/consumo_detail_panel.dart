import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/consumo_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del registro de consumo seleccionado
class ConsumoDetailPanel extends StatelessWidget {
  const ConsumoDetailPanel({
    required this.consumo,
    required this.vehiculos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ConsumoCombustibleEntity? consumo;
  final Map<String, VehiculoEntity> vehiculos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ConsumoCombustibleEntity? c = consumo;
    if (c == null) {
      return const GestionDetailEmpty(message: 'Selecciona un repostaje para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: '${consumoMatricula(c, vehiculos)} · ${GestionFormatters.fecha(c.fecha)}',
      badges: <Widget>[
        GestionDotLabel(label: combustibleLabel(c.tipoCombustible), color: combustibleColor(c.tipoCombustible)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _ConsumoGeneralTab(consumo: c, vehiculo: vehiculos[c.vehiculoId]),
        ),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _ConsumoGeneralTab extends StatelessWidget {
  const _ConsumoGeneralTab({required this.consumo, required this.vehiculo});

  final ConsumoCombustibleEntity consumo;
  final VehiculoEntity? vehiculo;

  @override
  Widget build(BuildContext context) {
    final ConsumoCombustibleEntity c = consumo;
    final VehiculoEntity? v = vehiculo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: v?.matricula),
        GestionDetailField(label: 'Marca/Modelo', value: v == null ? null : '${v.marca} ${v.modelo}'),
        GestionDetailField(label: 'Km vehículo', value: flotaKm(c.kmVehiculo)),
        GestionDetailField(label: 'Km recorridos', value: _opt(flotaKm(c.kmRecorridosDesdeUltimo))),
        GestionDetailField(
          label: 'Consumo',
          child: c.consumoL100km == null
              ? null
              : FlotaCellText(
                  flotaDecimal(c.consumoL100km, sufijo: ' L/100km'),
                  bold: true,
                  color: consumoColor(c.consumoL100km!),
                ),
        ),
        const GestionDetailSection(title: 'Repostaje'),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(c.fecha)),
        GestionDetailField(label: 'Combustible', value: combustibleLabel(c.tipoCombustible)),
        GestionDetailField(label: 'Litros', value: flotaDecimal(c.litros, sufijo: ' L')),
        GestionDetailField(label: 'Precio litro', value: _opt(flotaDecimal2(c.precioLitro, sufijo: ' €/L'))),
        GestionDetailField(label: 'Coste total', value: GestionFormatters.moneda(c.costoTotal)),
        GestionDetailField(label: 'Estación', value: c.estacion),
        GestionDetailField(label: 'Ubicación', value: c.ubicacion),
        const GestionDetailSection(title: 'Pago'),
        GestionDetailField(label: 'Método', value: c.metodoPago),
        GestionDetailField(label: 'Tarjeta', value: c.numeroTarjetaCombustible),
        GestionDetailField(label: 'Nº ticket', value: c.numeroTicket),
        GestionDetailField(
          label: 'Ticket',
          value: c.ticketUrl == null || c.ticketUrl!.isEmpty ? null : 'Adjunto',
        ),
        const GestionDetailSection(title: 'Conductor'),
        GestionDetailField(label: 'Nombre', value: c.conductorNombre),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }

  static String? _opt(String s) => s == GestionFormatters.vacio ? null : s;
}
