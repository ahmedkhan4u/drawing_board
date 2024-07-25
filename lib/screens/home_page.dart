import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scribble/scribble.dart';
import 'package:share_plus/share_plus.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late ScribbleNotifier notifier;

  @override
  void initState() {
    notifier = ScribbleNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        actions: _buildActions(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Expanded(
              child: Card(
                clipBehavior: Clip.hardEdge,
                margin: EdgeInsets.zero,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                child: Scribble(
                  notifier: notifier,
                  drawPen: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                children: [
                  _buildColorToolbar(context),
                  const VerticalDivider(width: 32),
                  _buildStrokeToolbar(context),
                  _buildPointerModeSwitcher(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(context) {
    return [
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Undo",
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Redo",
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: "Clear",
        onPressed: notifier.clear,
      ),
      IconButton(
        icon: const Icon(Icons.image),
        tooltip: "Show PNG Image",
        onPressed: () => _showImage(context),
      ),
      IconButton(
        icon: const Icon(Icons.data_object),
        tooltip: "Show JSON",
        onPressed: () => _showJson(context),
      ),
    ];
  }

  void _showImage(BuildContext context) async {
    final image = notifier.renderImage();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generated Image"),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(snapshot.data!.buffer.asUint8List())
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final image = await notifier.renderImage();
              await _shareImage(image.buffer.asUint8List());
            },
            child: const Text("Share"),
          ),

          TextButton(
            onPressed: () async {
              final image = await notifier.renderImage();
              _saveToGallery(image);
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sketch as JSON"),
        content: SizedBox.expand(
          child: SelectableText(
            jsonEncode(notifier.currentSketch.toJson()),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.widths)
            _buildStrokeButton(
              context,
              strokeWidth: w,
              state: state,
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
                color: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                border: state.map(
                  drawing: (s) =>
                      Border.all(width: selected ? 1.5 : 0, color: selected ? Colors.grey.shade500 : Colors.transparent),
                  erasing: (_) => Border.all(width: 1),
                ),
                borderRadius: BorderRadius.circular(50.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildEraserButton(context),
          _buildColorButton(context, color: Colors.black),
          _buildColorButton(context, color: Colors.red),
          _buildColorButton(context, color: Colors.green),
          _buildColorButton(context, color: Colors.blue),
          _buildColorButton(context, color: Colors.yellow),
          _buildColorButton(context, color: Colors.teal),
          _buildColorButton(context, color: Colors.grey),
          _buildColorButton(context, color: Colors.cyan),
          _buildColorButton(context, color: Colors.purpleAccent),
          _buildColorButton(context, color: Colors.orange),
          _buildColorButton(context, color: Colors.pink),
          _buildColorButton(context, color: Colors.deepPurple),
          _buildColorButton(context, color: Colors.lightGreenAccent),
          _buildColorButton(context, color: Colors.blueGrey),
          _buildColorButton(context, color: Colors.brown),
        ],
      ),
    );
  }

  Widget _buildPointerModeSwitcher(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: notifier.select(
          (value) => value.allowedPointersMode,
        ),
        builder: (context, value, child) {
          return SegmentedButton<ScribblePointerMode>(
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
            onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
            segments: const [
              ButtonSegment(
                value: ScribblePointerMode.all,
                icon: Icon(Icons.touch_app),
                label: Text("All pointers"),
              ),
              ButtonSegment(
                value: ScribblePointerMode.penOnly,
                icon: Icon(Icons.draw),
                label: Text("Pen only"),
              ),
            ],
            selected: {value},
          );
        });
  }

  Widget _buildEraserButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) => value is Erasing),
      builder: (context, value, child) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: value,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
  }) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) => value is Drawing && value.selectedColor == color.value),
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ColorButton(
          color: color,
          isActive: value,
          onPressed: () => notifier.setColor(color),
        ),
      ),
    );
  }

  void _saveToGallery(ByteData image) async {
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.photos.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }

    if (permissionStatus) {
      final result = await ImageGallerySaver.saveImage(image.buffer.asUint8List());
      debugPrint(result.toString());
      if (result["isSuccess"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image saved to gallery"),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image not saved to gallery"),
          ),
        );
      }
    }
  }

  Future<void> _shareImage(Uint8List imageBytes) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      // Create a temporary file
      final file = await File('${tempDir.path}/shared_image.png').create();
      // Write the image bytes to the file
      await file.writeAsBytes(imageBytes);

      // Share the image using Share Plus
      await Share.shareXFiles([XFile(file.path)], text: 'Check out this image!');
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    super.key,
  });

  final Color color;

  final Color? outlineColor;

  final bool isActive;

  final VoidCallback onPressed;

  final Icon? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: switch (isActive) {
              true => outlineColor ?? color,
              false => Colors.transparent,
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive ? const BorderSide(color: Colors.white, width: 2) : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
      ),
    );
  }
}
