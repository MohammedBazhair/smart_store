import 'package:flutter/material.dart';

Future<int?> pickNumber(
  BuildContext context, {
  required String title,
  required int from,
  required int to,
}) {
  return showModalBottomSheet<int>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                to - from + 1,
                (index) {
                  final value = from + index;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, value),
                    child: CircleAvatar(
                      radius: value.toString().length == 4 ? 30 : 23,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
