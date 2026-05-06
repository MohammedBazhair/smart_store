class AppMetadata {
  AppMetadata({
    this.provider,
    this.providers,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) {
    return AppMetadata(
      provider: json['provider'] as String?,
      providers:
          (json['providers'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
  final String? provider;
  final List<String>? providers;

  @override
  String toString() {
    return 'AppMetadata(provider: $provider, providers: $providers)';
  }

  
}
