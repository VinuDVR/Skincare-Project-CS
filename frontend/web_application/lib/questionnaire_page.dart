import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recommendation_page.dart';
import 'product_model.dart';

class QuestionnairePage extends StatefulWidget {
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  // Existing user input data
  String _skinType = 'Normal';
  String _priceRange = 'Budget-Friendly';
  String _routinePreference = 'Minimal (3 steps)';
  List<String> _skinConcerns = [];
  String _gender = 'Man';

  // New user input data (dummy questions)
  String _skinFeel = 'Normal (no oiliness or dryness)';
  String _sunscreenUsage = 'Daily';
  String _productInterest = 'Hydrating and moisturizing products';
  String _age = '18-24';

  final List<String> skinConcernsOptions = [
    'Acne or breakouts',
    'Redness or irritation',
    'Uneven skin tone',
    'Dark spots',
    'Large pores',
    'Dullness',
    'Dehydration',
    'Fine lines or wrinkles',
    'None of the above'
  ];

  final List<String> skinFeelOptions = [
    'Oily or greasy',
    'Dry or tight',
    'Normal (no oiliness or dryness)',
    'Sensitive or irritated',
  ];

  final List<String> sunscreenUsageOptions = [
    'Daily',
    'Only on sunny days or when outdoors',
    'Rarely or never',
  ];

  final List<String> productInterestOptions = [
    'Hydrating and moisturizing products',
    'Anti-aging or wrinkle-reducing products',
    'Brightening and evening skin tone',
    'Oil control and mattifying products',
    'Sensitive or reactive skin products',
    'Acne treatment and prevention',
  ];

  final List<String> ageOptions = [
    '18-24',
    '25-34',
    '35-55',
    '55+',
  ];

  final List<String> genderOptions = ['Man', 'Woman'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // For debugging; later you can remove these prints
      print("Collected Data:");
      print(json.encode({
        "Skin Type": _skinType,
        "Price Range": _priceRange,
        "Routine Preference": _routinePreference,
        "Skin Concerns": _skinConcerns,
        "Skin Feel": _skinFeel,
        "Sunscreen Usage": _sunscreenUsage,
        "Product Interest": _productInterest,
        "Age": _age,
        "Gender": _gender,
      }));

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "Gender": _gender,
            "Skin Type": _skinType,
            "Price Range": _priceRange,
            "Routine Preference": _routinePreference,
            "Skin Concerns": _skinConcerns,
            "Skin Feel": _skinFeel,
            "Sunscreen Usage": _sunscreenUsage,
            "Product Interest": _productInterest,
            "Age": _age,
          }),
        );

        Navigator.pop(context); // Close loading dialog

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationPage(
                routineProducts: (result['routine'] as List)
                    .map((e) => SkincareProduct.fromJson(e))
                    .toList(),
              ),
            ),
          );
        } else {
          _showErrorDialog('Failed to get recommendations');
        }
      } catch (e) {
        Navigator.pop(context);
        _showErrorDialog('Connection error: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Error', style: TextStyle(color: Colors.green.shade300)),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: Colors.green.shade300)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Helper method to build a styled DropdownButtonFormField
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: value,
      dropdownColor: Colors.green.shade50,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(color: Colors.black),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 9, 221, 175), Color(0xFF141517)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Card(
                color: Colors.white.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          'Tell Us About Your Skin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Skin Type Dropdown
                        _buildDropdownField(
                          label: 'Skin Type',
                          value: _skinType,
                          items: ['Normal', 'Dry', 'Oily', 'Sensitive', 'Combination'],
                          onChanged: (value) => setState(() => _skinType = value!),
                        ),
                        SizedBox(height: 16),
                        // Price Range Dropdown
                        _buildDropdownField(
                          label: 'Price Range',
                          value: _priceRange,
                          items: ['Budget-Friendly', 'Mid-range', 'High-end'],
                          onChanged: (value) => setState(() => _priceRange = value!),
                        ),
                        SizedBox(height: 16),
                        // Routine Preference Dropdown
                        _buildDropdownField(
                          label: 'Routine Preference',
                          value: _routinePreference,
                          items: [
                            'Minimal (3 steps)',
                            'Moderate (4 steps)',
                            'Extensive (6 steps)'
                          ],
                          onChanged: (value) => setState(() => _routinePreference = value!),
                        ),
                        SizedBox(height: 16),
                        // Dummy Question: How does your skin feel at the end of the day?
                        _buildDropdownField(
                          label: 'How does your skin feel at the end of the day?',
                          value: _skinFeel,
                          items: skinFeelOptions,
                          onChanged: (value) => setState(() => _skinFeel = value!),
                        ),
                        SizedBox(height: 16),
                        // Dummy Question: How often do you wear sunscreen?
                        _buildDropdownField(
                          label: 'How often do you wear sunscreen?',
                          value: _sunscreenUsage,
                          items: sunscreenUsageOptions,
                          onChanged: (value) => setState(() => _sunscreenUsage = value!),
                        ),
                        SizedBox(height: 20),
                        // Gender Dropdown
                        _buildDropdownField(
                          label: 'What do you identify as?',
                          value: _gender,
                          items: genderOptions,
                          onChanged: (value) => setState(() => _gender = value!),
                        ),
                        SizedBox(height: 16),
                        // Dummy Question: Let us know your age
                        _buildDropdownField(
                          label: 'Let us know your age',
                          value: _age,
                          items: ageOptions,
                          onChanged: (value) => setState(() => _age = value!),
                        ),
                        SizedBox(height: 24),
                        // Skin Concerns (Multi-select using chips)
                        Text(
                          'Skin Concerns (Select all that apply):',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: skinConcernsOptions.map((concern) {
                            final isSelected = _skinConcerns.contains(concern);
                            return FilterChip(
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.green.shade500,
                              label: Text(
                                concern,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _skinConcerns.add(concern);
                                  } else {
                                    _skinConcerns.remove(concern);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24),
                        // Submit Button
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Get your recommendations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
