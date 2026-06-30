import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../constants/enums.dart';
import '../domain/entities/app_ui_event.dart';
import '../presentation/controllers/app_ui_event_controller.dart';

final isLoadingProvider =
    StateProvider.autoDispose.family<bool, IsLoading>((ref, type) => false);

final appUiEventProvider = NotifierProvider<AppUiEventController, AppUiEvent?>(
  AppUiEventController.new,
);
