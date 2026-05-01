import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';

final initDataFromNetProvider = FutureProvider((ref) async {
  final repo = ref.read(syncProductRepositoryProvider);
  await repo.initializeDataFromNetwork();
});
