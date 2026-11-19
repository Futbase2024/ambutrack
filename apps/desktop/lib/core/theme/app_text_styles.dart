import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto centralizados de la aplicación AmbuTrack
///
/// Todos los TextStyles están precargados para optimizar rendimiento.
/// NUNCA usar `GoogleFonts.inter()` inline, SIEMPRE usar estos estilos.
///
/// **Rendimiento**:
/// - ✅ GoogleFonts se carga UNA sola vez al inicio
/// - ✅ TextStyles se reutilizan (sin crear objetos nuevos)
/// - ✅ Crítico en tablas y listas con muchos elementos
class AppTextStyles {
  AppTextStyles._();

  // === ESTILO BASE ===
  static final TextStyle _baseInter = GoogleFonts.inter();

  // ============================================================================
  // HEADERS
  // ============================================================================

  /// H1 - Título principal de página
  /// Ejemplo: "Gestión de Vehículos"
  static final TextStyle h1 = _baseInter.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
    letterSpacing: -0.5,
  );

  /// H2 - Título de sección
  /// Ejemplo: "Información General"
  static final TextStyle h2 = _baseInter.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
    letterSpacing: -0.25,
  );

  /// H3 - Subtítulo de sección
  /// Ejemplo: "Datos del Vehículo"
  static final TextStyle h3 = _baseInter.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  /// H4 - Título de card o subsección
  /// Ejemplo: "Mantenimiento Reciente"
  static final TextStyle h4 = _baseInter.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  /// H5 - Título pequeño
  /// Ejemplo: "Detalles Adicionales"
  static final TextStyle h5 = _baseInter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  /// H6 - Título mínimo
  /// Ejemplo: "Notas"
  static final TextStyle h6 = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  // ============================================================================
  // BODY / PÁRRAFOS
  // ============================================================================

  /// Body Large - Texto principal grande
  /// Ejemplo: Contenido destacado
  static final TextStyle bodyLarge = _baseInter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  /// Body - Texto principal estándar
  /// Ejemplo: Contenido general de la app
  static final TextStyle body = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  /// Body Bold - Texto principal en negrita
  /// Ejemplo: Etiquetas destacadas
  static final TextStyle bodyBold = body.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Body Secondary - Texto secundario
  /// Ejemplo: Texto de ayuda, descripciones
  static final TextStyle bodySecondary = body.copyWith(
    color: AppColors.textSecondaryLight,
  );

  /// Body Small - Texto pequeño
  /// Ejemplo: Pies de página, notas
  static final TextStyle bodySmall = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
    height: 1.4,
  );

  /// Body Small Secondary - Texto pequeño secundario
  /// Ejemplo: Metadatos, timestamps
  static final TextStyle bodySmallSecondary = bodySmall.copyWith(
    color: AppColors.textSecondaryLight,
  );

  // ============================================================================
  // TABLAS
  // ============================================================================

  /// Table Header - Encabezado de tabla
  /// Ejemplo: "MATRÍCULA", "MODELO", "ESTADO"
  static final TextStyle tableHeader = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondaryLight,
    letterSpacing: 0.5,
  );

  /// Table Cell - Celda de tabla estándar
  /// Ejemplo: "ABC-1234", "Ford Transit"
  static final TextStyle tableCell = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  /// Table Cell Bold - Celda de tabla en negrita
  /// Ejemplo: Valores importantes
  static final TextStyle tableCellBold = tableCell.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Table Cell Secondary - Celda de tabla secundaria
  /// Ejemplo: Fechas, IDs
  static final TextStyle tableCellSecondary = tableCell.copyWith(
    color: AppColors.textSecondaryLight,
  );

  /// Table Cell Small - Celda de tabla pequeña
  /// Ejemplo: Timestamps, metadatos
  static final TextStyle tableCellSmall = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  // ============================================================================
  // TABLAS ESTÁNDAR (Estilo específico de diseño unificado)
  // ============================================================================

  /// Standard Table Header - Encabezado de tabla estándar
  /// Estilo: 14px, bold (600), color #333333
  /// Uso: AppStandardTable
  static final TextStyle standardTableHeader = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.tableHeaderText,
    height: 1.4,
  );

  /// Standard Table Cell - Celda de tabla estándar
  /// Estilo: 14px, regular (400), color #666666
  /// Uso: AppStandardTable
  static final TextStyle standardTableCell = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.tableCellText,
    height: 1.4,
  );

  /// Standard Table Cell Bold - Celda de tabla estándar en negrita
  /// Estilo: 14px, bold (600), color #666666
  /// Uso: AppStandardTable para celdas destacadas
  static final TextStyle standardTableCellBold = standardTableCell.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Standard Table Cell Small - Celda de tabla estándar pequeña
  /// Estilo: 12px, regular (400), color #666666
  /// Uso: AppStandardTable para metadatos
  static final TextStyle standardTableCellSmall = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.tableCellText,
    height: 1.3,
  );

  // ============================================================================
  // BADGES / CHIPS / ESTADOS
  // ============================================================================

  /// Badge White - Badge con texto blanco
  /// Ejemplo: Estados, etiquetas sobre fondo de color
  static final TextStyle badgeWhite = _baseInter.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  /// Badge Dark - Badge con texto oscuro
  /// Ejemplo: Estados sobre fondo claro
  static final TextStyle badgeDark = _baseInter.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
    letterSpacing: 0.3,
  );

  /// Badge Large - Badge grande
  /// Ejemplo: Estados destacados
  static final TextStyle badgeLarge = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  /// Chip Text - Texto de chip
  /// Ejemplo: Filtros, categorías
  static final TextStyle chipText = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryLight,
  );

  // ============================================================================
  // BOTONES
  // ============================================================================

  /// Button Large - Botón grande
  /// Ejemplo: Botones primarios principales
  static final TextStyle buttonLarge = _baseInter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.25,
  );

  /// Button - Botón estándar
  /// Ejemplo: Botones generales
  static final TextStyle button = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.25,
  );

  /// Button Small - Botón pequeño
  /// Ejemplo: Botones secundarios, acciones inline
  static final TextStyle buttonSmall = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  /// Button Text - Botón de solo texto
  /// Ejemplo: Botones secundarios sin fondo
  static final TextStyle buttonText = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.25,
  );

  // ============================================================================
  // FORMULARIOS
  // ============================================================================

  /// Label - Etiqueta de campo
  /// Ejemplo: "Nombre", "Email", "Teléfono"
  static final TextStyle label = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryLight,
  );

  /// Label Bold - Etiqueta de campo en negrita
  /// Ejemplo: Campos obligatorios destacados
  static final TextStyle labelBold = label.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Hint - Placeholder de campo
  /// Ejemplo: "Ingresa tu nombre"
  static final TextStyle hint = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  /// Input - Texto de input
  /// Ejemplo: Valor ingresado por el usuario
  static final TextStyle input = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  /// Helper Text - Texto de ayuda
  /// Ejemplo: "Mínimo 8 caracteres"
  static final TextStyle helperText = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  /// Error Text - Texto de error
  /// Ejemplo: "Este campo es obligatorio"
  static final TextStyle errorText = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  // ============================================================================
  // LINKS Y NAVEGACIÓN
  // ============================================================================

  /// Link - Enlace estándar
  /// Ejemplo: "Ver más", "Descargar documento"
  static final TextStyle link = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Link Bold - Enlace en negrita
  /// Ejemplo: CTAs destacados
  static final TextStyle linkBold = link.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// Breadcrumb - Migas de pan
  /// Ejemplo: "Inicio > Vehículos > Detalle"
  static final TextStyle breadcrumb = _baseInter.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  /// Breadcrumb Active - Miga de pan activa
  /// Ejemplo: Última miga (página actual)
  static final TextStyle breadcrumbActive = breadcrumb.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  // ============================================================================
  // NAVEGACIÓN / MENÚS
  // ============================================================================

  /// Menu Item - Elemento de menú
  /// Ejemplo: Opciones del menú lateral
  static final TextStyle menuItem = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryLight,
  );

  /// Menu Item Active - Elemento de menú activo
  /// Ejemplo: Opción seleccionada
  static final TextStyle menuItemActive = menuItem.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Tab - Pestaña de navegación
  /// Ejemplo: "General", "Mantenimiento", "Documentos"
  static final TextStyle tab = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryLight,
  );

  /// Tab Active - Pestaña activa
  /// Ejemplo: Pestaña seleccionada
  static final TextStyle tabActive = tab.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ============================================================================
  // NÚMEROS Y MÉTRICAS
  // ============================================================================

  /// Metric Large - Métrica grande
  /// Ejemplo: KPIs principales
  static final TextStyle metricLarge = _baseInter.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
    letterSpacing: -1,
  );

  /// Metric Medium - Métrica mediana
  /// Ejemplo: KPIs secundarios
  static final TextStyle metricMedium = _baseInter.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
    letterSpacing: -0.5,
  );

  /// Metric Small - Métrica pequeña
  /// Ejemplo: Contadores, estadísticas
  static final TextStyle metricSmall = _baseInter.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
  );

  /// Metric Label - Etiqueta de métrica
  /// Ejemplo: "Total de servicios", "Disponibles"
  static final TextStyle metricLabel = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryLight,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // DIÁLOGOS Y NOTIFICACIONES
  // ============================================================================

  /// Dialog Title - Título de diálogo
  /// Ejemplo: "Confirmar Eliminación"
  static final TextStyle dialogTitle = _baseInter.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  /// Dialog Content - Contenido de diálogo
  /// Ejemplo: Mensaje del diálogo
  static final TextStyle dialogContent = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  /// Snackbar - Texto de snackbar
  /// Ejemplo: Mensajes de feedback
  static final TextStyle snackbar = _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// Tooltip - Texto de tooltip
  /// Ejemplo: Ayudas contextuales
  static final TextStyle tooltip = _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ============================================================================
  // CÓDIGO Y MONOSPACE
  // ============================================================================

  /// Code - Texto de código
  /// Ejemplo: IDs, referencias técnicas
  static final TextStyle code = GoogleFonts.robotoMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
    backgroundColor: AppColors.gray100,
  );

  /// Code Small - Texto de código pequeño
  /// Ejemplo: Timestamps, hashes
  static final TextStyle codeSmall = GoogleFonts.robotoMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  // ============================================================================
  // ESTADOS ESPECÍFICOS
  // ============================================================================

  /// Success Text - Texto de éxito
  /// Ejemplo: Mensajes positivos
  static final TextStyle successText = body.copyWith(
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );

  /// Warning Text - Texto de advertencia
  /// Ejemplo: Mensajes de precaución
  static final TextStyle warningText = body.copyWith(
    color: AppColors.warning,
    fontWeight: FontWeight.w600,
  );

  /// Error Text Large - Texto de error grande
  /// Ejemplo: Mensajes de error destacados
  static final TextStyle errorTextLarge = body.copyWith(
    color: AppColors.error,
    fontWeight: FontWeight.w600,
  );

  /// Info Text - Texto informativo
  /// Ejemplo: Mensajes informativos
  static final TextStyle infoText = body.copyWith(
    color: AppColors.info,
    fontWeight: FontWeight.w600,
  );

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  /// Obtiene un TextStyle con un color personalizado
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Obtiene un TextStyle con un tamaño de fuente personalizado
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  /// Obtiene un TextStyle con un peso de fuente personalizado
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
