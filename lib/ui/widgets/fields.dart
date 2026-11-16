import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';

/// Text field (§3.24): 52 pt, `surface2`, radius 16, label above; focus — 2 pt
/// primary outline; error — `bad` outline and the message under the field.
class GField extends StatelessWidget {
  const GField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.suffix,
    this.autofocus = false,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.focusNode,
    this.enabled = true,
    this.autocorrect = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final Widget? suffix;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    OutlineInputBorder border(Color color, double w) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(GRadius.field),
      borderSide: w == 0 ? BorderSide.none : BorderSide(color: color, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(label!, style: context.t.subhead.copyWith(color: c.ink2)),
          ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          autofillHints: autofillHints,
          autofocus: autofocus,
          autocorrect: autocorrect && !obscure,
          enableSuggestions: !obscure,
          inputFormatters: inputFormatters,
          maxLines: obscure ? 1 : maxLines,
          minLines: minLines,
          textCapitalization: textCapitalization,
          style: style ?? context.t.body.copyWith(fontWeight: FontWeight.w500),
          cursorColor: GColors.brand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.t.body.copyWith(color: c.ink3),
            filled: true,
            fillColor: c.surface2,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: border(c.hairline, 0),
            enabledBorder: border(error != null ? c.bad : c.hairline, error != null ? 2 : 0),
            focusedBorder: border(error != null ? c.bad : GColors.brand, 2),
            disabledBorder: border(c.hairline, 0),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GIcon(GIcons.error, size: 16, color: c.bad, fill: 1),
                  const SizedBox(width: 6),
                  Expanded(child: Text(error!, style: context.t.footnote.copyWith(color: c.bad))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// School code formatter (§3.24): `XXXXX-XXXXX`, upper case, only letters and
/// digits of the code alphabet.
class AccessCodeFormatter extends TextInputFormatter {
  static final _allowed = RegExp('[A-Z0-9]');

  static String normalize(String raw) => raw.toUpperCase().split('').where(_allowed.hasMatch).take(10).join();

  static String format(String raw) {
    final n = normalize(raw);
    return n.length > 5 ? '${n.substring(0, 5)}-${n.substring(5)}' : n;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = format(newValue.text);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
