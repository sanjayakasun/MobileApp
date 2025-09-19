import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GradCamScreen extends StatefulWidget {
  final String originalImageUrl; // passed from results screen

  const GradCamScreen({Key? key, required this.originalImageUrl})
    : super(key: key);

  @override
  State<GradCamScreen> createState() => _GradCamScreenState();
}

class _GradCamScreenState extends State<GradCamScreen> {
  bool _isLoading = true;
  String? originalImage;
  String? heatmapImage;
  String? outlineImage;
  String? combinedImage;

  @override
  void initState() {
    super.initState();
    _fetchGradCamImages();
  }

  Future<void> _fetchGradCamImages() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://192.168.1.189:8000/explore_more_grad_cam/",
        ), // Your backend API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image_path": widget.originalImageUrl, // send original image url
        }),
      );

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);

        setState(() {
          originalImage = "http://192.168.1.189:8000${jsonResp['original']}";
          heatmapImage = "http://192.168.1.189:8000${jsonResp['heatmap']}";
          outlineImage = "http://192.168.1.189:8000${jsonResp['outlines']}";
          combinedImage = "http://192.168.1.189:8000${jsonResp['combined']}";
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load Grad-CAM images");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageBox(String? url, String label, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              url == null
                  ? const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  )
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.red,
                            ),
                          ),
                    ),
                  ),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color.fromARGB(255, 75, 75, 75), fontSize: 13),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F59);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grad-CAM Visualization',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Leveraging Taxonomic Features with \n CNN + Grad-CAM Explainability",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Endemic freshwater fish species often share very similar external characteristics, which makes classification a challenging task. To improve accuracy, we can leverage taxonomic features biologically meaningful traits such as fin structure, body markings, or barbels that distinguish species in ichthyology.",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 85, 85, 85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Grad-CAM produces a heatmap overlay on the fish image, highlighting the regions (e.g., fins, scales, or body patterns) that were most important for the CNN’s decision.",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "These visualizations help you understand which parts of the image contributed most to the model’s prediction.",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 92, 92, 92),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Below are the Grad-CAM visualizations generated for your selected image.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color.fromARGB(255, 43, 43, 43), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _buildImageBox(
                      originalImage,
                      "Original Image",
                      "This is the raw uploaded image used for prediction.",
                    ),
                    _buildImageBox(
                      heatmapImage,
                      "Grad-CAM heat map",
                      "Highlights regions of the image most influential in classification.",
                    ),
                    _buildImageBox(
                      outlineImage,
                      "Feature outline",
                      "Extracted important contours/features identified by the model.",
                    ),
                    _buildImageBox(
                      combinedImage,
                      "Heat map with outline",
                      "Overlay of heat map and outline, showing precise important areas.",
                    ),
                  ],
                ),
              ),
    );
  }
}
