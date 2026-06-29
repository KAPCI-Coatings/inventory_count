import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onSubmitPressed;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onSubmitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(['1', '2', '3']),
            const SizedBox(height: 8),
            _buildRow(['4', '5', '6']),
            const SizedBox(height: 8),
            _buildRow(['7', '8', '9']),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildButton('', onPressed: null), // Empty space
                const SizedBox(width: 8),
                _buildButton('0', onPressed: () => onDigitPressed('0')),
                const SizedBox(width: 8),
                _buildButton('⌫', onPressed: onDeletePressed, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits.map((digit) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: digit == digits.last ? 0 : 8.0,
            ),
            child: _buildButton(digit, onPressed: () => onDigitPressed(digit)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, {VoidCallback? onPressed, Color? color}) {
    if (text.isEmpty) {
      return const Expanded(child: SizedBox.shrink());
    }
    return Expanded(
      child: Material(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 55,
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
