import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/screen/dashboard_screen.dart';
import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store.dart';
import '../controller/store_provider.dart';

class StoreSelectionScreen extends ConsumerStatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  ConsumerState<StoreSelectionScreen> createState() =>
      _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends ConsumerState<StoreSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color roleColor(Role role) {
    switch (role) {
      case Role.storeOwner:
        return Colors.green;
      case Role.worker:
        return Colors.blue;
      case Role.guest:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'اختر متجرك',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// STORES GRID
                  Consumer(
                    builder: (_, ref, __) {
                      final state = ref.watch(storeControllerProvider).state;
                      final stores = state.myStores.values.toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: stores.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final store = stores[index].store;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _StoreCard(
                                store: store,
                                role: state.myRole.label,
                                color: roleColor(state.myRole),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  /// CREATE BUTTON
                  AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String storeName = '';
                              return AlertDialog(
                                title: const Text('Create New Store'),
                                content: TextField(
                                  onChanged: (value) => storeName = value,
                                  decoration: const InputDecoration(
                                    hintText: 'Store Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إالغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async{
                                      final name = storeName.trim();
                                      if (name.isEmpty) return;
                                      final cntroller= ref
                                          .read(
                                            storeControllerProvider.notifier,
                                          );
                                      
                                          await cntroller.createStore(name);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Create'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Create New Store',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreCard extends ConsumerWidget {
  const _StoreCard({
    required this.store,
    required this.role,
    required this.color,
  });
  final Store store;
  final String role;
  final Color color;

  @override
  Widget build(BuildContext context, ref) {
    return GestureDetector(
      onTap: () {
        ref.read(storeControllerProvider.notifier).selectStore(store.id!);
        context.pushReplacementTo(const DashboardScreen());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.store, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
