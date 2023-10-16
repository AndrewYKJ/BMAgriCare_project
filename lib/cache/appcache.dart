import 'package:behn_meyer_flutter/const/util.dart';
import 'package:behn_meyer_flutter/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  static const String ACCESS_TOKEN_PREF = "ACCESS_TOEKN_PREF";
  static const String REFRESH_TOKEN_PREF = "REFRESH_TOKEN_PREF";

  static const String LANGUAGE_CODE_PREF = "LANGUAGE_CODE_PREF";
  static const String COUNTRY_CODE_PREF = "COUNTRY_CODE_PREF";
  static const String IS_HIDE_INTRO_PAGE_PREF = "IS_HIDE_INTRO_PAGE_PREF";

  static User me;
  static List cOutlet;

  static Future<void> setInteger(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  static Future<int> getIntegerValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt(key) ?? 0;
  }

  static Future<void> setDouble(String key, double value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble(key, value);
  }

  static Future<double> getDoubleValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getDouble(key) ?? 0.0;
  }

  static Future<void> setBoolean(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<bool> getbooleanValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key) ?? false;
  }

  static Future<void> setString(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static Future<String> getStringValue(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String data = pref.getString(key) ?? "";
    return data;
  }

  static void setAuthToken(String accessToken, String refreshToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(ACCESS_TOKEN_PREF, accessToken);
    pref.setString(REFRESH_TOKEN_PREF, refreshToken);
  }

  static Future<Locale> setLocale(String languageCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(LANGUAGE_CODE_PREF, languageCode);
    return Util.mylocale(languageCode);
  }

  static Future<Locale> getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(LANGUAGE_CODE_PREF) ?? "en";
    return Util.mylocale(languageCode);
  }

  static Future<void> setCountry(String countryCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(COUNTRY_CODE_PREF, countryCode);
  }

  static Future<String> getCountry() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String countryCode = _prefs.getString(COUNTRY_CODE_PREF) ?? "";
    return countryCode;
  }

  static void removeAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(ACCESS_TOKEN_PREF);
    prefs.remove(REFRESH_TOKEN_PREF);
  }

  static void removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(ACCESS_TOKEN_PREF);
    prefs.remove(REFRESH_TOKEN_PREF);
    // prefs.remove(LANGUAGE_CODE_PREF);
  }

  static void removeLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(LANGUAGE_CODE_PREF);
  }

  static Future<bool> containValue(String key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool checkValue = _prefs.containsKey(key);
    return checkValue;
  }
}
