import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _name = '';
  String _email = '';
  String _phone = '';
  String _organization = '';
  String _submissionType = '';
  String _title = '';
  String _shortDescription = '';
  String _keyFeaturesGoals = '';
  String _targetAudience = '';
  String _developmentStage = '';
  String _amountNeeded = '';
  String _fundUsage = '';
  String _marketOverview = '';
  String _competitors = '';
  String _potentialUsersImpact = '';
  String _uniqueness = '';
  int _numberOfPhotos = 0;
  int _numberOfVideos = 0;
  List<String> _photoUrls = [];
  List<String> _videoUrls = [];

  bool _showPhotoFields = false;
  bool _showVideoFields = false;

  final List<String> _submissionTypes = ['Product', 'Service', 'Idea', 'Research'];
  final List<String> _developmentStages = ['Idea', 'Prototype', 'Testing', 'Launched'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> formData = {
        '_id': 'some_id_value', // You can dynamically generate or fetch this if needed
        'parent': null, // Include this if required in your API
        'name': _name,
        'email': _email,
        'phone': _phone,
        'organization': _organization,
        'submission_type': _submissionType,
        'title': _title,
        'short_description': _shortDescription,
        'key_features_and_goals': _keyFeaturesGoals,
        'target_audience': _targetAudience,
        'development_stage': _developmentStage,
        'amount_needed': _amountNeeded,
        'how_will_funds_will_be_used': _fundUsage,
        'market_overview': _marketOverview,
        'competitors': _competitors,
        'potential_user_impact': _potentialUsersImpact,
        'uniqueness': _uniqueness,
        'no_of_photos': _numberOfPhotos,
        'no_of_videos': _numberOfVideos,
        'photos': _photoUrls,
        'videos': _videoUrls,
      };

      final url = Uri.parse('http://127.0.0.1:8000/api/publish/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit form. Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Crowdfunding Form'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Submit for Crowdfunding',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      _buildTextInputField('Name', 'Enter your name', (value) => _name = value!),
                      _buildTextInputField('Email', 'Enter your email', (value) => _email = value!),
                      _buildTextInputField('Phone', 'Enter your phone number', (value) => _phone = value!),
                      _buildTextInputField('Organization', 'Enter your organization (if any)', (value) => _organization = value!),
                      _buildDropdownField('Submission Type', _submissionTypes, _submissionType, (value) => _submissionType = value!),
                      _buildTextInputField('Title', 'Enter project title', (value) => _title = value!),
                      _buildTextInputField('Short Description', 'Provide a short description', (value) => _shortDescription = value!, maxLines: 4),
                      _buildTextInputField('Key Features and Goals', 'Key features/goals', (value) => _keyFeaturesGoals = value!, maxLines: 3),
                      _buildTextInputField('Target Audience', 'Who is the target audience?', (value) => _targetAudience = value!),
                      _buildDropdownField('Development Stage', _developmentStages, _developmentStage, (value) => _developmentStage = value!),
                      _buildTextInputField('Amount Needed', 'Enter the amount needed', (value) => _amountNeeded = value!),
                      _buildTextInputField('How will funds be used?', 'Describe fund usage', (value) => _fundUsage = value!, maxLines: 3),
                      _buildTextInputField('Market Overview', 'Describe the market overview', (value) => _marketOverview = value!, maxLines: 3),
                      _buildTextInputField('Competitors', 'List your competitors', (value) => _competitors = value!, maxLines: 2),
                      _buildTextInputField('Potential Users Impact', 'Describe the potential user impact', (value) => _potentialUsersImpact = value!, maxLines: 3),
                      _buildTextInputField('Uniqueness', 'What makes it unique?', (value) => _uniqueness = value!, maxLines: 3),
                      const SizedBox(height: 25.0),
                      _buildNumberInputField('Number of Photos', (value) {
                        _numberOfPhotos = int.tryParse(value!) ?? 0;
                      }),
                      _buildNumberInputField('Number of Videos', (value) {
                        _numberOfVideos = int.tryParse(value!) ?? 0;
                      }),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showPhotoFields = _numberOfPhotos > 0;
                            _showVideoFields = _numberOfVideos > 0;
                            _photoUrls = List.filled(_numberOfPhotos, '');
                            _videoUrls = List.filled(_numberOfVideos, '');
                          });
                        },
                        child: const Text('Attach'),
                      ),
                      const SizedBox(height: 20),
                      if (_showPhotoFields) ..._renderPhotoFields(),
                      if (_showVideoFields) ..._renderVideoFields(),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField(String label, String hint, FormFieldSetter<String> onSave, {int maxLines = 1}) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
          onSaved: onSave,
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedValue.isNotEmpty ? selectedValue : null,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select $label' : null,
          onChanged: onChanged,
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

  Widget _buildNumberInputField(String label, FormFieldSetter<String> onSaved) {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
          onSaved: onSaved,
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

  List<Widget> _renderPhotoFields() {
    return List.generate(_numberOfPhotos, (index) {
      return _buildTextInputField('Photo URL ${index + 1}', 'Enter photo URL', (value) => _photoUrls[index] = value!);
    });
  }

  List<Widget> _renderVideoFields() {
    return List.generate(_numberOfVideos, (index) {
      return _buildTextInputField('Video URL ${index + 1}', 'Enter video URL', (value) => _videoUrls[index] = value!);
    });
  }
}
