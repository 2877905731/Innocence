import 'package:flutter/material.dart';

bool isChineseLocale(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'zh';
}

String localizedText(BuildContext context, String zh, String en) {
  return isChineseLocale(context) ? zh : en;
}
