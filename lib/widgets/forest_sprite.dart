import 'package:flutter/material.dart';

// ForestSprite: un widget CustomPaint qui dessine une mascotte de forêt
class ForestSprite extends StatelessWidget {
  final String mood;
  final double size;

  const ForestSprite({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ForestSpritePainter(mood),
    );
  }
}

class _ForestSpritePainter extends CustomPainter {
  final String mood;

  _ForestSpritePainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodyPaint = Paint()..color = const Color(0xFF7ED957);
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    final eyePaint = Paint()..color = Colors.black;
    final blushPaint = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.7);

    // --- Corps rond ---
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * 0.65, height: size.height * 0.55),
      bodyPaint,
    );

    // --- Oreilles en feuilles ---
    final leftLeaf = Path()
      ..moveTo(center.dx - size.width * 0.18, center.dy - size.height * 0.33)
      ..quadraticBezierTo(center.dx - size.width * 0.35, center.dy - size.height * 0.5, center.dx - size.width * 0.22,
          center.dy - size.height * 0.12)
      ..close();

    final rightLeaf = Path()
      ..moveTo(center.dx + size.width * 0.18, center.dy - size.height * 0.33)
      ..quadraticBezierTo(center.dx + size.width * 0.35, center.dy - size.height * 0.5, center.dx + size.width * 0.22,
          center.dy - size.height * 0.12)
      ..close();

    canvas.drawPath(leftLeaf, leafPaint);
    canvas.drawPath(rightLeaf, leafPaint);

    // --- Yeux ---
    final eyeOffsetY = center.dy - size.height * 0.05;

    switch (mood) {
      case 'happy':
        // Yeux ronds et brillants
        canvas.drawCircle(Offset(center.dx - size.width * 0.12, eyeOffsetY), 6, eyePaint);
        canvas.drawCircle(Offset(center.dx + size.width * 0.12, eyeOffsetY), 6, eyePaint);

        // Blush
        canvas.drawCircle(Offset(center.dx - size.width * 0.2, eyeOffsetY + 10), 5, blushPaint);
        canvas.drawCircle(Offset(center.dx + size.width * 0.2, eyeOffsetY + 10), 5, blushPaint);

        break;

      case 'neutral':
        // Yeux ovales
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx - size.width * 0.12, eyeOffsetY), width: 8, height: 3),
          eyePaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx + size.width * 0.12, eyeOffsetY), width: 8, height: 3),
          eyePaint,
        );
        break;

      case 'sad':
        // Yeux tristes
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx - size.width * 0.12, eyeOffsetY), width: 6, height: 8),
          eyePaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx + size.width * 0.12, eyeOffsetY), width: 6, height: 8),
          eyePaint,
        );
        break;

      case 'exhausted':
        // Yeux fermés
        final paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(center.dx - size.width * 0.18, eyeOffsetY),
          Offset(center.dx - size.width * 0.06, eyeOffsetY),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + size.width * 0.06, eyeOffsetY),
          Offset(center.dx + size.width * 0.18, eyeOffsetY),
          paint,
        );
        break;
    }

    // --- Bouche en fonction de l'humeur ---
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (mood == 'happy') {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 10), width: 25, height: 20),
        0,
        3.14,
        false,
        mouthPaint,
      );
    } else if (mood == 'sad' || mood == 'exhausted') {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 15), width: 20, height: 15),
        3.14,
        3.14,
        false,
        mouthPaint,
      );
    } else {
      canvas.drawLine(
        Offset(center.dx - 8, center.dy + 10),
        Offset(center.dx + 8, center.dy + 10),
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// TreeSpirit: un widget CustomPaint qui dessine un visage / masque d'arbre
class TreeSpirit extends StatelessWidget {
  final double size;
  final Color tone;
  final String mood;

  const TreeSpirit({
    super.key,
    required this.mood,
    this.size = 120,
    this.tone = const Color(0xFF9A7E56),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TreeSpiritPainter(tone),
    );
  }
}

class _TreeSpiritPainter extends CustomPainter {
  final Color tone;
  _TreeSpiritPainter(this.tone);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // --- Helpers: paints & gradients used across layers ---
    final barkBase = Paint()
      ..shader = RadialGradient(
        colors: [tone.withValues(alpha: 1.0), tone.withValues(alpha: 0.85), tone.withValues(alpha: 0.6)],
        stops: const [0.0, 0.55, 1.0],
        center: const Alignment(-0.1, -0.25),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.9));

    final rimLight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.yellow.withValues(alpha: 0.12), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // --- Background subtle vignette ---
    final bgRect = Rect.fromLTWH(0, 0, w, h);
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.06)],
        stops: const [0.6, 1.0],
        center: const Alignment(0, -0.4),
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // --- Large crown / branching silhouette (back layer) ---
    final crownPath = Path();
    crownPath.moveTo(cx - w * 0.25, cy - h * 0.42);
    crownPath.quadraticBezierTo(cx - w * 0.42, cy - h * 0.55, cx - w * 0.5, cy - h * 0.28);
    crownPath.quadraticBezierTo(cx - w * 0.45, cy - h * 0.02, cx - w * 0.28, cy - h * 0.12);
    crownPath.quadraticBezierTo(cx - w * 0.06, cy - h * 0.02, cx, cy - h * 0.08);
    crownPath.quadraticBezierTo(cx + w * 0.06, cy - h * 0.02, cx + w * 0.28, cy - h * 0.12);
    crownPath.quadraticBezierTo(cx + w * 0.45, cy - h * 0.02, cx + w * 0.5, cy - h * 0.28);
    crownPath.quadraticBezierTo(cx + w * 0.42, cy - h * 0.55, cx + w * 0.25, cy - h * 0.42);
    crownPath.close();

    final crownPaint = Paint()
      ..shader = LinearGradient(
        colors: [tone.withValues(alpha: 0.95), tone.withValues(alpha: 0.7)],
        begin: const Alignment(-0.8, -1.0),
        end: const Alignment(0.8, 1.0),
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    // subtle shadow under crown
    canvas.drawShadow(crownPath, Colors.black, 8.0, false);
    canvas.drawPath(crownPath, crownPaint);

    // --- Face main oval (center) ---
    final faceRect = Rect.fromCenter(center: Offset(cx, cy + h * 0.02), width: w * 0.48, height: h * 0.62);
    final faceR = RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.2));
    canvas.drawRRect(faceR, barkBase);

    // add carved sculptural planes (light and dark) using clipped paths
    final planePaintLight = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(faceRect);

    final planePaintDark = Paint()..color = Colors.black.withValues(alpha: 0.12);

    // left cheek plane
    final leftPlane = Path();
    leftPlane.moveTo(cx - w * 0.08, cy - h * 0.02);
    leftPlane.quadraticBezierTo(cx - w * 0.22, cy + h * 0.05, cx - w * 0.12, cy + h * 0.28);
    leftPlane.quadraticBezierTo(cx - w * 0.02, cy + h * 0.2, cx - w * 0.0, cy + h * 0.08);
    leftPlane.close();
    canvas.drawPath(leftPlane, planePaintDark);

    // right cheek plane (lighter)
    final rightPlane = Path();
    rightPlane.moveTo(cx + w * 0.08, cy - h * 0.02);
    rightPlane.quadraticBezierTo(cx + w * 0.22, cy + h * 0.05, cx + w * 0.12, cy + h * 0.28);
    rightPlane.quadraticBezierTo(cx + w * 0.02, cy + h * 0.2, cx + w * 0.0, cy + h * 0.08);
    rightPlane.close();
    canvas.drawPath(rightPlane, planePaintLight);

    // --- Eyes (almond, sculpted) ---
    final eyeWidth = w * 0.14;
    final eyeHeight = h * 0.06;
    final eyeY = cy - h * 0.08;
    final leftEyeCenter = Offset(cx - w * 0.14, eyeY);
    final rightEyeCenter = Offset(cx + w * 0.14, eyeY);

    // eye sockets (deep) - dark rim
    final socketPaint = Paint()..color = Colors.black.withValues(alpha: 0.75);
    canvas.drawOval(
        Rect.fromCenter(center: leftEyeCenter.translate(0, h * 0.01), width: eyeWidth * 1.06, height: eyeHeight * 1.3),
        socketPaint);
    canvas.drawOval(
        Rect.fromCenter(center: rightEyeCenter.translate(0, h * 0.01), width: eyeWidth * 1.06, height: eyeHeight * 1.3),
        socketPaint);

    // iris / glossy eye
    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.deepPurple.shade900, Colors.black],
        center: const Alignment(0, -0.2),
        radius: 0.9,
      ).createShader(Rect.fromCenter(center: leftEyeCenter, width: eyeWidth, height: eyeHeight));
    canvas.drawOval(Rect.fromCenter(center: leftEyeCenter, width: eyeWidth * 0.9, height: eyeHeight * 0.9), irisPaint);
    canvas.drawOval(Rect.fromCenter(center: rightEyeCenter, width: eyeWidth * 0.9, height: eyeHeight * 0.9), irisPaint);

    // small specular highlights
    final whitePaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(leftEyeCenter.translate(-eyeWidth * 0.12, -eyeHeight * 0.1), eyeWidth * 0.12, whitePaint);
    canvas.drawCircle(rightEyeCenter.translate(-eyeWidth * 0.12, -eyeHeight * 0.1), eyeWidth * 0.12, whitePaint);

    // lower eyelid sculpting (thin lines)
    final eyelidPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leftEyelid = Path()
      ..moveTo(leftEyeCenter.dx - eyeWidth * 0.45, leftEyeCenter.dy + eyeHeight * 0.12)
      ..quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy + eyeHeight * 0.4, leftEyeCenter.dx + eyeWidth * 0.45,
          leftEyeCenter.dy + eyeHeight * 0.12);
    canvas.drawPath(leftEyelid, eyelidPaint);
    final rightEyelid = Path()
      ..moveTo(rightEyeCenter.dx - eyeWidth * 0.45, rightEyeCenter.dy + eyeHeight * 0.12)
      ..quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy + eyeHeight * 0.4, rightEyeCenter.dx + eyeWidth * 0.45,
          rightEyeCenter.dy + eyeHeight * 0.12);
    canvas.drawPath(rightEyelid, eyelidPaint);

    // --- Nose bridge (subtle carved ridge) ---
    final nosePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final nosePath = Path();
    nosePath.moveTo(cx, cy - h * 0.02);
    nosePath.quadraticBezierTo(cx - w * 0.01, cy + h * 0.06, cx, cy + h * 0.12);
    canvas.drawPath(nosePath, nosePaint);

    // small nostril suggestion
    final nostrilPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - w * 0.05, cy + h * 0.14), width: w * 0.03, height: h * 0.02), nostrilPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + w * 0.05, cy + h * 0.14), width: w * 0.03, height: h * 0.02), nostrilPaint);

    // --- Mouth / expression (subtle, sculpted) ---
    final mouthPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final mouth = Path();
    mouth.moveTo(cx - w * 0.06, cy + h * 0.22);
    mouth.quadraticBezierTo(cx, cy + h * 0.26, cx + w * 0.06, cy + h * 0.22);
    canvas.drawPath(mouth, mouthPaint);

    // inner shadow under lower lip
    final mouthShadow = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + h * 0.22), width: w * 0.14, height: h * 0.07), 0, 3.14,
        false, mouthShadow);

    // --- Bark texture strokes: many thin lines carved across face ---
    final texturePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // draw concentric subtle ring lines (simulate growth rings / veining)
    for (double t = -0.4; t <= 0.5; t += 0.08) {
      final path = Path();
      final startX = cx - w * 0.28 * (1 - t.abs());
      final endX = cx + w * 0.28 * (1 - t.abs());
      path.moveTo(startX, cy + h * t * 0.35);
      path.quadraticBezierTo(cx, cy + h * t * 0.48 + 4 * (t * t), endX, cy + h * t * 0.35);
      canvas.drawPath(path, texturePaint);
    }

    // add a few carved grooves with higher contrast
    final groovePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final groove1 = Path();
    groove1.moveTo(cx - w * 0.2, cy - h * 0.08);
    groove1.quadraticBezierTo(cx - w * 0.08, cy + h * 0.04, cx - w * 0.06, cy + h * 0.18);
    canvas.drawPath(groove1, groovePaint);

    final groove2 = Path();
    groove2.moveTo(cx + w * 0.2, cy - h * 0.08);
    groove2.quadraticBezierTo(cx + w * 0.08, cy + h * 0.04, cx + w * 0.06, cy + h * 0.18);
    canvas.drawPath(groove2, groovePaint);

    // --- Foreground carved "branch collar" under the chin ---
    final collarPath = Path();
    collarPath.moveTo(cx - w * 0.18, cy + h * 0.28);
    collarPath.quadraticBezierTo(cx - w * 0.02, cy + h * 0.4, cx + w * 0.18, cy + h * 0.28);
    collarPath.quadraticBezierTo(cx + w * 0.06, cy + h * 0.48, cx - w * 0.06, cy + h * 0.44);
    collarPath.close();
    final collarPaint = Paint()
      ..shader = LinearGradient(
        colors: [tone.withValues(alpha: 0.85), tone.withValues(alpha: 0.5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - w * 0.22, cy + h * 0.24, w * 0.44, h * 0.28));
    canvas.drawPath(collarPath, collarPaint);
    // shadow below collar
    canvas.drawShadow(collarPath, Colors.black, 6.0, false);

    // --- Rim highlight (subtle) to enhance sculptural look ---
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawRRect(faceR, rimLight);
    canvas.restore();

    // final soft top highlight
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.06), Colors.transparent],
        center: const Alignment(0, -0.95),
        radius: 0.7,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(bgRect, topGlow);

    // small decorative chips / wood edges (left + right)
    final edgeChip = Paint()..color = Colors.black.withValues(alpha: 0.08);
    final chip1 = Path();
    chip1.moveTo(cx - w * 0.48, cy - h * 0.02);
    chip1.quadraticBezierTo(cx - w * 0.55, cy + h * 0.06, cx - w * 0.42, cy + h * 0.14);
    canvas.drawPath(chip1, edgeChip);

    final chip2 = Path();
    chip2.moveTo(cx + w * 0.48, cy - h * 0.02);
    chip2.quadraticBezierTo(cx + w * 0.55, cy + h * 0.06, cx + w * 0.42, cy + h * 0.14);
    canvas.drawPath(chip2, edgeChip);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Emoji Leafle representation for simple displays
class LeafleEmoji extends StatelessWidget {
  final String mood;
  final double size;

  const LeafleEmoji({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _getLeafleEmoji(mood),
      style: TextStyle(fontSize: size),
    );
  }
}

String _getLeafleEmoji(String mood) {
  switch (mood) {
    case 'happy':
      return '🌱';
    case 'neutral':
      return '🌿';
    case 'sad':
      return '🍃';
    case 'exhausted':
      return '🥀';
    default:
      return '🌱';
  }
}

// LeafleCreature: un widget CustomPaint qui dessine une petite créature feuille
class LeafleCreature extends StatelessWidget {
  final String mood;
  final double size;

  const LeafleCreature({
    super.key,
    required this.mood,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LeafleCreaturePainter(mood),
    );
  }
}

class _LeafleCreaturePainter extends CustomPainter {
  final String mood;

  _LeafleCreaturePainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // --- Corps : un petit esprit rond lumineux ---
    paint.color = const Color(0xFFB7F6C8);
    canvas.drawCircle(center, size.width * 0.35, paint);

    // --- Contour ---
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.green.shade700
      ..strokeWidth = 4;
    canvas.drawCircle(center, size.width * 0.35, paint);

    // --- Visage ---
    final eyePaint = Paint()..color = Colors.green.shade900;

    // Yeux
    double eyeY = center.dy - size.width * 0.1;
    canvas.drawCircle(Offset(center.dx - size.width * 0.12, eyeY), 5, eyePaint);
    canvas.drawCircle(Offset(center.dx + size.width * 0.12, eyeY), 5, eyePaint);

    // Bouche selon mood
    final mouthPaint = Paint()
      ..color = Colors.green.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    switch (mood) {
      case "happy":
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.width * 0.05),
            width: size.width * 0.25,
            height: size.width * 0.2,
          ),
          0,
          3.14,
          false,
          mouthPaint,
        );
        break;

      case "neutral":
        canvas.drawLine(
          Offset(center.dx - size.width * 0.12, center.dy + size.width * 0.05),
          Offset(center.dx + size.width * 0.12, center.dy + size.width * 0.05),
          mouthPaint,
        );
        break;

      case "sad":
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.width * 0.15),
            width: size.width * 0.25,
            height: size.width * 0.2,
          ),
          3.14,
          3.14,
          false,
          mouthPaint,
        );
        break;

      case "exhausted":
        final tiredPaint = mouthPaint..strokeWidth = 3;
        canvas.drawLine(
          Offset(center.dx - size.width * 0.12, center.dy + size.width * 0.10),
          Offset(center.dx + size.width * 0.12, center.dy + size.width * 0.10),
          tiredPaint,
        );
        // sourcils tombants
        canvas.drawLine(
          Offset(center.dx - size.width * 0.17, eyeY - 8),
          Offset(center.dx - size.width * 0.07, eyeY - 2),
          tiredPaint,
        );
        canvas.drawLine(
          Offset(center.dx + size.width * 0.17, eyeY - 8),
          Offset(center.dx + size.width * 0.07, eyeY - 2),
          tiredPaint,
        );
        break;
    }

    // --- Petite feuille sur la tête ---
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.green.shade400;
    Path leaf = Path();
    leaf.moveTo(center.dx, center.dy - size.width * 0.35);
    leaf.quadraticBezierTo(
      center.dx + 20,
      center.dy - size.width * 0.55,
      center.dx,
      center.dy - size.width * 0.75,
    );
    leaf.quadraticBezierTo(
      center.dx - 20,
      center.dy - size.width * 0.55,
      center.dx,
      center.dy - size.width * 0.35,
    );
    canvas.drawPath(leaf, paint);

    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.green.shade700
      ..strokeWidth = 3;
    canvas.drawPath(leaf, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
