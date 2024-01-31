import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:convert';
import 'package:celebrare_editor/edit_class.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

double canvasHeight = 650;
double canvasWidth = 500;
Color canvasColor = Colors.grey.shade300;

class Utils {
  static downloadImage(ScreenshotController screenshotController) async {
    // Capture screenshot
    Uint8List? capturedImageBytes = await screenshotController.capture();

    if (capturedImageBytes != null) {
      // Convert to Image from image package
      img.Image image = img.decodeImage(capturedImageBytes)!;

      // Save image to file
      saveImage(image);
    }
  }

  static void saveImage(img.Image image) {
    // Convert Image to PNG bytes
    List<int> pngBytes = img.encodePng(image);

    // Convert to base64
    String base64String = base64Encode(pngBytes);

    // Create a link element
    final html.AnchorElement anchor = html.AnchorElement(
        href: 'data:application/octet-stream;base64,$base64String')
      // ..target = 'blank'
      ..download = 'screenshot.png';

    // Trigger a click event to download the image
    html.document.body?.append(anchor);
    anchor.click();
    // html.document.body?.remove();
  }

  static bool isTapInsideItem(Offset tapPosition, EditableItem item) {
    double itemLeft = item.position.dx * canvasWidth;
    double itemTop = item.position.dy * canvasHeight;

    if (tapPosition.dx >= itemLeft &&
        tapPosition.dx <= itemLeft + (canvasWidth / 4) &&
        tapPosition.dy >= itemTop &&
        tapPosition.dy <= itemTop + (canvasHeight / 4)) {
      return true;
    }

    return false;
  }
}
