import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recommendation_page.dart';
import 'product_model.dart';
import 'main.dart';
import 'chat_fab.dart';

class QuestionnairePage extends StatefulWidget {
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  
  String _skinType = 'Normal';
  String _priceRange = 'Budget-Friendly';
  String _routinePreference = 'Minimal (3 steps)';
  List<String> _skinConcerns = [];
  String _gender = 'Man';

  
  String _skinFeel = 'Normal (no oiliness or dryness)';
  String _sunscreenUsage = 'Daily';
  String _age = '18-24';

  final List<String> skinTypeOptions = [
  'Normal',
  'Dry',
  'Oily',
  'Sensitive',
  'Combination'
  ];

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

    
    print("Collected Data:");
    print(json.encode({
      "Skin Type": _skinType,
      "Price Range": _priceRange,
      "Routine Preference": _routinePreference,
      "Skin Concerns": _skinConcerns,
      "Skin Feel": _skinFeel,
      "Sunscreen Usage": _sunscreenUsage,
      "Age": _age,
      "Gender": _gender,
    }));

    
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
          "Age": _age,
        }),
      );

      Navigator.pop(context); 

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        final List<SkincareProduct> primaryProducts = (result['primary'] as List)
            .map((e) => SkincareProduct.fromJson(e))
            .toList();
        final List<SkincareProduct> alternateProducts = (result['alternate'] as List)
            .map((e) => SkincareProduct.fromJson(e))
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationPage(
              primaryProducts: primaryProducts,
              alternateProducts: alternateProducts,
              filters: {
                "Price Range": _priceRange,
                "Routine Preference": _routinePreference,
                "Skin Type": _skinType,
                "Skin Concerns": _skinConcerns,
                "Gender": _gender,
              },
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

  
   Widget _buildDropdownField(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Card(
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.grey.shade900,
            isExpanded: true,
            value: value,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            onChanged: onChanged,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade600,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text('SkinGenie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: "Go to Home",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildQuestionSection(
                    'Skin Type',
                    _buildDropdownField(_skinType, skinTypeOptions, (val) => setState(() => _skinType = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Price Range',
                    _buildDropdownField(_priceRange, ['Budget-Friendly', 'Mid-range', 'High-end'], (val) => setState(() => _priceRange = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Routine Preference',
                    _buildDropdownField(_routinePreference, ['Minimal (3 steps)', 'Moderate (4 steps)', 'Extensive (6 steps)'], (val) => setState(() => _routinePreference = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Skin Concerns',
                    _buildMultiSelectChips(skinConcernsOptions, _skinConcerns),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Skin Feel',
                    _buildDropdownField(_skinFeel, ['Oily or greasy', 'Dry or tight', 'Normal (no oiliness or dryness)', 'Sensitive or irritated'], (val) => setState(() => _skinFeel = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Sunscreen Usage',
                    _buildDropdownField(_sunscreenUsage, ['Daily', 'Only on sunny days or when outdoors', 'Rarely or never'], (val) => setState(() => _sunscreenUsage = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Age Range',
                    _buildDropdownField(_age, ['18-24', '25-34', '35-55', '55+'], (val) => setState(() => _age = val!)),
                  ),
                  SizedBox(height: 16),
                  _buildQuestionSection(
                    'Gender',
                    _buildDropdownField(_gender, ['Man', 'Woman'], (val) => setState(() => _gender = val!)),
                  ),
                  SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const ChatFloatingButton(),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Tell Us About Your Skin',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildQuestionSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildMultiSelectChips(List<String> options, List<String> selected) {
    return Card(
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return ChoiceChip(
                  label: Text(option, 
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey.shade700,
                  onSelected: (bool selectedState) {
                    setState(() {
                      selectedState 
                          ? selected.add(option)
                          : selected.remove(option);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected 
                          ? Colors.green.shade800 
                          : Colors.grey.shade600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade500,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Get Your Recommendations',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
