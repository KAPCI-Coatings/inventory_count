import 'package:flutter/material.dart';

import 'app_input_decoration.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final void Function(T?)? onChanged;
  final String? labelText;
  final double fontSize;
  final InputDecoration? decoration;
  final bool isLoading;
  final double? height;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.labelText,
    required this.fontSize,
    this.decoration,
    this.isLoading = false,
    this.height,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final defaultDeco = AppInputDecoration.standard(
      context: context,
      labelText: labelText ?? itemLabelBuilder(value),
    );
    final appliedDecoration = decoration?.copyWith(
          labelText: labelText ?? itemLabelBuilder(value),
        ) ??
        defaultDeco;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        decoration: appliedDecoration,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabelBuilder(item),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        onChanged: isLoading ? null : onChanged,
        validator: validator,
      ),
    );
  }
}
