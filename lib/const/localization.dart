import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyLocalization {
  MyLocalization(this.locale);

  final Locale locale;
  static MyLocalization of(BuildContext context) {
    return Localizations.of<MyLocalization>(context, MyLocalization);
  }

  Map<String, String> _localizedValues;

  Future<void> load() async {
    String jsonStringValues = await rootBundle
        .loadString('assets/locale/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<MyLocalization> delegate =
      _MyLocalizationsDelegate();
}

class _MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalization> {
  const _MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id', 'zh', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<MyLocalization> load(Locale locale) async {
    MyLocalization localization = new MyLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<MyLocalization> old) => false;
}
