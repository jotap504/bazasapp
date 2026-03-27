/// Constantes de la aplicación Bazas
abstract class AppConstants {
  // Supabase Storage
  static const String storageBucket = 'scoresheets';

  // Edge Functions
  static const String edgeFnProcessScoresheet = 'process-scoresheet';

  // Configuración de juego por defecto
  static const List<int> defaultF1Points = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
  static const double defaultOsadiaMultiplier = 1.0;
  static const double defaultEfectividadMultiplier = 1.0;
  static const int defaultMinQuorum = 5;

  // Formato de fechas
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';

  // Animaciones
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow   = Duration(milliseconds: 600);
}
