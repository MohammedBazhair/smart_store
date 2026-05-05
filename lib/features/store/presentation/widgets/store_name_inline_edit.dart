import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../controller/store_provider.dart';
import '../controller/store_state.dart';
import '../handle_store_states.dart';
import 'custom_store_name_field.dart';

final isEditingStoreNameProvider = StateProvider.autoDispose((ref) => false);

class StoreNameInlineEdit extends ConsumerStatefulWidget {
  const StoreNameInlineEdit({
    super.key,
  });

  @override
  ConsumerState<StoreNameInlineEdit> createState() =>
      _StoreNameInlineEditState();
}

class _StoreNameInlineEditState extends ConsumerState<StoreNameInlineEdit> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initStoreName();

    ref.listenManual(
      storeControllerProvider,
      (_, event) => handleStoreStates(event, context),
    );

    ref.listenManual(
      isEditingStoreNameProvider,
      (_, isEditing) {
        Logger.debugLog(message: 'isEditing: $isEditing');
        if (!isEditing) _resetStoreName();
      },
    );
  }

  void _initStoreName() {
    if (!ref.context.mounted) return;
    _controller.text = _controller.text =
        ref.read(storeControllerProvider).state.selectedStore?.store.name ??
            'لم يتم تحديد متجر';
  }

  void _resetStoreName() {
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (!ref.context.mounted) return;
      _controller.text = _controller.text =
          ref.watch(storeControllerProvider).state.selectedStore?.store.name ??
              'لم يتم تحديد متجر';
    });
  }

  void _onSubmit() async {
    final isValidated = _formKey.currentState?.validate() ?? false;
    if (!isValidated) return;

    final storeName = _controller.text;
    await ref
        .read(storeControllerProvider.notifier)
        .updateSelectedStore(storeName);
    ref.read(isEditingStoreNameProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(isEditingStoreNameProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isEditing
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  CustomStoreNameField(
                    controller: _controller,
                    onSubmitted: _onSubmit,
                  ),
                  Consumer(
                    builder: (_, ref, __) {
                      final isLoading = ref.watch(storeControllerProvider)
                          is UpdateingStoreEvent;

                      return ElevatedButton.icon(
                        icon: isLoading ? null : const Icon(Icons.check),
                        label: isLoading
                            ? const ThreeDotsLoading(
                                dotSize: 5,
                              )
                            : const Text('حفظ'),
                        onPressed: isLoading ? null : _onSubmit,
                      );
                    },
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTap: () {
                ref.read(isEditingStoreNameProvider.notifier).state = true;
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _controller.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 2,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: 'تعديل المتجر',
                    onPressed: () {
                      ref.read(isEditingStoreNameProvider.notifier).state =
                          true;
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
