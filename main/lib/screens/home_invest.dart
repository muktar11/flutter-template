import 'package:flutter/material.dart';

class InvestPage extends StatefulWidget {
  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _budget = ''; // Adjusted to have a leading underscore
  String _investmentType = ''; // Adjusted to have a leading underscore
  String _description = '';
  String _category = '';

  final List<String> _investments = [
    'Equity',
    'Loan',
    'Grant',
    'Other',
  ];

  final List<String> _categories = [
    'Technology',
    'Health',
    'Education',
    'Finance',
    'Agriculture',
    'Environment',
    'Entertainment',
    'Fashion',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invest'),
       // backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.white,
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
                style: TextStyle(color: Colors.grey),
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
                  labelText: 'Budget',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  return null;
                },
                onSaved: (value) {
                  _budget = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey),
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Investment Type',
                  border: OutlineInputBorder(),
                ),
                value: _investmentType.isNotEmpty ? _investmentType : null,
                items: _investments.map((String invest) {
                  return DropdownMenuItem<String>(
                    value: invest,
                    child: Text(invest),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _investmentType = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an investment type';
                  }
                  return null;
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
