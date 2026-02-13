class GetProfileParams {
  GetProfileParams({required this.userId, required this.appMetadata, required this.userMetadata});

  final String userId;
  final Map<String, dynamic> appMetadata;
  final Map<String, dynamic>? userMetadata;

}