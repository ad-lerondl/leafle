import 'package:flutter/material.dart';

// Couleurs centrales pour l'application
// Routines (bleu profond)
const kRoutinePrimary = Color(0xFF0D47A1);
const kRoutinePrimaryLight = Color(0xFF1565C0);

// Anti-routines (orange / dépendances)
const kAntiPrimary = Color(0xFFEF6C00); // deepOrange[600]
const kAntiPrimaryLight = Color(0xFFFF9800); // orange

// Forêt / nature (verts)
const kForestPrimary = Color(0xFF2E7D32); // green[800]
const kForestPrimaryLight = Color(0xFF388E3C); // green[700]
const kForestAccent = Color(0xFF81C784); // light green accent

// États génériques
const kSuccess = Color(0xFF2E7D32);
const kWarning = Color(0xFFFFA000);
const kDanger = Color(0xFFD32F2F);
const kInfo = Color(0xFF1976D2);

// Neutres / surfaces
const kSurface = Colors.white;
const kBackground = Color(0xFFF5F9F5);
const kDivider = Color(0xFFE0E0E0);

// Accents divers
const kPointsAmber = Color(0xFFFFC107);
const kPointsAmberLight = Color(0xFFFFECB3);
const kPointsAmberDark = Color(0xFFFFA000);

// Arbres / états de santé (Material approximations)
const kTreeHealthHigh = Color(0xFFA5D6A7); // green[200]
const kTreeHealthMid = Color(0xFFC8E6C9); // green[100]
const kTreeHealthWarn = Color(0xFFFFF9C4); // yellow[100]
const kTreeHealthLow = Color(0xFFFFE0B2); // orange[100]
const kTreeHealthCritical = Color(0xFFFFCDD2); // red[100]

// Forêt vide (browns)
const kForestEmptyBg = Color(0xFFD7CCC8); // brown[100]
const kForestEmptyBorder = Color(0xFFA1887F); // brown[300]
const kForestEmptyTextPrimary = Color(0xFF8D6E63); // brown[400]
const kForestEmptyTextSecondary = Color(0xFF6D4C41); // brown[600]

// Surfaces d'alerte rouge
const kDangerSurface = Color(0xFFFFEBEE); // red[50]
const kDangerBorder = Color(0xFFEF9A9A); // red[200]
const kDangerText = Color(0xFFB71C1C); // red[900]

// Fonction utilitaire de couleur d'énergie
Color energyColor(double energy) {
  if (energy >= 80) return kSuccess;
  if (energy >= 50) return kForestAccent;
  if (energy >= 20) return kWarning;
  return kDanger;
}
