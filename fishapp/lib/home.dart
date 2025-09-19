import 'dart:convert';
import 'dart:io';
import 'package:fishapp/ResultScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // static const primaryColor = Color(0xFF001F59);
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_image == null) return;

    //open show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF001F59),
            ), // Primary color
            strokeWidth: 4.0,
          ),
        );
      },
    );

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.189:8000/predict/'), // Use my device IP
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
      final response = await request.send();
      final responseStr = await response.stream.bytesToString();
      final jsonResp = json.decode(responseStr);

      // Close the loading dialog before navigating
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultScreen(
                speciesName: jsonResp['prediction'],
                scientificName: '',
                confidenceScore: jsonResp['confidence'] ?? 0.90,
                imageUrl:
                    "http://192.168.1.189:8000${jsonResp['original_image']}",
                heatmapimageurl: "http://192.168.1.189:8000${jsonResp['heatmap_image']}",
              ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to classify the species.\n\n$e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F59);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Endemic Fish Species Classification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Predicting Endemic Fish Species in                   Sri Lanka',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Take a clear photo of the fish for accurate classification',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              'Fish Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _image == null
                      ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_image != null) {
                    _uploadImage(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('No Image Selected'),
                          content: const Text(
                            'Please select an image before classifying.',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF001F59),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CLASSIFY SPECIES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Expanded(child: Divider(thickness: 1, color: primaryColor)),
            const Text(
              '*Note: only for following 7 Endemic fish species of Sri Lanka',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.right,
            ),
            const Text(
              'Dawkinsia sri lankensis, Puntius titteya, Pethiya nigrofasciata, Pethia cumingii, Belontia signata, Devario pathirana and Rasboroides vateriflorisare',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 119, 119, 119),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const Expanded(child: Divider(thickness: 1, color: primaryColor)),
          ],
        ),
      ),
    );
  }
}
