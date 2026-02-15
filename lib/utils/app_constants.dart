/// Application-wide constants used across modules.
class AppConstants {
  AppConstants._();

  /// SharedPreferences key for storing the role selected on first launch.
  static const String userRoleKey = 'user_role';

  /// Role value for doctor users.
  static const String roleDoctor = 'doctor';

  /// Role value for patient users.
  static const String rolePatient = 'patient';
}
