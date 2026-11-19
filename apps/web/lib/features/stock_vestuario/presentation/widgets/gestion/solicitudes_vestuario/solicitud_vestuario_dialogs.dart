import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Diálogo con la foto adjunta a la solicitud (URL firmada temporal)
class SolicitudFotoDialog extends StatelessWidget {
  const SolicitudFotoDialog({required this.url, required this.titulo, super.key});

  /// Carga de la URL firmada
  final Future<String> url;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.photo_outlined, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.gray600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(child: _FotoBody(url: url)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FotoBody extends StatelessWidget {
  const _FotoBody({required this.url});

  final Future<String> url;

  static const Widget _cargando =
      SizedBox(height: 240, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: url,
      builder: (BuildContext context, AsyncSnapshot<String> snap) {
        if (snap.hasError) {
          return _FotoError(mensaje: '${snap.error}');
        }
        if (!snap.hasData) {
          return _cargando;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: InteractiveViewer(
            maxScale: 4,
            child: Image.network(
              snap.data!,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext _, Widget child, ImageChunkEvent? progress) =>
                  progress == null ? child : _cargando,
              errorBuilder: (BuildContext _, Object error, StackTrace? __) =>
                  const _FotoError(mensaje: 'No se pudo cargar la imagen'),
            ),
          ),
        );
      },
    );
  }
}

class _FotoError extends StatelessWidget {
  const _FotoError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.broken_image_outlined, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
        ],
      ),
    );
  }
}

/// Pide el motivo (obligatorio) del rechazo. Devuelve null si se cancela.
Future<String?> pedirMotivoRechazoSolicitud(BuildContext context, {required String trabajador}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) => _MotivoRechazoDialog(trabajador: trabajador),
  );
}

class _MotivoRechazoDialog extends StatefulWidget {
  const _MotivoRechazoDialog({required this.trabajador});

  final String trabajador;

  @override
  State<_MotivoRechazoDialog> createState() => _MotivoRechazoDialogState();
}

class _MotivoRechazoDialogState extends State<_MotivoRechazoDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _intentado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valido => _controller.text.trim().isNotEmpty;

  void _confirmar() {
    if (!_valido) {
      setState(() => _intentado = true);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const VestuarioDialogIcon(icon: Icons.cancel_outlined, color: AppColors.error),
                const SizedBox(height: 20),
                const Text(
                  'Rechazar solicitud',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Indica el motivo del rechazo. ${widget.trabajador} recibirá una notificación con él.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Motivo del rechazo',
                    errorText: _intentado && !_valido ? 'El motivo es obligatorio' : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                VestuarioDialogButtons(
                  confirmText: 'Continuar',
                  color: AppColors.error,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: _confirmar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icono grande circular de cabecera de diálogo profesional
class VestuarioDialogIcon extends StatelessWidget {
  const VestuarioDialogIcon({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 48, color: color),
    );
  }
}

/// Botones Cancelar / Confirmar de los diálogos profesionales
class VestuarioDialogButtons extends StatelessWidget {
  const VestuarioDialogButtons({
    required this.confirmText,
    required this.color,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final String confirmText;
  final Color color;
  final VoidCallback onCancel;

  /// null = botón deshabilitado
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: shape),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: shape,
            ),
            child: Text(confirmText),
          ),
        ),
      ],
    );
  }
}
