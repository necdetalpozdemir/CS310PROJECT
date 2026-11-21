import 'package:flutter/material.dart';

/// A labelled text field with an optional leading icon and inline error text.
///
/// Set [isPassword] to true to hide the text and show an eye button
/// that toggles visibility.
///
/// Must be placed inside a [Form] so that [validator] runs when the form
/// calls `validate()`.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  /// Small text shown above the box, e.g. "Email".
  final String label;

  /// Lets the screen read what the user typed: `controller.text`.
  final TextEditingController? controller;

  /// Grey example text inside the empty box, e.g. "name@sabanciuniv.edu".
  final String? hintText;

  /// Icon at the start of the box, e.g. Icons.mail_outline.
  final IconData? icon;

  /// Hides the text and adds a show/hide eye button.
  final bool isPassword;

  /// Returns an error message to show under the box, or null if the value is OK.
  final String? Function(String? value)? validator;

  /// Which keyboard to open, e.g. TextInputType.emailAddress.
  final TextInputType? keyboardType;

  /// What the keyboard's action key does, e.g. TextInputAction.next.
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // The only thing that changes inside this widget:
  // is the password currently hidden?
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            // Only password fields get the eye button.
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            border: border,
            enabledBorder: border,
            // Long error messages wrap instead of being cut off.
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
