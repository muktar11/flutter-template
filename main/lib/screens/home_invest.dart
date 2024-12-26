import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InvestPage extends StatefulWidget {
  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _budget = '';
  String _investmentType = '';
  String _description = '';
  String _category = '';

  final List<String> _investments = ['Equity', 'Loan', 'Grant', 'Other'];
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

  final storage = const FlutterSecureStorage();

  Future<void> _submitInvestment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      //Retrieve user_id from SharedPrefernces
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final url = Uri.parse('http://192.168.1.16:8000/api/invest/');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'user_id': userId.toString(),
        'title': _title,
        'budget': _budget,
        'description': _description,
        'category': _category,
        'investment_type': _investmentType,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 201) {
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
        _title = '';
        _budget = '';
        _description = '';
        _category = '';
        _investmentType = '';
       
      });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to create investment: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
             
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
                      Text(
                        'Create Investment',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter Title',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                      const SizedBox(height: 25.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Budget',
                          hintText: 'Enter Budget',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                      const SizedBox(height: 25.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter Description',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                      const SizedBox(height: 25.0),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                      const SizedBox(height: 25.0),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Investment Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value:
                            _investmentType.isNotEmpty ? _investmentType : null,
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
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitInvestment,
                          child: const Text('Publish'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
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
}
