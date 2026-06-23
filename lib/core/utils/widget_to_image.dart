import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// PNG-encoded bytes of a rendered widget, ready to be wrapped in a Mapbox
/// `MbxImage`.
///
/// The plugin decodes this data natively via `UIImage(data:)` (iOS) and
/// `BitmapFactory.decodeByteArray` (Android), so the bytes must be an encoded
/// image (PNG) rather than a raw pixel buffer.
class RenderedImage {
  const RenderedImage({
    required this.widthPx,
    required this.heightPx,
    required this.pixelRatio,
    required this.bytes,
  });

  /// Physical pixel width (logical width * pixelRatio).
  final int widthPx;

  /// Physical pixel height (logical height * pixelRatio).
  final int heightPx;

  /// Scale factor the image was rendered at.
  final double pixelRatio;

  /// PNG-encoded image bytes.
  final Uint8List bytes;
}

/// Rasterises an arbitrary Flutter widget into a PNG image entirely off-screen
/// (the widget is never attached to the visible tree).
///
/// This lets us design map markers as ordinary Flutter widgets (cards, icons,
/// gradients…) and hand the result to Mapbox as a style image, which is far
/// cheaper at runtime than rendering thousands of native annotations.
class WidgetToImage {
  WidgetToImage._();

  static Future<RenderedImage> toPngBytes(
    Widget widget, {
    required Size logicalSize,
    double pixelRatio = 3.0,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        physicalConstraints: BoxConstraints.tight(logicalSize * pixelRatio),
        devicePixelRatio: pixelRatio,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(devicePixelRatio: pixelRatio),
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: pixelRatio,
    );
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode widget to PNG bytes.');
      }
      return RenderedImage(
        widthPx: image.width,
        heightPx: image.height,
        pixelRatio: pixelRatio,
        bytes: byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    } finally {
      image.dispose();
    }
  }
}
