import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// DarkTheme Color
const Color constantWhite = Color.fromRGBO(255, 255, 255, 1);
const Color backgroundColor = Color.fromRGBO(25, 27, 32, 1);
const Color sunnyOrange = Color.fromRGBO(255, 153, 0, 1);
const Color fadedWhite = Color.fromRGBO(187, 187, 187, 1);
const Color gradientGrey40 = Color.fromRGBO(45, 45, 45, 0.4);
const Color gradientGrey60 = Color.fromRGBO(45, 45, 45, 0.6);
const Color blackShadow = Color.fromRGBO(0, 0, 0, 0.1);

const Color whiteShadow = Color.fromRGBO(255, 255, 255, 0.1);

//Gradients
const LinearGradient greyGradient =
    LinearGradient(colors: [gradientGrey40, gradientGrey60], begin: Alignment.topLeft, end: Alignment.bottomRight);

// TextStyles
TextStyle orangeHeadline1 = GoogleFonts.poppins(color: sunnyOrange, fontWeight: FontWeight.w700, fontSize: 24);

TextStyle whiteHeadlineLarge = GoogleFonts.poppins(color: constantWhite, fontWeight: FontWeight.w700, fontSize: 36);
TextStyle whiteHeadline1 = GoogleFonts.poppins(color: constantWhite, fontWeight: FontWeight.w700, fontSize: 24);
TextStyle whiteHeadline2 = GoogleFonts.poppins(color: constantWhite, fontWeight: FontWeight.w600, fontSize: 18);
TextStyle whiteHeadline3 = GoogleFonts.poppins(color: constantWhite, fontWeight: FontWeight.w500, fontSize: 15);
TextStyle whiteHeadline4 = GoogleFonts.poppins(color: constantWhite, fontWeight: FontWeight.w500, fontSize: 12);

TextStyle fadedHeadline3 = GoogleFonts.poppins(color: fadedWhite, fontWeight: FontWeight.w500, fontSize: 15);

void showUpdateStatus(BuildContext context, String content, {bool isError = false}) {
  ThemeData theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        style: theme.textTheme.bodyText2,
        overflow: TextOverflow.visible,
        maxLines: 2,
      ),
      backgroundColor: sunnyOrange,
      behavior: SnackBarBehavior.floating,
      width: 250));
}
