import 'package:flutter/material.dart';

class QuestionnairePage extends StatefulWidget {
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  // User input data
  String _skinType = 'Normal';
  String _priceRange = 'Budget-friendly';
  String _routinePreference = 'Minimal (3 steps)';
  List<String> _skinConcerns = [];

  final List<String> skinConcernsOptions = [
    'Acne or breakouts',
    'Dryness',
    'Oily skin',
    'Sensitive skin',
    'Redness or irritation',
    'Uneven skin tone',
    'Dark spots',
    'Large pores',
    'Dullness',
    'Fine lines or wrinkles'
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Print for testing, replace with API call
      print("Skin Type: $_skinType");
      print("Price Range: $_priceRange");
      print("Routine Preference: $_routinePreference");
      print("Skin Concerns: $_skinConcerns");

      // Navigate or process data as required
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
        backgroundColor: Colors.purple.shade300,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your skin:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade300,
                ),
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Skin Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: _skinType,
                items: ['Normal', 'Dry', 'Oily', 'Sensitive', 'Combination']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _skinType = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Price Range',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: _priceRange,
                items: ['Budget-friendly', 'Mid-range', 'High-end']
                    .map((range) => DropdownMenuItem(
                          value: range,
                          child: Text(range),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priceRange = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Routine Preference',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: _routinePreference,
                items: [
                  'Minimal (3 steps)',
                  'Moderate (4 steps)',
                  'Extensive (6 steps)'
                ]
                    .map((routine) => DropdownMenuItem(
                          value: routine,
                          child: Text(routine),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _routinePreference = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              Text(
                'Skin Concerns (Select all that apply):',
                style: TextStyle(fontSize: 16),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 5,
                children: skinConcernsOptions.map((concern) {
                  final isSelected = _skinConcerns.contains(concern);
                  return FilterChip(
                    label: Text(concern),
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
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
