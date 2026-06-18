import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

extension AppTextStyles on BuildContext {
  TextTheme get _t => Theme.of(this).textTheme;

  TextStyle get headlineMedium => GoogleFonts.nunito(
        textStyle: _t.headlineMedium,
        fontWeight: FontWeight.w800,
      );

  TextStyle get titleLarge => GoogleFonts.nunito(
        textStyle: _t.titleLarge,
        fontWeight: FontWeight.w700,
      );

  TextStyle get titleMedium => GoogleFonts.nunito(
        textStyle: _t.titleMedium,
        fontWeight: FontWeight.w800,
      );

  TextStyle get bodyMedium => GoogleFonts.nunito(
        textStyle: _t.bodyMedium,
        fontWeight: FontWeight.w700,
      );

  TextStyle get bodySmall => GoogleFonts.nunito(
        textStyle: _t.bodySmall,
        color: AppColors.secondary,
      );

  TextStyle get labelMedium => GoogleFonts.nunito(
        textStyle: _t.labelMedium,
        fontWeight: FontWeight.w700,
      );

  TextStyle get labelSmall => GoogleFonts.nunito(
        textStyle: _t.labelSmall,
        color: AppColors.secondary,
        fontWeight: FontWeight.w600,
      );
}
