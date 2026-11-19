import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/vestuario_state.dart';

/// Campos del formulario de solicitud (estado gestionado por el sheet)
class SolicitudFormCampos extends StatelessWidget {
  const SolicitudFormCampos({
    required this.state,
    required this.tipo,
    required this.actual,
    required this.prenda,
    required this.talla,
    required this.cantidad,
    required this.motivo,
    required this.motivoObligatorio,
    required this.foto,
    required this.onTipo,
    required this.onActual,
    required this.onPrenda,
    required this.onTalla,
    required this.onCantidad,
    required this.onMotivo,
    required this.onFoto,
    required this.onQuitarFoto,
    super.key,
  });

  final VestuarioState state;
  final TipoSolicitudVestuario tipo;
  final VestuarioEntity? actual;
  final String? prenda;
  final String? talla;
  final int cantidad;
  final TextEditingController motivo;
  final bool motivoObligatorio;
  final Uint8List? foto;
  final ValueChanged<TipoSolicitudVestuario> onTipo;
  final ValueChanged<VestuarioEntity?> onActual;
  final ValueChanged<String?> onPrenda;
  final ValueChanged<String?> onTalla;
  final ValueChanged<int> onCantidad;
  final VoidCallback onMotivo;
  final VoidCallback onFoto;
  final VoidCallback onQuitarFoto;

  /// Prendas que puede sustituir/devolver (sin solicitudes en curso)
  List<VestuarioEntity> get _prendasPropias => state.prendasActivas
      .where((VestuarioEntity p) => !state.tieneSolicitudAbierta(p.id) || p.id == actual?.id)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: <Widget>[
        const _Titulo('Qué necesitas'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final TipoSolicitudVestuario t in TipoSolicitudVestuario.values)
              ChoiceChip(
                label: Text(t.label),
                selected: tipo == t,
                onSelected: t.requierePrendaActual && state.prendasActivas.isEmpty ? null : (_) => onTipo(t),
              ),
          ],
        ),
        if (tipo.requierePrendaActual) ...<Widget>[
          const _Titulo('Prenda que tienes'),
          DropdownButtonFormField<String>(
            initialValue: actual?.id,
            isExpanded: true,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.checkroom_outlined)),
            hint: const Text('Elige la prenda'),
            items: <DropdownMenuItem<String>>[
              for (final VestuarioEntity p in _prendasPropias)
                DropdownMenuItem<String>(value: p.id, child: Text('${p.prenda.toUpperCase()} · Talla ${p.talla}')),
            ],
            onChanged: (String? id) => onActual(_prendasPropias.where((VestuarioEntity p) => p.id == id).firstOrNull),
          ),
        ] else ...<Widget>[
          const _Titulo('Prenda'),
          _SelectorPrenda(opciones: state.prendasCatalogo, valor: prenda, onChanged: onPrenda),
        ],
        if (tipo.entregaPrenda && prenda != null) ...<Widget>[
          _Titulo(tipo == TipoSolicitudVestuario.cambioTalla ? 'Nueva talla' : 'Talla'),
          _SelectorTalla(opciones: state.tallasDe(prenda!), valor: talla, onChanged: onTalla),
          const _Titulo('Cantidad'),
          _Cantidad(valor: cantidad, onChanged: onCantidad),
        ],
        _Titulo(motivoObligatorio ? 'Motivo (obligatorio)' : 'Comentario (opcional)'),
        TextField(
          controller: motivo,
          onChanged: (_) => onMotivo(),
          maxLines: 2,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: tipo == TipoSolicitudVestuario.reposicion ? 'Ej: cremallera rota, muy desgastada...' : '',
          ),
        ),
        const SizedBox(height: 8),
        if (foto == null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onFoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Añadir foto (opcional)'),
            ),
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(foto!, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: const Text('Foto añadida'),
            trailing: IconButton(
              onPressed: onQuitarFoto,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600, letterSpacing: 0.8),
      ),
    );
  }
}

/// Prendas del almacén; si el catálogo está vacío se escribe a mano
class _SelectorPrenda extends StatelessWidget {
  const _SelectorPrenda({required this.opciones, required this.valor, required this.onChanged});

  final List<String> opciones;
  final String? valor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (opciones.isEmpty) {
      return TextFormField(
        initialValue: valor,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: 'Ej: PANTALÓN, POLO...'),
        onChanged: (String v) => onChanged(v.trim().isEmpty ? null : v.trim().toUpperCase()),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: opciones.contains(valor) ? valor : null,
      isExpanded: true,
      hint: const Text('Elige la prenda'),
      decoration: const InputDecoration(prefixIcon: Icon(Icons.checkroom_outlined)),
      items: <DropdownMenuItem<String>>[
        for (final String p in opciones) DropdownMenuItem<String>(value: p, child: Text(p)),
      ],
      onChanged: onChanged,
    );
  }
}

/// Tallas disponibles en almacén (se indica si no hay unidades); a mano si no hay catálogo
class _SelectorTalla extends StatelessWidget {
  const _SelectorTalla({required this.opciones, required this.valor, required this.onChanged});

  final List<PrendaCatalogoEntity> opciones;
  final String? valor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (opciones.isEmpty) {
      return TextFormField(
        key: ValueKey<String?>(valor),
        initialValue: valor,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: 'Ej: L, 42...'),
        onChanged: (String v) => onChanged(v.trim().isEmpty ? null : v.trim().toUpperCase()),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final PrendaCatalogoEntity c in opciones)
          ChoiceChip(
            label: Text(c.disponible > 0 ? c.talla : '${c.talla} (agotada)'),
            selected: valor?.toUpperCase() == c.talla.toUpperCase(),
            onSelected: (_) => onChanged(c.talla),
          ),
      ],
    );
  }
}

class _Cantidad extends StatelessWidget {
  const _Cantidad({required this.valor, required this.onChanged});

  final int valor;
  final ValueChanged<int> onChanged;

  static const int _maximo = 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton.outlined(
          onPressed: valor > 1 ? () => onChanged(valor - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$valor',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.outlined(
          onPressed: valor < _maximo ? () => onChanged(valor + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
