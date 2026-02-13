

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/enums.dart';

final isLoadingProvider =
    StateProvider.autoDispose.family<bool, IsLoading>((ref, type) => false);
