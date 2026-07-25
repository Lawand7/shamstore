import 'package:get_storage/get_storage.dart';

class TokenStorage {
  TokenStorage._();

  static final GetStorage _box = GetStorage();

  static const String _authTokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  static const String _firstNameKey = 'profile_first_name';
  static const String _lastNameKey = 'profile_last_name';
  static const String _governorateKey = 'profile_governorate';
  static const String _dateOfBirthKey = 'profile_date_of_birth';
  static const String _profileImageUrlKey = 'profile_image_url';
  static const String _identityImageUrlKey = 'identity_image_url';

  static Future<void> saveToken(String token) async {
    await _box.write(_authTokenKey, token.trim());
  }

  static String? getToken() {
    return _cleanStoredText(_box.read<dynamic>(_authTokenKey));
  }

  static Future<void> saveUserRole(String role) async {
    await _box.write(_userRoleKey, role.trim().toLowerCase());
  }

  static String? getUserRole() {
    return _cleanStoredText(_box.read<dynamic>(_userRoleKey))?.toLowerCase();
  }

  static Future<void> saveUserId(int userId) async {
    await _box.write(_userIdKey, userId);
  }

  static int? getUserId() {
    final value = _box.read<dynamic>(_userIdKey);

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static Future<void> saveUserEmail(String email) async {
    await _box.write(_userEmailKey, email.trim().toLowerCase());
  }

  static String? getUserEmail() {
    return _cleanStoredText(_box.read<dynamic>(_userEmailKey));
  }

  static Future<void> saveProfileData({
    String? firstName,
    String? lastName,
    String? governorate,
    String? dateOfBirth,
    String? profileImageUrl,
    String? identityImageUrl,
    bool replaceExisting = false,
  }) async {
    if (replaceExisting) {
      await clearProfileData();
    }

    await _writeOptionalText(_firstNameKey, firstName);
    await _writeOptionalText(_lastNameKey, lastName);
    await _writeOptionalText(_governorateKey, governorate);
    await _writeOptionalText(_dateOfBirthKey, dateOfBirth);
    await _writeOptionalText(_profileImageUrlKey, profileImageUrl);
    await _writeOptionalText(_identityImageUrlKey, identityImageUrl);
  }

  static String? getProfileFirstName() {
    return _cleanStoredText(_box.read<dynamic>(_firstNameKey));
  }

  static String? getProfileLastName() {
    return _cleanStoredText(_box.read<dynamic>(_lastNameKey));
  }

  static String? getProfileGovernorate() {
    return _cleanStoredText(_box.read<dynamic>(_governorateKey));
  }

  static String? getProfileDateOfBirth() {
    return _cleanStoredText(_box.read<dynamic>(_dateOfBirthKey));
  }

  static String? getProfileImageUrl() {
    return _cleanStoredText(_box.read<dynamic>(_profileImageUrlKey));
  }

  static String? getIdentityImageUrl() {
    return _cleanStoredText(_box.read<dynamic>(_identityImageUrlKey));
  }

  static String getProfileFullName() {
    final parts = <String>[
      if (getProfileFirstName() != null) getProfileFirstName()!,
      if (getProfileLastName() != null) getProfileLastName()!,
    ];

    return parts.join(' ').trim();
  }

  static String getDisplayName() {
    final fullName = getProfileFullName();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = getUserEmail();

    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'مستخدم';
  }

  static bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearProfileData() async {
    await Future.wait([
      _box.remove(_firstNameKey),
      _box.remove(_lastNameKey),
      _box.remove(_governorateKey),
      _box.remove(_dateOfBirthKey),
      _box.remove(_profileImageUrlKey),
      _box.remove(_identityImageUrlKey),
    ]);
  }

  static Future<void> clear() async {
    await Future.wait([
      _box.remove(_authTokenKey),
      _box.remove(_userRoleKey),
      _box.remove(_userIdKey),
      _box.remove(_userEmailKey),
    ]);

    await clearProfileData();
  }

  static Future<void> _writeOptionalText(
    String key,
    String? value,
  ) async {
    final cleanValue = _cleanStoredText(value);

    if (cleanValue == null) {
      return;
    }

    await _box.write(key, cleanValue);
  }

  static String? _cleanStoredText(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
