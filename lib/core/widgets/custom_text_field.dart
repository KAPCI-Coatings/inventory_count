import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources/responsive_utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool autofocus;
  final double? height;
  final TextAlign textAlign;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.labelText,
    this.hintText,
    this.onChanged,
    this.initialValue,
    this.keyboardType,
    this.autofocus = false,
    this.height,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  }) : assert(
          controller == null || initialValue == null,
          'Cannot provide both a controller and an initial value.',
        );

  @override
  Widget build(BuildContext context) {
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
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        initialValue: initialValue,
        textAlign: textAlign,
        keyboardType: keyboardType,
        autofocus: autofocus,
        obscureText: obscureText,
        maxLines: maxLines,
        validator: validator,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          isDense: true,
          labelText: labelText,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
