import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final String? selectedDate;
  final VoidCallback onTap;
  final Color? fillColor;
  final Color? hintColor;
  final Color? textColor;
  final double? width;

  const CustomDatePicker({
    super.key,
    required this.onTap,
    this.selectedDate,
    this.fillColor,
    this.hintColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = 'Fecha de nacimiento';
    if (selectedDate != null && selectedDate!.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(selectedDate!);
        formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (_) {
        formattedDate = selectedDate!;
      }
    }

    return SizedBox(
      width: width,
      height: 30,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  color: formattedDate == 'Fecha de nacimiento'
                      ? hintColor
                      : Colors.white,
                  fontFamily: 'AvenirRegular',
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today,
                    color: Colors.white, size: 18),
                onPressed: onTap,
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
