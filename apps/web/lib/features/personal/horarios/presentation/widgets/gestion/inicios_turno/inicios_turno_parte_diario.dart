import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_pdf/ambutrack_pdf.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/horarios/data/repositories/parte_diario_pdf_repository_impl.dart';
import 'package:flutter/material.dart';

/// Impresión de partes diarios (PDF) desde la pantalla de inicios de turno
mixin IniciosTurnoParteDiario<T extends StatefulWidget> on State<T> {
  final ParteDiarioGenerador _generador = ParteDiarioGenerador(ParteDiarioPdfRepositoryImpl());

  static DateTime _diaDe(InicioTurnoEntity i) {
    final DateTime d = (i.createdAt ?? DateTime.now()).toLocal();
    return DateTime(d.year, d.month, d.day);
  }

  static String _nombre(InicioTurnoEntity i) => (i.personalNombre ?? '').trim();

  /// Parte diario de la persona del inicio seleccionado (su día completo)
  Future<void> imprimirParteDiario(InicioTurnoEntity inicio) {
    final DateTime dia = _diaDe(inicio);
    return _generar(
      mensaje: 'Generando parte diario...',
      nombreArchivo: ParteDiarioPdf.nombreArchivo(persona: _nombre(inicio), dia: dia),
      carga: () => _generador.cargar(
        personalId: inicio.personalId,
        personalNombre: _nombre(inicio),
        dia: dia,
        empresaId: inicio.empresaId,
      ),
    );
  }

  /// Partes diarios de todas las personas que iniciaron turno el mismo día
  Future<void> imprimirPartesDelDia(InicioTurnoEntity referencia, List<InicioTurnoEntity> todos) {
    final DateTime dia = _diaDe(referencia);
    final Map<String, String> personas = <String, String>{
      for (final InicioTurnoEntity i in todos)
        if (_diaDe(i) == dia) i.personalId: _nombre(i),
    };
    final List<({String id, String nombre})> ordenadas = personas.entries
        .map((MapEntry<String, String> e) => (id: e.key, nombre: e.value))
        .toList()
      ..sort((({String id, String nombre}) a, ({String id, String nombre}) b) => a.nombre.compareTo(b.nombre));
    return _generar(
      mensaje: 'Generando ${ordenadas.length} partes diarios...',
      nombreArchivo: ParteDiarioPdf.nombreArchivo(persona: 'todos', dia: dia),
      carga: () => _generador.cargarVarios(personas: ordenadas, dia: dia, empresaId: referencia.empresaId),
    );
  }

  Future<void> _generar({
    required String mensaje,
    required String nombreArchivo,
    required Future<List<ParteDiarioData>> Function() carga,
  }) async {
    final NavigatorState navigator = Navigator.of(context);
    bool overlayAbierto = true;
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => AppLoadingOverlay(
        message: mensaje,
        color: AppColors.primary,
        icon: Icons.picture_as_pdf_outlined,
      ),
    ));
    try {
      final List<ParteDiarioData> partes = await carga();
      navigator.pop();
      overlayAbierto = false;
      await ParteDiarioPdf.imprimir(partes, nombreArchivo: nombreArchivo);
    } catch (e) {
      debugPrint('❌ IniciosTurnoParteDiario: error al generar el parte: $e');
      if (overlayAbierto) {
        navigator.pop();
      }
      if (mounted) {
        await showResultDialog(
          context: context,
          title: 'Error al generar el parte',
          message: 'No se pudo generar el PDF del parte diario.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }
}
