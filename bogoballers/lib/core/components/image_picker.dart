import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// This function crops the image using Dart canvas APIs.
Future<Uint8List?> cropImageDataWithDartLibrary({
  required ExtendedImageEditorState state,
}) async {
  try {
    final Uint8List? data = await state.rawImageData;
    if (data == null) return null;

    final Rect? cropRect = state.getCropRect();
    if (cropRect == null) return null;

    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final paint = Paint();
    final src = cropRect;
    final dst = Rect.fromLTWH(0, 0, cropRect.width, cropRect.height);

    canvas.drawImageRect(image, src, dst, paint);

    final ui.Image croppedImage = await recorder.endRecording().toImage(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );

    final ByteData? byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint("Crop error: $e");
    return null;
  }
}

/// A popup dialog for cropping images
class CropPopup extends StatefulWidget {
  final File file;
  final double? aspectRatio;

  const CropPopup({super.key, required this.file, required this.aspectRatio});

  @override
  State<CropPopup> createState() => _CropPopupState();
}

class _CropPopupState extends State<CropPopup> {
  final GlobalKey<ExtendedImageEditorState> _editorKey = GlobalKey();

  Future<void> _cropImage() async {
    final state = _editorKey.currentState;
    if (state == null) return;

    final Uint8List? croppedBytes = await cropImageDataWithDartLibrary(
      state: state,
    );

    if (croppedBytes != null) {
      Navigator.pop(context, croppedBytes);
    }
  }

  void _resetCrop() {
    final state = _editorKey.currentState;
    if (state != null) {
      state.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Crop Image"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          height: 470,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 400,
                height: 410,
                child: ExtendedImage.file(
                  widget.file,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  extendedImageEditorKey: _editorKey,
                  cacheRawData: true,
                  initEditorConfigHandler: (_) => EditorConfig(
                    cropAspectRatio: widget.aspectRatio,
                    cornerColor: context.appColors.accent800,
                    hitTestSize: 20,
                    cropRectPadding: const EdgeInsets.all(20),
                    maxScale: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          onPressed: () => Navigator.pop(context),
          label: 'Cancel',
          variant: ButtonVariant.ghost,
        ),
        AppButton(
          onPressed: _resetCrop,
          label: 'Reset',
          variant: ButtonVariant.ghost,
        ),
        AppButton(onPressed: _cropImage, label: 'Crop & Use'),
      ],
    );
  }
}

class AppImagePickerController {
  _AvatarCropperState? _state;

  /// Call this to open the picker + cropper
  Future<void> pickImage() async {
    await _state?._selectAndCropImage();
  }

  /// Get the final image bytes
  Uint8List? get selectedImage => _state?._avatarBytes;

  /// Get base64 string of image
  String get base64Image =>
      _state?._avatarBytes != null ? base64Encode(_state!._avatarBytes!) : '';
  String? get fileName => _state?.fileName;
}

/// The actual image cropper widget that only displays the selected image
class AppImagePicker extends StatefulWidget {
  final AppImagePickerController controller;
  final double aspectRatio;
  final double width;

  const AppImagePicker({
    super.key,
    required this.controller,
    this.aspectRatio = 1.0,
    this.width = 180,
  });

  @override
  State<AppImagePicker> createState() => _AvatarCropperState();
}

class _AvatarCropperState extends State<AppImagePicker> {
  Uint8List? _avatarBytes;
  String? _fileName;

  String? get fileName => _fileName;
  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    widget.controller._state = null;
    super.dispose();
  }

  Future<void> _selectAndCropImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result?.files.single.path == null) return;

    // Save the original file name
    _fileName = result!.files.single.name;

    final file = File(result.files.single.path!);
    final decoded = await decodeImageFromList(await file.readAsBytes());

    Uint8List? finalBytes;

    if (decoded.width != decoded.height) {
      final cropped = await showDialog<Uint8List>(
        context: context,
        builder: (_) => CropPopup(file: file, aspectRatio: widget.aspectRatio),
      );
      finalBytes = cropped;
    } else {
      finalBytes = await file.readAsBytes();
    }

    if (finalBytes != null) {
      setState(() {
        _avatarBytes = finalBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _avatarBytes != null
          ? Image.memory(
              _avatarBytes!,
              width: widget.width,
              height: widget.width / widget.aspectRatio,
              fit: BoxFit.cover,
            )
          : Container(
              width: widget.width,
              height: widget.width / widget.aspectRatio,
              color: appColors.gray400,
              child: Icon(Icons.image, size: 48, color: appColors.gray100),
            ),
    );
  }
}
