import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// PALETA DE COLORES BAZAS - MODO OSCURO OBLIGATORIO
// ============================================================
abstract class AppColors {
  // Fondos
  static const Color backgroundDark  = Color(0xFF0A0A0F);
  static const Color surface         = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1A1A26);
  static const Color surfaceCard     = Color(0xFF1E1E2E);
  static const Color borderSubtle    = Color(0xFF2A2A3D);

  // Neónes principales
  static const Color neonGreen  = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonCyan   = Color(0xFF00E5FF);
  static const Color neonPink   = Color(0xFFFF2D78);

  // Neónes apagados (para fondos con opacidad)
  static const Color neonGreenDim  = Color(0x1A39FF14);
  static const Color neonOrangeDim = Color(0x1AFF6B00);
  static const Color neonCyanDim   = Color(0x1A00E5FF);

  // Texto
  static const Color textPrimary   = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090AA);
  static const Color textMuted     = Color(0xFF5A5A7A);

  // Posiciones del podio
  static const Color gold   = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Indicadores de tendencia
  static const Color trendUp   = Color(0xFF39FF14);
  static const Color trendDown = Color(0xFFFF2D78);
  static const Color trendFlat = Color(0xFF9090AA);

  // Error y éxito
  static const Color error   = Color(0xFFFF2D78);
  static const Color success  = Color(0xFF39FF14);
  static const Color warning  = Color(0xFFFF6B00);
}

// ============================================================
// GRADIENTES PREDEFINIDOS
// ============================================================
abstract class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0D1A), Color(0xFF0A0A0F)],
  );

  static const LinearGradient backgroundOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black54, Colors.black87],
  );

  static const LinearGradient neonGreenGradient = LinearGradient(
    colors: [Color(0xFF39FF14), Color(0xFF00C853)],
  );

  static const LinearGradient neonOrangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF9100)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E2E), Color(0xFF15151F)],
  );

  static LinearGradient podiumGradient(int position) {
    switch (position) {
      case 1:
        return const LinearGradient(
          colors: [Color(0x33FFD700), Color(0x0AFFD700)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0x33C0C0C0), Color(0x0AC0C0C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0x33CD7F32), Color(0x0ACD7F32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(
          colors: [AppColors.surfaceCard, AppColors.surface],
        );
    }
  }
}

// ============================================================
// DECORACIONES Y FONDOS
// ============================================================
abstract class AppDecorations {
  static const BoxDecoration background = BoxDecoration(
    color: AppColors.backgroundDark,
    image: DecorationImage(
      image: AssetImage('assets/images/felt_background.png'),
      fit: BoxFit.cover,
      opacity: 0.4, // Sutil para no distraer
    ),
  );

  static const BoxDecoration backgroundWithGradient = BoxDecoration(
    color: AppColors.backgroundDark,
    image: DecorationImage(
      image: AssetImage('assets/images/felt_background.png'),
      fit: BoxFit.cover,
      opacity: 0.3,
    ),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, AppColors.backgroundDark],
    ),
  );
}

// ============================================================
// HELPERS DE ESTILO CON GOOGLE FONTS
// ============================================================
abstract class AppTextStyles {
  // Rajdhani — estilo deportivo y moderno (titulares, números grandes)
  static TextStyle rajdhani({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.rajdhani(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Inter — texto de cuerpo y UI
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Atajos de uso frecuente
  static TextStyle get statNumber => rajdhani(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.neonGreen,
      );

  static TextStyle get positionBig => rajdhani(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get neonLabel => inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 1.4,
      );

  static TextStyle get headlineMedium => rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => rajdhani(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displaySmall => rajdhani(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      );
}

// ============================================================
// TEMA PRINCIPAL
// ============================================================
abstract class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary:          AppColors.neonGreen,
        secondary:        AppColors.neonOrange,
        tertiary:         AppColors.neonCyan,
        surface:          AppColors.surface,
        surfaceVariant:   AppColors.surfaceElevated,
        error:            AppColors.error,
        onPrimary:        AppColors.backgroundDark,
        onSecondary:      AppColors.backgroundDark,
        onSurface:        AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline:          AppColors.borderSubtle,
      ),

      textTheme: _buildTextTheme(),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.neonGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        shape: CircleBorder(),
      ),

      // Cards
      cardTheme: CardTheme(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),

      // Botón primario
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Botón outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        errorStyle: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.neonGreenDim,
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonGreen,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display — Rajdhani Bold
      displayLarge: GoogleFonts.rajdhani(
        fontSize: 57, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.rajdhani(
        fontSize: 45, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.rajdhani(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: 1.0,
      ),

      // Headline — Rajdhani
      headlineSmall: GoogleFonts.rajdhani(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      // Title — Inter SemiBold
      titleLarge: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary, letterSpacing: 0.1,
      ),

      // Body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),

      // Label — Inter Medium
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary, letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: AppColors.textMuted, letterSpacing: 0.5,
      ),
    );
  }
}
