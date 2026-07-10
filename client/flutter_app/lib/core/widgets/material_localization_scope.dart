import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MaterialLocalizationScope extends StatelessWidget {
  const MaterialLocalizationScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: child,
    );
  }
}
