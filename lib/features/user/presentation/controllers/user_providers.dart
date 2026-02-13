import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/core_providers.dart';


final isUserLoggedInProvider = Provider.autoDispose((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.isUserLoggedIn;
});


final getUserIdProvider = Provider.autoDispose((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.currentUser?.id;
});

