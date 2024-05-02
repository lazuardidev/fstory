import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFFD1093A);
const Color secondaryColor = Color(0xFFFF475A);
const Color primaryGray = Color(0xFFCDD2E1);
const Color secondaryGray = Color(0xFFE9EDF5);
const Color primaryBlack = Color(0xFF181B1E);
const Color secondaryBlack = Color(0xFF333940);

final TextTheme myTextTheme = TextTheme(
  titleLarge: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  ),
  titleMedium: GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  ),
  bodyLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  ),
  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  bodySmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  ),
);
