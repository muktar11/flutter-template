import 'package:flutter/material.dart';

class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = ''; // Renamed to _category
  String _videoLink = '';
  String _imageUrl = ''; // Renamed to _imageUrl

  final List<String> _categories = [
    'Technology',
    'Health',
    'Education',
    'Finance',
    'Agriculture',
    'Environment',
    'Entertainment',
    'Fashion',
  ]; // Sample categories for the dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publish'),
       // backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey), // Set text color to grey
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey), // Set text color to grey
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _category.isNotEmpty ? _category : null,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Video Link',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey), // Set text color to grey
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a video link';
                  }
                  return null;
                },
                onSaved: (value) {
                  _videoLink = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey), // Set text color to grey
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
                onSaved: (value) {
                  _imageUrl = value ?? '';
                },
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Perform your publish action here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Publishing...')),
                      );
                    }
                  },
                  child: Text('Publish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

