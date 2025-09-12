import 'package:flutter/material.dart';

class AppTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xffA5B68D),
    onPrimary: Color(0xff6B4646),
    // primaryContainer: Color(0xff425c43),
    // onPrimaryContainer: Color(0xffffffff),
    secondary: Color(0xffE7CCCC),
    onSecondary: Color(0xff6B4646),

    secondaryContainer: Color(0xFFE7E5E5),
    onSecondaryContainer: Color(0xffC1CFA1),
    tertiary: Color(0xFFF2E5C7),
    onTertiary: Color(0xff716F6F),
    // tertiaryContainer: Color(0xff4bac4e),
    // onTertiaryContainer: Color(0xffffffff),

    error: Color(0xffffb4ab),
    onError: Color(0xff690005),
    errorContainer: Color(0xff93000a),
    onErrorContainer: Color(0xffffb4ab),

    surface: Color(0xFFEDE8DC),
    onSurface: Color(0xff6B4646),
    // surfaceContainerHighest: Color(0xff2d2f2d),
    // onSurfaceVariant: Color(0xffffffff),
    outline: Color(0xffE7CCCC),

    // outlineVariant: Color(0xff404040),
    // shadow: Color(0xff000000),
    // scrim: Color(0xff000000),
    // inverseSurface: Color(0xffffffff),
    // onInverseSurface: Color(0xff000000),
    // inversePrimary: Color(0xff4c604d),
    // surfaceTint: Color(0xffa5d6a7),
  );

  static ThemeData get theme {
    return ThemeData(
      colorScheme: colorScheme,
      // listTileTheme: ListTileThemeData(
      //   tileColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      // ),
      // chipTheme: ChipThemeData(
      //   labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      //   padding: EdgeInsets.zero,
      //   selectedColor: colorScheme.primaryContainer,
      //   showCheckmark: false,
      //   shape: const RoundedRectangleBorder(
      //     side: BorderSide(width: 0, color: Colors.transparent),
      //     borderRadius: BorderRadius.all(Radius.circular(6)),
      //   ),
      // ),
      // filledButtonTheme: FilledButtonThemeData(
      //   style: FilledButton.styleFrom(
      //     padding: const EdgeInsets.all(14),
      //   ),
      // ),
    );
  }
}
