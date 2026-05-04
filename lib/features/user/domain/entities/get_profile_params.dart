import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/app_metadata.dart';
import '../../data/models/user_metadata.dart';

class GetProfileParams {
  GetProfileParams({
    required this.userId,
    required this.appMetadata,
    required this.userMetadata,
    this.phone,
  });

  factory GetProfileParams.fromSupabaseUser(User user) {
    return GetProfileParams(
      userId: user.id,
      appMetadata: AppMetadata.fromJson(user.appMetadata),
      userMetadata: user.userMetadata != null
          ? UserMetadata.fromJson(user.userMetadata!)
          : null,
      phone: user.phone,
    );
  }
  final String userId;
  final String? phone;
  final AppMetadata appMetadata;
  final UserMetadata? userMetadata;

  @override
  String toString() {
    return 'GetProfileParams('
        'userId: $userId, '
        'appMetadata: $appMetadata, '
        'userMetadata: $userMetadata'
        ')';
  }
}
