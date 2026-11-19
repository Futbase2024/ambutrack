import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de usuario (crear y editar)
class UsuarioFormData {
  UsuarioFormData({UserEntity? original})
      : dni = TextEditingController(text: original?.dni ?? ''),
        nombre = TextEditingController(text: _extractNombre(original?.displayName)),
        apellidos = TextEditingController(text: _extractApellidos(original?.displayName)),
        email = TextEditingController(text: original?.email ?? ''),
        telefono = TextEditingController(text: original?.phoneNumber ?? ''),
        password = TextEditingController(),
        rol = original?.rol,
        empresaId = original?.empresaId,
        activo = original?.activo ?? true;

  final TextEditingController dni;
  final TextEditingController nombre;
  final TextEditingController apellidos;
  final TextEditingController email;
  final TextEditingController telefono;
  final TextEditingController password;

  String? rol;
  String? empresaId;
  bool activo;
  bool passwordVisible = false;

  /// Tipo de clave provisional: true = PIN de 6 dígitos (app móvil), false = contraseña web
  bool pinMovil = true;

  String get displayName => '${nombre.text.trim()} ${apellidos.text.trim()}';
  String? get telefonoValue => telefono.text.trim().isEmpty ? null : telefono.text.trim();

  /// Extrae el nombre del displayName (primera palabra)
  static String _extractNombre(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return '';
    }
    final List<String> parts = displayName.split(' ');
    return parts.isNotEmpty ? parts[0] : '';
  }

  /// Extrae los apellidos del displayName (palabras después de la primera)
  static String _extractApellidos(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return '';
    }
    final List<String> parts = displayName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// Genera una contraseña segura aleatoria de 12 caracteres
  static String generarPassword() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random rnd = Random.secure();
    return String.fromCharCodes(
      Iterable<int>.generate(12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  /// Genera un PIN de 6 dígitos (clave de la app móvil)
  static String generarPin() {
    final Random rnd = Random.secure();
    return List<String>.generate(6, (_) => '${rnd.nextInt(10)}').join();
  }

  void dispose() {
    dni.dispose();
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    telefono.dispose();
    password.dispose();
  }
}

/// Validaciones del formulario de usuario
class UsuarioFormValidators {
  const UsuarioFormValidators._();

  static String? nombre(String? value) =>
      (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null;

  static String? apellidos(String? value) =>
      (value == null || value.isEmpty) ? 'Los apellidos son obligatorios' : null;

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  /// PIN de la app móvil: exactamente 6 dígitos
  static String? pin(String? value) {
    if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'El PIN debe tener exactamente 6 dígitos';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida formato de DNI español
  static String? dni(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es obligatorio';
    }
    final String dniUpper = value.toUpperCase().trim();
    final RegExp dniRegex = RegExp(r'^\d{8}[A-Z]$');
    if (!dniRegex.hasMatch(dniUpper)) {
      return 'Formato de DNI inválido (8 dígitos + letra)';
    }
    const String letras = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final int numero = int.parse(dniUpper.substring(0, 8));
    final String letra = dniUpper[8];
    if (letras[numero % 23] != letra) {
      return 'La letra del DNI no es correcta';
    }
    return null;
  }

  /// Formatea el nombre del rol: 'jefe_personal' → 'Jefe Personal'
  static String rolLabel(String rolName) {
    return rolName
        .split('_')
        .map((String word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : word)
        .join(' ');
  }
}
