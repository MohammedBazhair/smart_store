import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
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

    _listenToStoreChanges();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenToStoreChanges() {
    ref.listenManual(
      storeControllerProvider,
      fireImmediately: true,
      (_, next) async {
        final newName = next.state.selectedStore?.store.name;
        final isEditing = ref.read(isEditingStoreNameProvider);

        if (!isEditing) {
          _controller.text = newName ?? '';
        }
        await handleStoreStates(next, context);
      },
    );
  }

  void _onSubmit() async {
    final isValidated = _formKey.currentState?.validate() ?? false;
    if (!isValidated) return;

    final storeName = _controller.text;
    final isEdited = await ref
        .read(storeControllerProvider.notifier)
        .updateSelectedStore(storeName);

    if (!isEdited) {
      final oldName =
          ref.read(storeControllerProvider).state.selectedStore?.store.name;
      _controller.text = oldName ?? _controller.text;
    }
    ref.read(isEditingStoreNameProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(isEditingStoreNameProvider);
    final storeName =
        ref.watch(storeControllerProvider).state.selectedStore?.store.name ??
            '';
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
                      storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'تعديل المتجر',
                    onPressed: () {
                      ref.read(isEditingStoreNameProvider.notifier).state =
                          true;
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/edit.svg',
                      width: 30,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
