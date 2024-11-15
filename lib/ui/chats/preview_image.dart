import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; // or gallery_saver
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  Future<void> saveImage(BuildContext context) async {
    try {
      // Download the image
      var response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes));
      // Save the image to the gallery
      final result = await ImageGallerySaver.saveImage(response.data);

      if (result['isSuccess'] && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 70),
            backgroundColor: Color(0xCC1E1F22),
            content: Text(
              "Image saved to gallery!",
              style: TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 70),
            backgroundColor: const Color(0xCC1E1F22),
            content: Text(
              "Failed to save image: $e.",
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Image"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => saveImage(context), // Save button
          ),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2.0, // Adjust maximum zoom
        ),
      ),
    );
  }
}
