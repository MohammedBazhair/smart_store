

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';

final isLoadingProvider =
    StateProvider.family<bool, IsLoading>((ref, type) => false);
