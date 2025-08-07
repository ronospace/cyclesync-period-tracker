import 'package:flutter/material.dart';
import '../services/symptom_ai_service.dart';

class SymptomAnalysisScreen extends StatefulWidget {
  const SymptomAnalysisScreen({super.key});

  @override
  State<SymptomAnalysisScreen> createState() => _SymptomAnalysisScreenState();
}

class _SymptomAnalysisScreenState extends State<SymptomAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  final SymptomAIService _aiService = SymptomAIService();

  String? _aiResponse;
  bool _isLoading = false;

  Future<void> _analyzeSymptoms() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final response = await _aiService.analyzeSymptoms(input);

    setState(() {
      _aiResponse = response;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 Symptom AI Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Describe your current symptoms:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g., Cramps, bloating, fatigue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Analyze'),
              onPressed: _analyzeSymptoms,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_aiResponse != null && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_aiResponse!, style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
