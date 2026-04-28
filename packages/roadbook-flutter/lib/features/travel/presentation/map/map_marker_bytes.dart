// lib/features/travel/presentation/map/map_marker_bytes.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Renders a coral pill marker: "D{N} · name" + stem + dot below.
/// Returns raw PNG bytes usable by both AMap and Google Maps BitmapDescriptor.
Future<Uint8List> buildScheduleMarkerBytes({
  required Color color,
  required String dayLabel,
  required String time,
  required String name,
}) async {
  final shortName = name.length > 3 ? '${name.substring(0, 3)}…' : name;
  final label = '$dayLabel·$shortName';

  const double fontSize = 38;
  const double padH = 22;
  const double padV = 14;
  const double radius = 24;
  const double stemH = 18;
  const double dotR = 9;

  final textBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.left, maxLines: 1),
  )
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: ui.FontWeight.w700,
      fontFamily: 'PingFang SC',
    ))
    ..addText(label);
  final textPara = textBuilder.build()
    ..layout(const ui.ParagraphConstraints(width: 800));

  final textW = textPara.maxIntrinsicWidth;
  final pillW = textW + padH * 2;
  final pillH = fontSize + padV * 2;
  final totalW = (pillW + 8).ceilToDouble();
  final totalH = (pillH + stemH + dotR * 2 + 8).ceilToDouble();

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final pillX = (totalW - pillW) / 2;
  final cx = totalW / 2;

  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(pillX, 6, pillW, pillH), ui.Radius.circular(radius)),
    ui.Paint()
      ..color = color.withValues(alpha: 0.30)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6));

  final pillRect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(pillX, 2, pillW, pillH), ui.Radius.circular(radius));
  canvas.drawRRect(pillRect, ui.Paint()..color = color);

  final textY = 2 + (pillH - textPara.height) / 2;
  canvas.drawParagraph(textPara, Offset(pillX + padH, textY));

  final stemTop = pillH + 2;
  canvas.drawLine(
    Offset(cx, stemTop), Offset(cx, stemTop + stemH),
    ui.Paint()..color = color..strokeWidth = 5..strokeCap = ui.StrokeCap.round);

  final dotCy = stemTop + stemH + dotR;
  canvas.drawCircle(Offset(cx, dotCy), dotR + 2, ui.Paint()..color = color);
  canvas.drawCircle(Offset(cx, dotCy), dotR - 1, ui.Paint()..color = Colors.white);

  final picture = recorder.endRecording();
  final image = await picture.toImage(totalW.ceil(), totalH.ceil());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// Renders a circle marker with white number label.
Future<Uint8List> buildCircleMarkerBytes({
  required Color color,
  required String label,
  double size = 72,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final center = Offset(size / 2, size / 2);
  final radius = (size - 4) / 2;

  canvas.drawCircle(
    Offset(center.dx, center.dy + 3),
    radius,
    ui.Paint()
      ..color = color.withValues(alpha: 0.30)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
  );

  canvas.drawCircle(center, radius, ui.Paint()..color = color);

  canvas.drawCircle(
    center,
    radius,
    ui.Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4,
  );

  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center),
  )
    ..pushStyle(ui.TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: label.length == 1 ? 28 : 22,
      fontWeight: ui.FontWeight.w800,
    ))
    ..addText(label);
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(paragraph, Offset(0, (size - paragraph.height) / 2));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
