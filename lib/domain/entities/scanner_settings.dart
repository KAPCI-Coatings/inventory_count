class ScannerSettings {
  final String profileName;
  final String baseUrl;
  final int deviceId;

  const ScannerSettings({
    required this.profileName,
    required this.baseUrl,
    required this.deviceId,
  });

  factory ScannerSettings.defaults() {
    return const ScannerSettings(
      profileName: 'APP_PROFILE',
      baseUrl: 'http://10.10.30.47:2604',
      deviceId: 0,
    );
  }

  factory ScannerSettings.fromJson(Map<String, dynamic> json) {
    final ScannerSettings defaults = ScannerSettings.defaults();

    return ScannerSettings(
      profileName:
          (json['profileName'] as String?) ?? defaults.profileName,
      baseUrl: (json['baseUrl'] as String?) ?? defaults.baseUrl,
      deviceId: (json['deviceId'] as num?)?.toInt() ?? defaults.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'profileName': profileName, 'baseUrl': baseUrl, 'deviceId': deviceId};
  }
}
