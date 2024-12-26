import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _author = '';
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
  int _numPhotos = 0;
  int _numVideos = 0;
  List<XFile?> _photos = [];
  List<String> _photoFileNames = [];
  List<String> _videoUrls = [];

  final List<String> _submissionTypes = [
    'Product',
    'Service',
    'Idea',
    'Research'
  ];
  final List<String> _developmentStages = [
    'Idea',
    'Prototype',
    'Testing',
    'Launched'
  ];

 Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Retrieve user_id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final url = Uri.parse('http://192.168.1.16:8000/api/publish/');
    var request = http.MultipartRequest('POST', url);

    // Add form fields
    request.fields['parent'] = userId.toString();
    request.fields['author'] = _author;
    request.fields['email'] = _email;
    request.fields['phone'] = _phone;
    request.fields['organization'] = _organization;
    request.fields['submission_type'] = _submissionType;
    request.fields['title'] = _title;
    request.fields['short_description'] = _shortDescription;
    request.fields['key_features_and_goals'] = _keyFeaturesGoals;
    request.fields['target_audience'] = _targetAudience;
    request.fields['development_stage'] = _developmentStage;
    request.fields['amount_needed'] = _amountNeeded;
    request.fields['how_will_funds_will_be_used'] = _fundUsage;
    request.fields['market_overview'] = _marketOverview;
    request.fields['competitors'] = _competitors;
    request.fields['potential_user_impact'] = _potentialUsersImpact;
    request.fields['uniqueness'] = _uniqueness;

    // Attach photos
    for (var photo in _photos) {
      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
      }
    }

    // Attach video URLs as a JSON array
    request.fields['videos'] = jsonEncode(_videoUrls);

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {

       Fluttertoast.showToast(
        msg: "Form submitted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );

      // Reset the form and fields
      _formKey.currentState!.reset();
      setState(() {
        _author = '';
        _email = '';
        _phone = '';
        _organization = '';
        _submissionType = '';
        _title = '';
        _shortDescription = '';
        _keyFeaturesGoals = '';
        _targetAudience = '';
        _developmentStage = '';
        _amountNeeded = '';
        _fundUsage = '';
        _marketOverview = '';
        _competitors = '';
        _potentialUsersImpact = '';
        _uniqueness = '';
        _numPhotos = 0;
        _numVideos = 0;
        _photos = [];
        _photoFileNames = [];
        _videoUrls = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit form. Error: ${response.statusCode}'),
        ),
      );
    }
  }
}


  Future<void> _pickPhoto(int index) async {
    final picker = ImagePicker();
    final pickedPhoto = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedPhoto != null) {
        _photos[index] = pickedPhoto;
        _photoFileNames[index] = pickedPhoto.name; // Update file name list
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _photoFileNames = List<String>.filled(_numPhotos, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
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
                      _buildTextInputField(
                          'Author', 'Enter your author', (value) => _author = value!),
                      _buildTextInputField('Email', 'Enter your email',
                          (value) => _email = value!),
                      _buildTextInputField('Phone', 'Enter your phone number',
                          (value) => _phone = value!),
                      _buildTextInputField(
                          'Organization',
                          'Enter your organization (if any)',
                          (value) => _organization = value!),
                      _buildDropdownField('Submission Type', _submissionTypes,
                          _submissionType, (value) => _submissionType = value!),
                      _buildTextInputField('Title', 'Enter project title',
                          (value) => _title = value!),
                      _buildTextInputField(
                          'Short Description',
                          'Provide a short description',
                          (value) => _shortDescription = value!,
                          maxLines: 4),
                      _buildTextInputField(
                          'Key Features and Goals',
                          'Key features/goals',
                          (value) => _keyFeaturesGoals = value!,
                          maxLines: 3),
                      _buildTextInputField(
                          'Target Audience',
                          'Who is the target audience?',
                          (value) => _targetAudience = value!),
                      _buildDropdownField(
                          'Development Stage',
                          _developmentStages,
                          _developmentStage,
                          (value) => _developmentStage = value!),
                      _buildTextInputField(
                          'Amount Needed',
                          'Enter the amount needed',
                          (value) => _amountNeeded = value!),
                      _buildTextInputField('How will funds be used?',
                          'Describe fund usage', (value) => _fundUsage = value!,
                          maxLines: 3),
                      _buildTextInputField(
                          'Market Overview',
                          'Describe the market overview',
                          (value) => _marketOverview = value!,
                          maxLines: 3),
                      _buildTextInputField(
                          'Competitors',
                          'List your competitors',
                          (value) => _competitors = value!,
                          maxLines: 2),
                      _buildTextInputField(
                          'Potential Users Impact',
                          'Describe the potential user impact',
                          (value) => _potentialUsersImpact = value!,
                          maxLines: 3),
                      _buildTextInputField(
                          'Uniqueness',
                          'What makes it unique?',
                          (value) => _uniqueness = value!,
                          maxLines: 3),

                      // Photo and Video Count Inputs
                      _buildNumberInputField('Number of Photos', (value) {
                        setState(() {
                          _numPhotos = int.tryParse(value ?? '0') ??
                              0; // Handle null by providing default '0'
                          _photos = List<XFile?>.filled(_numPhotos, null);
                          _photoFileNames = List<String>.filled(_numPhotos, '');
                        });
                      }),
                      _buildNumberInputField('Number of Videos', (value) {
                        setState(() {
                          _numVideos = int.tryParse(value ?? '0') ??
                              0; // Handle null by providing default '0'
                          _videoUrls = List<String>.filled(_numVideos, '');
                        });
                      }),

                      const SizedBox(height: 10),

                      // Render photo pickers based on the number specified
                      for (int i = 0; i < _numPhotos; i++) ...[
                        ElevatedButton(
                          onPressed: () => _pickPhoto(i),
                          child: Text('Attach Photo ${i + 1}'),
                        ),
                        if (_photoFileNames[i].isNotEmpty)
                          Text(_photoFileNames[i],
                              style: const TextStyle(color: Colors.grey)),
                      ],

                      // Render video URL fields based on the number specified
                      for (int i = 0; i < _numVideos; i++)
                        _buildTextInputField(
                            'Video URL ${i + 1}', 'Enter video URL', (value) {
                          _videoUrls[i] = value!;
                        }),

                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Submit'),
                        ),
                      ),
                      const SizedBox(height: 15.0),
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

  Widget _buildTextInputField(
    String label,
    String hint,
    FormFieldSetter<String> onSaved, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextFormField(
          onSaved: onSaved,
          validator: (value) => value!.isEmpty ? 'Please enter $label.' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey), // Make the hint text gray
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0), // Add padding inside the input field
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: TextStyle(
              color: Colors.grey), // Make the text inside the input field gray
          maxLines: maxLines,
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }

 Widget _buildNumberInputField(
  String label, 
  FormFieldSetter<String> onChanged
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.brown, // Set label text color to brown
        ),
      ),
    TextFormField(
  keyboardType: TextInputType.number,
  onChanged: onChanged,
  validator: (value) => value!.isEmpty ? 'Please enter $label.' : null,
  decoration: InputDecoration(
    hintText: 'Enter $label',
    hintStyle: TextStyle(color: Colors.brown), // Set the hint text color
  ),
  style: TextStyle(color: Colors.brown), // Set the input text color
),

      const SizedBox(height: 15.0),
    ],
  );
}


  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedItem,
    FormFieldSetter<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.brown, // Set label text color to brown
          ),
        ),
        DropdownButtonFormField<String>(
          value: items.contains(selectedItem) ? selectedItem : null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12.0, vertical: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: onChanged,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select $label' : null,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }
}
