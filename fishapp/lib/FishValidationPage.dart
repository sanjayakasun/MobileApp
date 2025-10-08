import 'package:flutter/material.dart';

// --- Models ---
class FishKeyStep {
  final String question;
  final Map<String, dynamic> options; // answer → nextStep or FishSpecies
  FishKeyStep({required this.question, required this.options});
}

class FishSpecies {
  final String scientific;
  final String local;
  FishSpecies({required this.scientific, required this.local});
}

// --- Decision Tree (for your 7 species) ---
final Map<String, dynamic> fishKey = {
  "start": FishKeyStep(
    question: "Family?",
    options: {
      "Cyprinidae": "cyprinidae_step1",
      "Osphronemidae": "osphronemidae_step1",
    },
  ),

  // ==================== CYPRINIDAE PATH ====================
  "cyprinidae_step1": FishKeyStep(
    question: "Lateral line?",
    options: {
      "Complete": "cyprinidae_step2",
      "Incomplete": "cyprinidae_step3",
    },
  ),

  "cyprinidae_step2": FishKeyStep(
    question: "Barbels present?",
    options: {
      "Yes": "cyprinidae_step4",
      "No": "cyprinidae_step5",
    },
  ),

  "cyprinidae_step3": FishKeyStep(
    question: "Nature of dorsal fin spines – Smooth",
    options: {
      "yes":FishSpecies(
        scientific: "Puntius titteya",
        local: "lethiththaya",
      ),
      "No":"cyprinidae_step6"
    },
  ),

  "cyprinidae_step4": FishKeyStep(
    question: "Two pair of barbels present",
    options: {
       "Yes": "cyprinidae_step7",
      "No": "not_included",
    },
  ),
  "cyprinidae_step5": FishKeyStep(
    question: "Position of mouth- Subterminal",
    options: {
       "Yes": "cyprinidae_step8",
      "No": "not_included",
    },
  ),
  "cyprinidae_step6": FishKeyStep(
    question: "Present of bands on the body",
    options: {
       "Yes": "cyprinidae_step9",
      "No": FishSpecies(
        scientific: "Rasboroides vaterifloris",
        local: "halamal dandiya",
      ),
    },
  ),

  "cyprinidae_step7": FishKeyStep(
    question: "Presence of 8–9 dark, irregular bars on body",
    options: {
       "Yes": FishSpecies(
        scientific: "Devario pathirana",
        local: "Pathirana salaya",
      ),
      "No": "not_included",
    },
  ),
    "cyprinidae_step8": FishKeyStep(
    question: "Nature of dorsal fin spines- Serrate",
    options: {
       "Yes": FishSpecies(
        scientific: "Pethiya nigrofasciata",
        local: "Bulath hapaya",
      ),
      "No": FishSpecies(
        scientific: "Dawkinsia srilankensis",
        local: "Dankuda pethiya",
      ),
    },
  ),

  

  "cyprinidae_step9": FishKeyStep(
    question: "Pelvic/anal/dorsal fin tint?",
    options: {
      "Yellow": FishSpecies(
        scientific: "Pethiya cumingii",
        local: "Depulliya",
      ),
      "Other": "not_included",
    },
  ),

  // ==================== OSPHRONEMIDAE PATH ====================
  "osphronemidae_step1": FishKeyStep(
    question: "Dark lines from snout to operculum?",
    options: {
      "Yes": "not_included",
      "No": FishSpecies(
        scientific: "Belontia signata",
        local: "Thal kossa",
      ),
    },
  ),
};



// --- UI Widget ---
class FishValidationPage extends StatefulWidget {
  final String cnnPrediction; // CNN predicted species name
  const FishValidationPage({Key? key, required this.cnnPrediction})
      : super(key: key);

  @override
  State<FishValidationPage> createState() => _FishValidationPageState();
}

class _FishValidationPageState extends State<FishValidationPage> {
  String currentStep = "start";
  FishSpecies? finalSpecies;

  void nextStep(String choice) {
    final step = fishKey[currentStep];

    if (step is FishKeyStep) {
      final next = step.options[choice];

      if (next is FishSpecies) {
        // End point (species identified)
        setState(() {
          finalSpecies = next;
        });
      } else if (next is String) {
        if (fishKey.containsKey(next)) {
          setState(() {
            currentStep = next;
          });
        } else {
          // species not included in your 7
          setState(() {
            finalSpecies = FishSpecies(
              scientific: "Not covered in this key",
              local: "-",
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finalSpecies != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Validation Result")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("CNN Prediction:",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(widget.cnnPrediction, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text("Validation Key Result:",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${finalSpecies!.local} (${finalSpecies!.scientific})",
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = "start";
                    finalSpecies = null;
                  });
                },
                child: const Text("Restart Validation"),
              )
            ],
          ),
        ),
      );
    }

    final step = fishKey[currentStep] as FishKeyStep;
    return Scaffold(
      appBar: AppBar(title: const Text("Fish Validation Key")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(step.question,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...step.options.keys.map((choice) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () => nextStep(choice),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: Text(choice, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
