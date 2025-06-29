import 'package:bogoballers/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/constants/image_strings.dart';

class FlexibleNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final double size;
  final double radius;
  final bool isCircular;
  final double? aspectRatio;
  final bool enableEdit;
  final Future<String?> Function()? onEdit;
  final bool enableViewImageFull;
  final BoxFit fit;

  const FlexibleNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fallbackAsset = ImageStrings.appLogoFill,
    this.size = 100,
    this.isCircular = true,
    this.radius = Sizes.radiusSm,
    this.aspectRatio = 1 / 1,
    this.enableEdit = false,
    this.onEdit,
    this.enableViewImageFull = false,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<FlexibleNetworkImage> createState() => _FlexibleNetworkImageState();
}

class _FlexibleNetworkImageState extends State<FlexibleNetworkImage> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;
  }

  void _viewFullImage(BuildContext context) {
    if (_imageUrl == null || _imageUrl!.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(widget.fallbackAsset, fit: BoxFit.contain);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleEdit() async {
    if (widget.onEdit != null) {
      final newUrl = await widget.onEdit!();
      if (newUrl != null) {
        setState(() => _imageUrl = newUrl);
      }
    }
  }

  Widget _buildImage() {
    return Image.network(
      _imageUrl ?? '',
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(widget.fallbackAsset, fit: widget.fit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final double editButtonSize = 24;
    final double editIconSize = 16;

    Widget clippedImage = widget.isCircular
        ? ClipOval(child: _buildImage())
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: AspectRatio(
              aspectRatio: widget.aspectRatio ?? 1.0,
              child: _buildImage(),
            ),
          );

    return SizedBox(
      width: widget.size,
      height: widget.isCircular ? widget.size : null,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.enableViewImageFull
                ? () => _viewFullImage(context)
                : null,
            child: clippedImage,
          ),
          if (widget.enableEdit)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _handleEdit,
                child: Container(
                  width: editButtonSize,
                  height: editButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appColors.gray100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    size: editIconSize,
                    color: appColors.accent900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ViewOnlyNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;

  const ViewOnlyNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fallbackAsset = ImageStrings.appLogoFill,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit);
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(fallbackAsset, fit: fit);
      },
    );
  }
}
