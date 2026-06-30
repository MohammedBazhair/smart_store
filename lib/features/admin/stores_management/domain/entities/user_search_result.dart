import 'dart:convert';
import '../../../../user/domain/entities/account_status.dart';

class UserSearchResult {
  UserSearchResult({
    required this.userId,
    required this.userName,
    required this.phone,
    required this.accountStatus,
  });

  factory UserSearchResult.fromMap(Map<String, dynamic> map) {
    return UserSearchResult(
      userId: map['id'] as String,
      userName: map['user_name'] as String,
      phone: map['phone'] as String,
      accountStatus: AccountStatus.fromString(map['account_status'] as String),
    );
  }

  factory UserSearchResult.fromJson(String source) =>
      UserSearchResult.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserSearchResult.empty(int index) => UserSearchResult(
        userId: 'gghfgh-$index',
        accountStatus: AccountStatus.active,
        phone: '773456789',
        userName: 'ghjgjh hfhfj hf jh',
      );

  final String userId;
  final String userName;
  final String phone;
  final AccountStatus accountStatus;

  static List<UserSearchResult> get fakeList => List.generate(
        5,
        UserSearchResult.empty,
      );

  static List<String> get dbColumns =>
      ['id', 'user_name', 'phone', 'account_status'];

  UserSearchResult copyWith({
    String? userId,
    String? userName,
    String? phone,
    AccountStatus? accountStatus,
  }) {
    return UserSearchResult(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }
}
