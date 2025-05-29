// lib/widgets/journal_card_widget.dart
import 'package:flutter/material.dart';

class JournalCardWidget extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const JournalCardWidget({
    Key? key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMoodIcon(entry['mood']),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['title'] ?? 'Untitled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          entry['date'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                entry['content'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icon(Icons.sentiment_very_satisfied, color: Colors.green, size: 24);
      case 'sad':
        return Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 24);
      case 'anxious':
        return Icon(Icons.sentiment_dissatisfied, color: Colors.purple, size: 24);
      case 'excited':
        return Icon(Icons.sentiment_very_satisfied, color: Colors.blue, size: 24);
      case 'neutral':
      default:
        return Icon(Icons.sentiment_neutral, color: Colors.orange, size: 24);
    }
  }
}