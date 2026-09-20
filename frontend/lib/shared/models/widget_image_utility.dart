import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WidgetImageUtility {
  /// Fetches a network image or uses a fallback icon, rendering either onto a
  /// canvas with squircle clipping. Returns a base64 encoded PNG.
  static Future<String?> getSquircleBase64({
    String? imageUrl,
    IconData? fallbackIcon,
    Color fallbackBgColor = const Color(0xFF2C353D),
    Color iconColor = Colors.white,
    double size = 48.0,
  }) async {
    ui.Image? networkImage;

    // Attempt to fetch and decode the network image
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(Uri.parse(imageUrl));
        request.followRedirects = true;
        request.maxRedirects = 5;
        final response = await request.close();

        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          final codec = await ui.instantiateImageCodec(bytes);
          final frameInfo = await codec.getNextFrame();
          networkImage = frameInfo.image;
        }
      } catch (e) {
        debugPrint("Failed to fetch/decode image for widget utility: $e");
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

    // Dynamic corner radius matching LogoBaseWidget
    final dynamicRadius = (size * 0.2);

    // Define clip region across full bounds
    final rect = Rect.fromLTWH(0, 0, size, size);
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(dynamicRadius),
    );

    // Apply smooth anti-aliased clip
    canvas.clipRRect(rRect, doAntiAlias: true);

    // Draw background
    final bgPaint = Paint()..color = fallbackBgColor;
    canvas.drawRect(rect, bgPaint);

    // Draw content
    if (networkImage != null) {
      // Draw image across full bounds so the canvas clip handles the squircle edge cleanly
      paintImage(
        canvas: canvas,
        rect: rect,
        image: networkImage,
        fit: BoxFit.cover, // Fill completely without leaving background edges
        filterQuality: FilterQuality.medium, // Improves crispness on low-res rendering
      );
    } else if (fallbackIcon != null) {
      final double targetContentSize = size * 0.65;
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(fallbackIcon.codePoint),
        style: TextStyle(
          fontSize: targetContentSize,
          fontFamily: fallbackIcon.fontFamily,
          package: fallbackIcon.fontPackage,
          color: iconColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );
    } else {
      return null;
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(pngBytes!.buffer.asUint8List()).replaceAll('\n', '').replaceAll('\r', '').trim();
  }
}
