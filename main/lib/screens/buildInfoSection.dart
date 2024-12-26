import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/theme/theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EditableInfoSection extends StatefulWidget {
  final String label;
  final String content;
  final Function(String newContent) onSave;

  const EditableInfoSection({
    Key? key,
    required this.label,
    required this.content,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditableInfoSectionState createState() => _EditableInfoSectionState();
}

class _EditableInfoSectionState extends State<EditableInfoSection> {
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter ${widget.label.toLowerCase()}',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSave(_controller.text);
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.content,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                if (!isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String label;
  final String content;

  const InfoSection({
    required this.label,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
