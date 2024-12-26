import 'package:flutter/material.dart';

class HomeSearchPage extends StatefulWidget {
  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    // Implement your search logic here
    final query = _searchController.text;
    if (query.isNotEmpty) {
      // For example purposes, just print the query
      print('Searching for: $query');
    } else {
      // Handle empty search case
      print('Search query is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.search), // Search icon inside the input field
              ),
              onSubmitted: (value) => _performSearch(), // Perform search when pressing enter
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performSearch, // Perform search on button press
              child: Text('Search'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

