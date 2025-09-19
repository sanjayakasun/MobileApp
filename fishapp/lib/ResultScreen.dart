import 'package:fishapp/FishChatBotPage.dart';
import 'package:fishapp/GradCamScreen.dart';
import 'package:flutter/material.dart';
import 'package:fishapp/OntologyDetailsPage.dart';

class ResultScreen extends StatelessWidget {
  final String speciesName;
  final String scientificName;
  final double confidenceScore;
  final String heatmapimageurl;
  final String imageUrl; // Optional: if you want to show the selected image

  ResultScreen({
    Key? key,
    required this.speciesName,
    required this.scientificName,
    required this.confidenceScore,
    required this.imageUrl,
    required this.heatmapimageurl,
  }) : super(key: key);

// Mapping species names to IDs
  final Map<String, String> speciesIdMap = {
    "Bulath_hapaya": "Q2249852",
    "Dankuda_pethiya": "Q28599176",
    "Depulliya": "Q1518816",
    "Halamal_dandiya": "Q269931",
    "Lethiththaya": "Q637598",
    "Pathirana_salaya": "Q2917966",
    "Thal_kossa": "Q2703814",
  };

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F59);
    String? speciesId = speciesIdMap[speciesName];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classification Results',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Gradient-weighted Class Activation Mapping\nGrad-CAM',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Image Box
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  heatmapimageurl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Result Box
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Classification Result',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                  Text(speciesName, style: const TextStyle(fontSize: 18)),
                  Text(
                    scientificName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Confidence Score',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(confidenceScore * 100).toStringAsFixed(1)} %',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: confidenceScore, // e.g. 0.91
                    minHeight: 10,
                    color: primaryColor, // or your primaryColor
                    backgroundColor: Colors.indigo.shade100,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GradCamScreen(
                              originalImageUrl:
                                  imageUrl, // send original image url
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.question_mark_rounded, color: primaryColor),
                  label: Text(
                    'How ? Explain Using Grad-CAM ',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // back to home
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    'Take Another',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FishChatBotPage(
                              speciesName: speciesName,
                            ), // pass actual species
                      ),
                    );
                  },
                  icon: Icon(Icons.chat_bubble, color: primaryColor),
                  label: Text('Try GPT', style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ElevatedButton.icon(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder:
                //             (context) => GradCamScreen(
                //               originalImageUrl:
                //                   imageUrl, // send original image url
                //             ),
                //       ),
                //     );
                //   },
                //   icon: Icon(Icons.question_mark_rounded, color: primaryColor),
                //   label: Text(
                //     'How ? Explain Using Grad-CAM ',
                //     style: TextStyle(color: primaryColor),
                //   ),
                // ),

                ElevatedButton.icon(
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OntologyDetailsPage(speciesId: speciesId, imageUrl:imageUrl ),
                    ),
                  );
                },
                  icon: Icon(Icons.explore, color: primaryColor),
                  label: Text(
                    'Explore more',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
