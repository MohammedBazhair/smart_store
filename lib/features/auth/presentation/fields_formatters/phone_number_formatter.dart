import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final phoneNumber = newValue.text;

    final formattedPhoneNumber = StringBuffer();

    for (int index = 0; index < phoneNumber.length; index++) {
      final isNewGroup = index > 0 && index % 3 == 0;

      if (isNewGroup) formattedPhoneNumber.write(' ');

      formattedPhoneNumber.write(phoneNumber[index]);
    }

    return TextEditingValue(
      text: formattedPhoneNumber.toString(),
      selection: TextSelection.collapsed(
        offset: formattedPhoneNumber.length,
      ),
    );
  }
}
