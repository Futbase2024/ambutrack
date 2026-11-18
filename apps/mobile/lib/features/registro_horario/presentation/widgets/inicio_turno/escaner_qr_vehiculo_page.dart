import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/theme/app_colors.dart';

/// Abre la cámara para leer el QR del vehículo. Devuelve el texto leído o null
Future<String?> escanearQrVehiculo(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(builder: (_) => const EscanerQrVehiculoPage(), fullscreenDialog: true),
  );
}

/// Pantalla de escaneo del QR pegado en el vehículo
class EscanerQrVehiculoPage extends StatefulWidget {
  const EscanerQrVehiculoPage({super.key});

  @override
  State<EscanerQrVehiculoPage> createState() => _EscanerQrVehiculoPageState();
}

class _EscanerQrVehiculoPageState extends State<EscanerQrVehiculoPage> {
  final MobileScannerController _controller = MobileScannerController(formats: <BarcodeFormat>[BarcodeFormat.qrCode]);
  bool _leido = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture captura) {
    if (_leido) {
      return;
    }
    for (final Barcode codigo in captura.barcodes) {
      final String? valor = codigo.rawValue;
      if (valor != null && valor.isNotEmpty) {
        _leido = true;
        Navigator.of(context).pop(valor);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear vehículo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: 'Linterna',
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Text(
                'Apunta al código QR pegado en el salpicadero de la ambulancia',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
