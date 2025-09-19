import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OntologyDetailsPage extends StatefulWidget {
  final String? speciesId; // e.g., Q2249852
  final String? imageUrl;

  const OntologyDetailsPage({Key? key, required this.speciesId, this.imageUrl})
    : super(key: key);

  @override
  _OntologyDetailsPageState createState() => _OntologyDetailsPageState();
}

class _OntologyDetailsPageState extends State<OntologyDetailsPage> {
  Map<String, dynamic>? speciesData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSpeciesDetails();
  }

  Future<void> fetchSpeciesDetails() async {
    final url = "http://192.168.1.189:8000/fish/${widget.speciesId}/";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          speciesData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F59);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ontology Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Knowledge Based Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Image Box
            //     Container(
            //       height: 300,
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //         color: Colors.grey[200],
            //         border: Border.all(color: Colors.grey.shade400),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: ClipRRect(
            //         borderRadius: BorderRadius.circular(16),
            //         child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            // ? Image.network(
            //     widget.imageUrl!,
            //     fit: BoxFit.cover,
            //     loadingBuilder: (context, child, loadingProgress) {
            //       if (loadingProgress == null) return child;
            //       return const Center(child: CircularProgressIndicator());
            //     },
            //     errorBuilder: (context, error, stackTrace) => const Center(
            //       child: Icon(
            //         Icons.broken_image,
            //         size: 60,
            //         color: Colors.grey,
            //       ),
            //     ),
            //   )
            // : const Center(
            //     child: Icon(
            //       Icons.image_not_supported,
            //       size: 60,
            //       color: Colors.grey,
            //     ),
            //   ),
            //       ),
            //     ),
            // Display only the image from previous page
            if (widget.imageUrl != null)
              Center(
                child: Image.network(
                  widget.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // Now show API data if available
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? const Center(child: Text("Failed to load species details"))
                : speciesData == null
                ? const Center(child: Text("No data available"))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speciesData!["label"] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Scientific Name: ${speciesData!["scientificName"] ?? "N/A"}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (speciesData!["vernacularNames"] != null)
                      Text(
                        "Common Names: ${(speciesData!["vernacularNames"] as List).join(", ")}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "Family: ${speciesData!["family"] ?? "N/A"}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Genus: ${speciesData!["genus"] ?? "N/A"}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "IUCN Status: ${speciesData!["iucnStatus"] ?? "N/A"}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      speciesData!["description"] ?? "No description available",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
