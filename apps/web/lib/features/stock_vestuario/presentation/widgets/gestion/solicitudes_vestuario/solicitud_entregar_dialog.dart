import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitud_vestuario_dialogs.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_columns.dart';
import 'package:flutter/material.dart';

/// Opciones elegidas en el diálogo de entrega
class EntregaSolicitudVestuario {
  const EntregaSolicitudVestuario({required this.stock, required this.devolverAStock});

  /// Fila de almacén desde la que se entrega (null en devoluciones)
  final StockVestuarioEntity? stock;

  /// La prenda antigua vuelve al almacén (null si no hay prenda antigua)
  final bool? devolverAStock;
}

/// Filas de stock activas de la misma prenda (sin distinguir mayúsculas)
List<StockVestuarioEntity> stockDePrenda(List<StockVestuarioEntity> stock, String prenda) {
  final String p = prenda.trim().toLowerCase();
  return stock.where((StockVestuarioEntity s) => s.activo && s.prenda.trim().toLowerCase() == p).toList()
    ..sort((StockVestuarioEntity a, StockVestuarioEntity b) => a.talla.compareTo(b.talla));
}

/// Pide la fila de stock y el destino de la prenda antigua. Null si se cancela.
Future<EntregaSolicitudVestuario?> pedirDatosEntrega(
  BuildContext context, {
  required SolicitudVestuarioEntity solicitud,
  required List<StockVestuarioEntity> stock,
}) {
  return showDialog<EntregaSolicitudVestuario>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) =>
        _EntregarDialog(solicitud: solicitud, opciones: stockDePrenda(stock, solicitud.prenda)),
  );
}

class _EntregarDialog extends StatefulWidget {
  const _EntregarDialog({required this.solicitud, required this.opciones});

  final SolicitudVestuarioEntity solicitud;
  final List<StockVestuarioEntity> opciones;

  @override
  State<_EntregarDialog> createState() => _EntregarDialogState();
}

class _EntregarDialogState extends State<_EntregarDialog> {
  StockVestuarioEntity? _stock;
  late bool _devolver;

  SolicitudVestuarioEntity get _s => widget.solicitud;

  bool _suficiente(StockVestuarioEntity st) => st.cantidadDisponible >= _s.cantidad;

  @override
  void initState() {
    super.initState();
    _devolver = _s.tipo != TipoSolicitudVestuario.reposicion;
    final String talla = (_s.talla ?? '').trim().toLowerCase();
    for (final StockVestuarioEntity st in widget.opciones) {
      if (st.talla.trim().toLowerCase() == talla && _suficiente(st)) {
        _stock = st;
        break;
      }
    }
  }

  void _confirmar() {
    Navigator.of(context).pop(
      EntregaSolicitudVestuario(
        stock: _s.tipo.entregaPrenda ? _stock : null,
        devolverAStock: _s.tipo.requierePrendaActual ? _devolver : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool entrega = _s.tipo.entregaPrenda;
    final bool puedeConfirmar = !entrega || _stock != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _EntregaCabecera(solicitud: _s),
                const SizedBox(height: 16),
                if (entrega)
                  Flexible(
                    child: _StockOpciones(
                      opciones: widget.opciones,
                      seleccionada: _stock,
                      cantidad: _s.cantidad,
                      onSelect: (StockVestuarioEntity st) => setState(() => _stock = st),
                    ),
                  )
                else
                  const _Aviso(texto: 'En una devolución no se entrega ninguna prenda del almacén.'),
                if (_s.tipo.requierePrendaActual)
                  _DevolverSwitch(value: _devolver, onChanged: (bool v) => setState(() => _devolver = v)),
                const SizedBox(height: 20),
                VestuarioDialogButtons(
                  confirmText: entrega ? 'Entregar' : 'Registrar',
                  color: AppColors.success,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: puedeConfirmar ? _confirmar : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntregaCabecera extends StatelessWidget {
  const _EntregaCabecera({required this.solicitud});

  final SolicitudVestuarioEntity solicitud;

  @override
  Widget build(BuildContext context) {
    final SolicitudVestuarioEntity s = solicitud;
    final bool entrega = s.tipo.entregaPrenda;
    return Column(
      children: <Widget>[
        VestuarioDialogIcon(
          icon: entrega ? Icons.local_shipping_outlined : Icons.assignment_return_outlined,
          color: AppColors.success,
        ),
        const SizedBox(height: 20),
        Text(
          entrega ? 'Entregar prenda' : 'Registrar devolución',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        const SizedBox(height: 12),
        Text(
          '${GestionFormatters.texto(s.personalNombre)} · ${tipoSolicitudCorto(s.tipo)}\n'
          '${s.prenda} · Talla ${GestionFormatters.texto(s.talla)} · ${s.cantidad} ud.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
        ),
      ],
    );
  }
}

class _DevolverSwitch extends StatelessWidget {
  const _DevolverSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.success,
      value: value,
      onChanged: onChanged,
      title: const Text('La prenda antigua vuelve al almacén', style: TextStyle(fontSize: 14)),
      subtitle: Text(
        value ? 'Se suma de nuevo al stock disponible' : 'Se da de baja (desgaste o rotura)',
        style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
      ),
    );
  }
}

class _StockOpciones extends StatelessWidget {
  const _StockOpciones({
    required this.opciones,
    required this.seleccionada,
    required this.cantidad,
    required this.onSelect,
  });

  final List<StockVestuarioEntity> opciones;
  final StockVestuarioEntity? seleccionada;
  final int cantidad;
  final ValueChanged<StockVestuarioEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    if (opciones.isEmpty) {
      return const _Aviso(texto: 'No hay artículos de almacén activos para esta prenda. Da de alta el stock primero.');
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: opciones.length,
        separatorBuilder: (BuildContext _, int __) => const Divider(height: 1, color: AppColors.gray100),
        itemBuilder: (BuildContext _, int i) {
          final StockVestuarioEntity st = opciones[i];
          final bool habilitada = st.cantidadDisponible >= cantidad;
          return _StockFila(
            stock: st,
            seleccionada: st.id == seleccionada?.id,
            onTap: habilitada ? () => onSelect(st) : null,
          );
        },
      ),
    );
  }
}

class _StockFila extends StatelessWidget {
  const _StockFila({required this.stock, required this.seleccionada, required this.onTap});

  final StockVestuarioEntity stock;
  final bool seleccionada;

  /// null = sin disponible suficiente
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool habilitada = onTap != null;
    final Color texto = habilitada ? AppColors.gray900 : AppColors.gray300;
    final String detalle = <String?>[stock.marca, stock.color]
        .where((String? v) => v != null && v.trim().isNotEmpty)
        .join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              seleccionada ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: seleccionada ? AppColors.success : (habilitada ? AppColors.gray500 : AppColors.gray300),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text('Talla ${stock.talla}', style: TextStyle(fontWeight: FontWeight.w600, color: texto)),
            ),
            Expanded(
              child: Text(
                detalle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: habilitada ? AppColors.gray600 : AppColors.gray300),
              ),
            ),
            SolicitudVestuarioBadge(
              label: 'Disponible ${stock.cantidadDisponible}',
              color: habilitada ? AppColors.success : AppColors.error,
              inCell: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.gray700)),
    );
  }
}
