import 'package:flutter/material.dart';

class AppFont {
  static TextStyle thin(double size, {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w100,
        color: color,
        decoration: decoration);
  }

  static TextStyle light(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: color,
        decoration: decoration);
  }

  static TextStyle regular(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        decoration: decoration);
  }

  static TextStyle medium(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        decoration: decoration);
  }

  static TextStyle semibold(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        decoration: decoration);
  }

  static TextStyle bold(double size, {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        decoration: decoration);
  }

  static TextStyle black(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        decoration: decoration);
  }

  static TextStyle italic(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'Lato',
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: color,
        decoration: decoration);
  }

  static TextStyle chemicalRegular(double size,
      {Color color, TextDecoration decoration}) {
    return TextStyle(
        fontFamily: 'SourceSansPro',
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        decoration: decoration);
  }
}
