import 'package:flutter_riverpod/legacy.dart';

import '../../constants/enums.dart';

final isLoadingProvider =
    StateProvider.autoDispose.family<bool, IsLoading>((ref, type) => false);
