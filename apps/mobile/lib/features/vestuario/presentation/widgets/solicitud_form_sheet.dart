import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/vestuario_cubit.dart';
import '../cubit/vestuario_state.dart';
import 'solicitud_form_campos.dart';

/// Abre el formulario de solicitud. [prendaActual]/[tipo] vienen de "Mis prendas"
Future<NuevaSolicitudVestuario?> showSolicitudFormSheet(
  BuildContext context, {
  required VestuarioState state,
  TipoSolicitudVestuario tipo = TipoSolicitudVestuario.nueva,
  VestuarioEntity? prendaActual,
}) {
  return showModalBottomSheet<NuevaSolicitudVestuario>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SolicitudFormSheet(state: state, tipoInicial: tipo, prendaInicial: prendaActual),
  );
}

class _SolicitudFormSheet extends StatefulWidget {
  const _SolicitudFormSheet({required this.state, required this.tipoInicial, this.prendaInicial});

  final VestuarioState state;
  final TipoSolicitudVestuario tipoInicial;
  final VestuarioEntity? prendaInicial;

  @override
  State<_SolicitudFormSheet> createState() => _SolicitudFormSheetState();
}

class _SolicitudFormSheetState extends State<_SolicitudFormSheet> {
  late TipoSolicitudVestuario _tipo = widget.tipoInicial;
  late VestuarioEntity? _actual = widget.prendaInicial;
  late String? _prenda = widget.prendaInicial?.prenda.toUpperCase();
  String? _talla;
  int _cantidad = 1;
  final TextEditingController _motivo = TextEditingController();
  Uint8List? _foto;

  @override
  void initState() {
    super.initState();
    _talla = _tallaSugerida();
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  /// Reposición: misma talla. Resto: la talla registrada del trabajador
  String? _tallaSugerida() {
    final String? prenda = _prenda;
    if (prenda == null) {
      return null;
    }
    if (_tipo == TipoSolicitudVestuario.reposicion && _actual != null) {
      return _actual!.talla.toUpperCase();
    }
    return widget.state.tallas?.tallaPara(prenda);
  }

  void _cambiarTipo(TipoSolicitudVestuario tipo) => setState(() {
    _tipo = tipo;
    if (!tipo.requierePrendaActual) {
      _actual = null;
    }
    _talla = _tallaSugerida();
  });

  void _cambiarActual(VestuarioEntity? prenda) => setState(() {
    _actual = prenda;
    _prenda = prenda?.prenda.toUpperCase();
    _cantidad = prenda?.cantidad ?? 1;
    _talla = _tallaSugerida();
  });

  void _cambiarPrenda(String? prenda) => setState(() {
    _prenda = prenda;
    _talla = _tallaSugerida();
  });

  Future<void> _hacerFoto() async {
    try {
      final XFile? f = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1280, imageQuality: 70);
      if (f != null) {
        final Uint8List bytes = await f.readAsBytes();
        setState(() => _foto = bytes);
      }
    } catch (e) {
      debugPrint('⚠️ [SolicitudVestuario] Foto no disponible: $e');
    }
  }

  bool get _motivoObligatorio =>
      _tipo == TipoSolicitudVestuario.reposicion || _tipo == TipoSolicitudVestuario.cambioTalla;

  bool get _valido {
    if (_prenda == null || _prenda!.trim().isEmpty) {
      return false;
    }
    if (_tipo.requierePrendaActual && _actual == null) {
      return false;
    }
    if (_tipo.entregaPrenda && (_talla == null || _talla!.trim().isEmpty)) {
      return false;
    }
    return !_motivoObligatorio || _motivo.text.trim().isNotEmpty;
  }

  void _enviar() {
    Navigator.of(context).pop(
      NuevaSolicitudVestuario(
        tipo: _tipo,
        prenda: _prenda!,
        talla: _tipo.entregaPrenda ? _talla : _actual?.talla,
        cantidad: _cantidad,
        motivo: _motivo.text,
        vestuarioId: _actual?.id,
        foto: _foto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _Cabecera(),
              Flexible(
                child: SolicitudFormCampos(
                  state: widget.state,
                  tipo: _tipo,
                  actual: _actual,
                  prenda: _prenda,
                  talla: _talla,
                  cantidad: _cantidad,
                  motivo: _motivo,
                  motivoObligatorio: _motivoObligatorio,
                  foto: _foto,
                  onTipo: _cambiarTipo,
                  onActual: _cambiarActual,
                  onPrenda: _cambiarPrenda,
                  onTalla: (String? t) => setState(() => _talla = t),
                  onCantidad: (int c) => setState(() => _cantidad = c),
                  onMotivo: () => setState(() {}),
                  onFoto: _hacerFoto,
                  onQuitarFoto: () => setState(() => _foto = null),
                ),
              ),
              _Botones(valido: _valido, onEnviar: _enviar),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.checkroom_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 12),
          Text('Solicitud de vestuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Botones extends StatelessWidget {
  const _Botones({required this.valido, required this.onEnviar});

  final bool valido;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: valido ? onEnviar : null,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Enviar solicitud'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: forma),
            ),
          ),
        ],
      ),
    );
  }
}
