import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hint;
  final Color? fillColor;
  final Color? hintColor;
  final Color? textColor;
  final double? width;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final double? height;
  final bool showSuffixIcon;
  final bool enabled;
  final VoidCallback? onTap;
  final String? errorText;
  final Function(String)? onChanged;
  final String? initialValue;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    this.hint,
    this.fillColor,
    this.hintColor,
    this.textColor,
    this.width,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.height,
    this.showSuffixIcon = true,
    this.enabled = true,
    this.onTap,
    this.errorText,
    this.onChanged,
    this.initialValue,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height ?? 30,
            maxHeight: height ?? 30,
          ),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: focusNode,
                      initialValue: initialValue,
                      onChanged: onChanged,
                      onTap: onTap,
                      enabled: enabled,
                      readOnly: !enabled,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontFamily: 'AvenirRegular',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: initialValue != null && initialValue!.isNotEmpty
                              ? null
                              : hintColor,
                          fontFamily: 'AvenirRegular',
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (showSuffixIcon)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Transform.translate(
                          offset: const Offset(0, -2),
                          child: suffixIcon,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) _buildErrorWidget(errorText!),
      ],
    );
  }

  Widget _buildErrorWidget(String errorText) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 5),
      child: Text(
        errorText,
        style: const TextStyle(
          color: Colors.red,
          fontFamily: 'AvenirRegular',
          fontSize: 11,
        ),
      ),
    );
  }
}
