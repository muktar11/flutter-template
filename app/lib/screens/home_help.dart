import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildFAQItem(
                'How do I reset my password?',
                'You can reset your password by going to the login page and clicking on "Forgot Password".',
              ),
              _buildFAQItem(
                'How do I contact support?',
                'You can contact support via the Contact Us page or email us at support@example.com.',
              ),
              _buildFAQItem(
                'Where can I find app updates?',
                'App updates can be found in the app store on your device.',
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Support',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'If you have any other questions or need assistance, please reach out to us:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
             ElevatedButton(
  onPressed: () {
    // Navigate to contact support page
  },
  child: const Text('Contact Us'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Adjusted padding
    textStyle: const TextStyle(fontSize: 16), // Optional: change button color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
    ),
  ),
),

              const SizedBox(height: 20),
              const Text(
                'Additional Resources',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildResourceItem('User Guide', 'Learn how to use the app effectively.'),
              _buildResourceItem('Community Forum', 'Join discussions and share tips with other users.'),
              _buildResourceItem('Feedback', 'Share your thoughts and suggestions with us.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to respective resource page
        },
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(description, style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}
